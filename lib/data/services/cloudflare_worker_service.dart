import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/dtos/translation_dto.dart';
import '../../domain/dtos/dot_payload_dto.dart';
import '../../domain/dtos/language_identification_dto.dart';
import '../../domain/interfaces/i_translation_service.dart';

/// Dev/testing-phase translation backend — routes translateText() through
/// Ollama Cloud via a thin Cloudflare Worker that holds the Ollama API key
/// server-side (see D:\SoutukAPP\cloudflare\soutuk-worker\). This exists to
/// avoid burning metered OpenAI spend during testing — NOT the production
/// backend. Revisit before any real launch (see plan history). TTS is
/// handled separately by FlutterTtsService (on-device, free) — no longer
/// routed through this Worker.
class CloudflareWorkerService implements ITranslationService {
  static const String workerBaseUrl = 'https://soutuk-worker.pb-aim.workers.dev';

  @override
  Future<TranslationResponseDto> translateText(String text, DotPayloadDto context) async {
    try {
      final response = await http
          .post(
            Uri.parse('$workerBaseUrl/translate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': text,
              'targetLanguageIso': context.targetLanguageIso,
              'targetCardContent': context.targetCard.content,
            }),
          )
          // 60s, not 30s: the low-resource-language override
          // (nemotron-3-nano:30b-cloud) is a large model that can take
          // 30s+ to spin up on a cold call before settling to ~10-25s on
          // warm calls — 30s clipped genuine successes mid-cold-start.
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Exception('Worker /translate returned status ${response.statusCode}');
      }
      return TranslationResponseDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      return TranslationResponseDto(
        sourceText: text,
        translatedText: 'Worker Translation Error: ${e.toString()}',
        confidenceScore: 0.0,
        confidenceTier: 'FLAG_FOR_REVIEW',
        appliedFlags: const ['ERROR'],
        warningTokens: const ['Failed to reach the Cloudflare Worker /translate endpoint.'],
      );
    }
  }

  /// Text-based language ID for Conversation Mode's handshake phase — see
  /// the Worker's /identify route for why this is a separate step from
  /// transcription (gpt-4o-transcribe doesn't expose a detected-language
  /// field the way whisper-1's verbose_json does).
  Future<LanguageIdentificationDto> identifyLanguage(String transcript) async {
    try {
      final response = await http
          .post(
            Uri.parse('$workerBaseUrl/identify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'transcript': transcript}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Worker /identify returned status ${response.statusCode}');
      }
      return LanguageIdentificationDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      return LanguageIdentificationDto(
        confidence: 0,
        sufficientSample: false,
        reasoning: 'Failed to reach the Cloudflare Worker /identify endpoint: ${e.toString()}',
      );
    }
  }
}
