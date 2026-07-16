/// The TTS "screen reader" step — speaks already-translated text aloud.
/// No translation intelligence involved, just voicing. [voice] is a target
/// language hint (Soutuk's ISO-639-3 code); implementations that don't need
/// it (or can't use it) may ignore it. Returns whether speaking succeeded.
abstract class ITextToSpeechService {
  Future<bool> speak(String text, {String voice});
}
