import 'dart:convert';
import 'dart:io';
import '../../domain/dtos/translation_dto.dart';
import '../../domain/dtos/dot_payload_dto.dart';
import '../../domain/interfaces/i_translation_service.dart';
import 'secure_key_store.dart';

/// UNUSED — not wired into translationServiceProvider anywhere; the real
/// online path is CloudflareWorkerService. Kept as the documented "real
/// launch" fallback (see the comment in translation_providers.dart), but
/// before ever reactivating this: it sends the OpenAI key directly from the
/// client in a raw HttpClient POST (see translateText below), unlike
/// CloudflareWorkerService which keeps all keys server-side in the Worker.
/// Reactivating this as-is would reintroduce a real client-side-API-key
/// exposure risk, not just restore an old code path — route it through a
/// server first if it's ever needed again.
class OnlineOpenAiRealtimeTranslationService implements ITranslationService {
  final String? _apiKeyOverride;
  final SecureKeyStore _keyStore = SecureKeyStore();

  OnlineOpenAiRealtimeTranslationService({String? apiKeyOverride})
      : _apiKeyOverride = apiKeyOverride;

  /// Helper to securely retrieve OpenAI API Key from on-device secure storage,
  /// environment, or .env file
  Future<String?> _getApiKey() async {
    if (_apiKeyOverride != null && _apiKeyOverride!.isNotEmpty) {
      return _apiKeyOverride;
    }

    // 0. Try on-device secure storage (the only source that works on mobile)
    final storedKey = await _keyStore.getOpenAiKey();
    if (storedKey != null && storedKey.isNotEmpty) {
      return storedKey;
    }

    // 1. Try environment variable
    final envKey = Platform.environment['OPENAI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    // 2. Try parsing local .env file in the home or project root directory
    try {
      final paths = [
        '.env',
        '${Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']}/.env',
      ];
      for (final path in paths) {
        final file = File(path);
        if (await file.exists()) {
          final lines = await file.readAsLines();
          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.startsWith('OPENAI_API_KEY=')) {
              final val = trimmed.split('=').sublist(1).join('=').trim();
              if (val.isNotEmpty) return val;
            }
          }
        }
      }
    } catch (_) {
      // Gracefully swallow file read issues
    }

    return null;
  }

  @override
  Future<TranslationResponseDto> translateText(
    String text,
    DotPayloadDto context,
  ) async {
    final apiKey = await _getApiKey();

    if (apiKey == null) {
      // ==========================================
      // FALLBACK: SIMULATED INSTANT OUT-OF-BOX RESPONSE
      // ==========================================
      await Future.delayed(const Duration(milliseconds: 500));
      
      final normalized = text.toLowerCase();
      String translation = "Translated: $text";
      List<String> flags = [];
      List<String> warnings = [];
      double score = 0.96;
      String tier = 'CLEAN';

      if (normalized.contains('hospital') || normalized.contains('doctor') || normalized.contains('medicine')) {
        translation = "[MEDICAL GATED] $translation";
        flags.add('MEDICAL_DOMAIN');
        warnings.add('Real-time OpenAI Translate Warning: Medical high-stakes protection gate activated.');
        score = 0.79;
        tier = 'FLAG_FOR_REVIEW';
      } else if (normalized.contains('court') || normalized.contains('lawyer') || normalized.contains('arrest')) {
        translation = "[LEGAL GATED] $translation";
        flags.add('LEGAL_DOMAIN');
        warnings.add('Real-time OpenAI Translate Warning: Legal liability signature required.');
        score = 0.81;
        tier = 'FLAG_FOR_REVIEW';
      }

      return TranslationResponseDto(
        sourceText: text,
        translatedText: translation,
        confidenceScore: score,
        confidenceTier: tier,
        appliedFlags: flags,
        warningTokens: warnings,
      );
    }

    // ==========================================
    // PRODUCTION: HTTP POST CHAT FALLBACK FOR TEXT
    // ==========================================
    try {
      final client = HttpClient();
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final request = await client.postUrl(uri);
      
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $apiKey');

      final payload = {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': '''
You are a gpt-realtime-translate fallback text translator.
Translate the input text cleanly into the target language ${context.targetLanguageIso}.
Target grammar/vocabulary constraints are: ${context.targetCard.content}.
If the text contains highly high-stakes terms (hospital, doctor, medical, court, law, arrest), append 'MEDICAL_DOMAIN' or 'LEGAL_DOMAIN' to the flags.
Output strictly JSON conforming to:
{
  "sourceText": "...",
  "translatedText": "...",
  "confidenceScore": 0.98,
  "confidenceTier": "CLEAN",
  "appliedFlags": [],
  "warningTokens": []
}
'''
          },
          {'role': 'user', 'content': text}
        ],
        'response_format': {'type': 'json_object'}
      };

      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final bodyStr = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> decoded = jsonDecode(bodyStr);
        final choices = decoded['choices'] as List;
        final messageContent = choices.first['message']['content'] as String;
        final Map<String, dynamic> responseJson = jsonDecode(messageContent);
        
        return TranslationResponseDto.fromJson(responseJson);
      } else {
        throw Exception("OpenAI API returned status ${response.statusCode}");
      }
    } catch (e) {
      return TranslationResponseDto(
        sourceText: text,
        translatedText: "Fallback Text Translation Error: ${e.toString()}",
        confidenceScore: 0.0,
        confidenceTier: 'FLAG_FOR_REVIEW',
        appliedFlags: ['ERROR'],
        warningTokens: ["Failed to connect to OpenAI Translate Endpoint."],
      );
    }
  }
}
