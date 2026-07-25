import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

enum SttFailureReason { noApiKey, networkError, emptyTranscript }

class SttResult {
  final String? text;
  final SttFailureReason? failureReason;

  SttResult.success(this.text) : failureReason = null;
  SttResult.failure(this.failureReason) : text = null;
}

/// Speech-to-text only now — voice synthesis moved to FlutterTtsService
/// (on-device, free, the actual "screen reader" mechanism).
///
/// Moved server-side 2026-07-23: was a direct client-side call to
/// api.openai.com with an exposed OpenAI key (gpt-4o-transcribe, metered
/// per-request pricing). Now goes through the Cloudflare Worker's
/// /transcribe route, which holds its own dedicated OpenRouter key
/// server-side and calls Whisper Large V3 ($0.0015/min) — cheaper, and the
/// key never touches the client at all. Same shape as CloudflareWorkerService
/// (translate/identify) but kept as its own class since this one deals with
/// multipart audio, not JSON.
class OpenAiAudioService {
  static const String _workerBaseUrl = 'https://soutuk-worker.pb-aim.workers.dev';

  Future<SttResult> transcribe(Uint8List audioBytes, {String filename = 'utterance.wav'}) async {
    try {
      final uri = Uri.parse('$_workerBaseUrl/transcribe');
      final request = http.MultipartRequest('POST', uri)
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
