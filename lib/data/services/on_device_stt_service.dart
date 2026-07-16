import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'iso_locale_map.dart';

enum OnDeviceSttFailureReason { unavailable, unsupportedLanguage, noSpeechDetected }

class OnDeviceSttResult {
  final String? text;
  final OnDeviceSttFailureReason? failureReason;

  OnDeviceSttResult.success(this.text) : failureReason = null;
  OnDeviceSttResult.failure(this.failureReason) : text = null;
}

/// Free, on-device, no API key, no network call — the actual mic-input
/// counterpart to FlutterTtsService. Replaces OpenAiAudioService for every
/// case where the spoken language is already known (Push-to-Talk's two
/// language boxes, Conversation Mode's steady-state turns once both
/// languages are locked in). Deliberately NOT used for Conversation Mode's
/// handshake step — native OS recognizers need a target locale up front and
/// can't identify an unknown spoken language the way a cloud model can; that
/// one narrow case still needs OpenAiAudioService/gpt-4o-transcribe.
class OnDeviceSttService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  String _lastWords = '';

  Future<bool> _ensureInitialized() async {
    if (_isAvailable) return true;
    try {
      _isAvailable = await _speech.initialize(
        onError: (e) => debugPrint('[OnDeviceSttService] error: ${e.errorMsg}'),
      );
    } catch (e) {
      debugPrint('[OnDeviceSttService] initialize failed: $e');
      _isAvailable = false;
    }
    return _isAvailable;
  }

  /// Starts listening for [sourceIso]. Caller must hold the mic open (via
  /// isListening) and call [stopListening] to get the final transcript —
  /// mirrors the existing tap-to-start/tap-to-stop mic button pattern rather
  /// than changing the interaction model.
  Future<OnDeviceSttResult?> startListening(String sourceIso) async {
    final locale = IsoLocaleMap.isoToLocale[sourceIso];
    if (locale == null) {
      return OnDeviceSttResult.failure(OnDeviceSttFailureReason.unsupportedLanguage);
    }

    final ready = await _ensureInitialized();
    if (!ready) {
      return OnDeviceSttResult.failure(OnDeviceSttFailureReason.unavailable);
    }

    _lastWords = '';
    await _speech.listen(
      localeId: locale,
      onResult: (result) => _lastWords = result.recognizedWords,
      partialResults: true,
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 8),
    );
    return null; // null = listening started successfully, no result yet
  }

  Future<OnDeviceSttResult> stopListening() async {
    await _speech.stop();
    // speech_to_text's onResult callback fires asynchronously; give the
    // final result a brief moment to land before reading _lastWords.
    await Future.delayed(const Duration(milliseconds: 300));
    if (_lastWords.trim().isEmpty) {
      return OnDeviceSttResult.failure(OnDeviceSttFailureReason.noSpeechDetected);
    }
    return OnDeviceSttResult.success(_lastWords.trim());
  }

  bool get isListening => _speech.isListening;
}
