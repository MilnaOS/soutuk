import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/interfaces/i_text_to_speech_service.dart';
import 'iso_locale_map.dart';

/// The real "screen reader" — speaks already-translated text using the
/// device's own OS-native TTS engine (the same one screen readers use).
/// Free, no network call, no API key, works offline. This replaces the
/// earlier OpenAI-TTS/Cloudflare-Worker-MeloTTS paths entirely; Ollama Cloud
/// translation routing through the Worker is unaffected — this only ever
/// touches the TTS half of the pipeline.
class FlutterTtsService implements ITextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  @override
  Future<bool> speak(String text, {String voice = 'eng'}) async {
    final locale = IsoLocaleMap.isoToLocale[voice];
    if (locale == null) return false;

    try {
      await _ensureInitialized();

      final available = await _tts.isLanguageAvailable(locale);
      if (available != true) return false;

      await _tts.setLanguage(locale);
      final result = await _tts.speak(text);
      return result == 1;
    } catch (_) {
      return false;
    }
  }
}
