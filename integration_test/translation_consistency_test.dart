// Data-gathering harness, not a pass/fail suite — calls the real production
// audio (STT) service and the real translation path the app actually uses
// (CloudflareWorkerService -> Ollama Cloud, not metered OpenAI) to
// characterize output consistency across languages. Only the STT leg still
// hits metered OpenAI billing — there's no free STT alternative wired up yet.
// Requires OPENAI_API_KEY (STT + one-time fixture synthesis) in the
// environment. Results are written to JSON files under
// /home/jeremy/soutuk_test_results/ for external inspection after the run.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:soutuk/data/services/cloudflare_worker_service.dart';
import 'package:soutuk/data/services/openai_audio_service.dart';
import 'package:soutuk/data/repositories/dot_repository.dart';

/// Self-contained OpenAI TTS call, used only to generate a synthetic source
/// audio *fixture* for the STT round-trip test below — unrelated to the
/// app's real output TTS (which is on-device via FlutterTtsService).
Future<Uint8List?> _synthesizeSourceFixture(String text) async {
  final apiKey = Platform.environment['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) return null;
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/audio/speech'),
    headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
    body: jsonEncode({
      'model': 'gpt-4o-mini-tts',
      'input': text,
      'voice': 'alloy',
      'response_format': 'mp3',
    }),
  );
  if (response.statusCode != 200) return null;
  return response.bodyBytes;
}

const String _testText = 'The patient needs immediate medical attention.';
const Map<String, String> _targetLanguages = {
  'lat': 'Latin',
  'spa': 'Spanish',
  'fra': 'French',
  'deu': 'German',
};
const int _runsPerLanguage = 10;
const String _resultsDir = '/home/jeremy/soutuk_test_results';

Future<void> _writeResults(String filename, Map<String, dynamic> data) async {
  final dir = Directory(_resultsDir);
  await dir.create(recursive: true);
  final file = File('$_resultsDir/$filename');
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
}

Map<String, dynamic> _summarize(Map<String, List<String>> results) {
  final summary = <String, dynamic>{};
  results.forEach((lang, outputs) {
    summary[lang] = {
      'runs': outputs.length,
      'distinct_outputs': outputs.toSet().length,
      'outputs': outputs,
    };
  });
  return summary;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('translateText consistency across languages (text-only, no STT)',
      (tester) async {
    final translator = CloudflareWorkerService();
    final repo = DotRepository();
    final results = <String, List<String>>{};

    for (final entry in _targetLanguages.entries) {
      final outputs = <String>[];
      for (var i = 0; i < _runsPerLanguage; i++) {
        final payload = await repo.loadActivePayload('auto', entry.key, _testText);
        final response = await translator.translateText(_testText, payload);
        outputs.add(response.translatedText);
      }
      results[entry.value] = outputs;
    }

    await _writeResults('translate_text_consistency.json', _summarize(results));
    expect(results.isNotEmpty, true);
  }, timeout: const Timeout(Duration(minutes: 10)));

  testWidgets('STT-to-TTT round trip via synthetic audio (full real pipeline)',
      (tester) async {
    final audioService = OpenAiAudioService();
    final translator = CloudflareWorkerService();
    final repo = DotRepository();

    // Generate synthetic source audio via the real TTS endpoint, then feed it
    // back through the real transcribe() -> translateText() pipeline — no
    // physical microphone or prerecorded fixture needed.
    final mp3Bytes = await _synthesizeSourceFixture(_testText);
    expect(mp3Bytes, isNotNull, reason: 'TTS synthesis of the source fixture failed');

    // STT doesn't depend on the target language, so transcribe once per
    // iteration and fan the single transcript out to every target language —
    // running STT per-language here would be 4x more metered OpenAI calls
    // for zero extra signal (translateText is the only per-language step,
    // and it's free via CloudflareWorkerService).
    final results = <String, List<String>>{for (final v in _targetLanguages.values) v: <String>[]};
    for (var i = 0; i < _runsPerLanguage; i++) {
      final sttResult = await audioService.transcribe(mp3Bytes!, filename: 'fixture.mp3');
      if (sttResult.text == null) {
        for (final entry in _targetLanguages.entries) {
          results[entry.value]!.add('[STT FAILED: ${sttResult.failureReason}]');
        }
        continue;
      }
      for (final entry in _targetLanguages.entries) {
        final payload = await repo.loadActivePayload('auto', entry.key, sttResult.text!);
        final response = await translator.translateText(sttResult.text!, payload);
        results[entry.value]!.add(response.translatedText);
      }
    }

    await _writeResults('stt_ttt_consistency.json', _summarize(results));
    expect(results.isNotEmpty, true);
  }, timeout: const Timeout(Duration(minutes: 15)));
}
