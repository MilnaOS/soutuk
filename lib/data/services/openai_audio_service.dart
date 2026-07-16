import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'secure_key_store.dart';

enum SttFailureReason { noApiKey, networkError, emptyTranscript }

class SttResult {
  final String? text;
  final SttFailureReason? failureReason;

  SttResult.success(this.text) : failureReason = null;
  SttResult.failure(this.failureReason) : text = null;
}

/// Speech-to-text only now — voice synthesis moved to FlutterTtsService
/// (on-device, free, the actual "screen reader" mechanism).
class OpenAiAudioService {
  final SecureKeyStore _keyStore = SecureKeyStore();

  /// Same lookup order as OnlineOpenAiRealtimeTranslationService._getApiKey():
  /// on-device secure storage, then environment variable, then a local .env file.
  Future<String?> _getApiKey() async {
    final storedKey = await _keyStore.getOpenAiKey();
    if (storedKey != null && storedKey.isNotEmpty) {
      return storedKey;
    }

    final envKey = Platform.environment['OPENAI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

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

  Future<SttResult> transcribe(Uint8List audioBytes, {String filename = 'utterance.wav'}) async {
    final apiKey = await _getApiKey();
    if (apiKey == null) return SttResult.failure(SttFailureReason.noApiKey);

    try {
      final uri = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['model'] = 'gpt-4o-transcribe'
        ..files.add(http.MultipartFile.fromBytes('file', audioBytes, filename: filename));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return SttResult.failure(SttFailureReason.networkError);
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (decoded['text'] as String?)?.trim();
      if (text == null || text.isEmpty) {
        return SttResult.failure(SttFailureReason.emptyTranscript);
      }
      return SttResult.success(text);
    } catch (_) {
      return SttResult.failure(SttFailureReason.networkError);
    }
  }
}
