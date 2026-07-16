import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/cloudflare_worker_service.dart';
import '../../data/services/mic_audio_capture_service.dart';
import '../../data/services/on_device_stt_service.dart';
import '../../data/datasources/real_dot_knowledge.dart';
import '../../data/datasources/linguistics_memory_alpha.dart';
import 'translation_providers.dart';

/// Conversation Mode: a real-time two-person interpreter flow, distinct from
/// the app's default press-to-talk. Owner (Person One) states their primary
/// language, then the app listens for Person Two's introduction and
/// identifies their language before settling into turn-based translation.
///
/// Two STT backends are used deliberately, not one: the handshake step
/// (identifying Person Two's unknown language) needs cloud transcription —
/// OpenAiAudioService — because on-device recognizers require knowing the
/// target locale up front and can't identify an unknown spoken language.
/// Once both languages are known, steady-state turns switch to free,
/// on-device OnDeviceSttService, using strict alternation (owner, then
/// person two, then owner...) to know whose known locale to listen for —
/// "automatic" here means the app tracks whose turn it is for you, not that
/// it re-identifies the language from scratch on every line.
///
/// This is a v1: each turn is still a tap-to-capture-then-release action
/// (like press-to-talk), not continuous VAD-gated background listening —
/// that's a real, separate piece of work (silence detection, muting the mic
/// during the app's own TTS playback) not yet built.
enum ConversationPhase {
  ownerSetup,
  awaitingPersonTwoIntro,
  identifying,
  needsMoreSample,
  noConsensus,
  noDotCard,
  conversing,
}

class ConversationTurn {
  final String id;
  final String text;
  final String translated;
  final bool isOwner;
  final DateTime timestamp;

  ConversationTurn({
    required this.id,
    required this.text,
    required this.translated,
    required this.isOwner,
  }) : timestamp = DateTime.now();
}

class ConversationModeState {
  final ConversationPhase phase;
  final String ownerLanguageIso;
  final String? personTwoLanguageIso;
  final String? personTwoLanguageName;
  final bool currentTurnIsOwner;
  final List<ConversationTurn> turns;
  final bool isListening;
  final bool isProcessing;
  final String? statusMessage;

  ConversationModeState({
    this.phase = ConversationPhase.ownerSetup,
    this.ownerLanguageIso = 'eng',
    this.personTwoLanguageIso,
    this.personTwoLanguageName,
    this.currentTurnIsOwner = true,
    this.turns = const [],
    this.isListening = false,
    this.isProcessing = false,
    this.statusMessage,
  });

  ConversationModeState copyWith({
    ConversationPhase? phase,
    String? ownerLanguageIso,
    String? Function()? personTwoLanguageIso,
    String? Function()? personTwoLanguageName,
    bool? currentTurnIsOwner,
    List<ConversationTurn>? turns,
    bool? isListening,
    bool? isProcessing,
    String? Function()? statusMessage,
  }) {
    return ConversationModeState(
      phase: phase ?? this.phase,
      ownerLanguageIso: ownerLanguageIso ?? this.ownerLanguageIso,
      personTwoLanguageIso:
          personTwoLanguageIso != null ? personTwoLanguageIso() : this.personTwoLanguageIso,
      personTwoLanguageName:
          personTwoLanguageName != null ? personTwoLanguageName() : this.personTwoLanguageName,
      currentTurnIsOwner: currentTurnIsOwner ?? this.currentTurnIsOwner,
      turns: turns ?? this.turns,
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      statusMessage: statusMessage != null ? statusMessage() : this.statusMessage,
    );
  }
}

final conversationModeProvider =
    StateNotifierProvider<ConversationModeNotifier, ConversationModeState>((ref) {
  return ConversationModeNotifier(ref);
});

class ConversationModeNotifier extends StateNotifier<ConversationModeState> {
  final Ref _ref;
  StreamSubscription? _captureSubscription;
  BytesBuilder? _pcmBuffer;

  // Below this confidence, treat identification as unresolved rather than
  // risk locking in a wrong language for the whole conversation.
  static const double _confidenceThreshold = 0.55;

  ConversationModeNotifier(this._ref) : super(ConversationModeState());

  void setOwnerLanguage(String iso) {
    state = state.copyWith(ownerLanguageIso: iso);
  }

  void startConversation() {
    state = state.copyWith(
      phase: ConversationPhase.awaitingPersonTwoIntro,
      statusMessage: () => 'Listening for the other person\'s introduction...',
    );
  }

  void reset() {
    state = ConversationModeState();
  }

  Future<bool> _hasDotCoverage(String iso) async {
    await RealDotKnowledge.ensureLoaded();
    return RealDotKnowledge.languageCard(iso) != null ||
        LinguisticsMemoryAlpha.grammarRules.containsKey(iso);
  }

  bool get _isHandshakePhase =>
      state.phase == ConversationPhase.awaitingPersonTwoIntro ||
      state.phase == ConversationPhase.needsMoreSample ||
      state.phase == ConversationPhase.noConsensus;

  Future<void> startTurn() async {
    if (state.isListening || state.isProcessing) return;

    if (_isHandshakePhase) {
      final capture = _ref.read(micCaptureServiceProvider);
      final granted = await capture.hasPermission();
      if (!granted) {
        state = state.copyWith(
          statusMessage: () => 'Microphone permission denied. Enable it in system settings.',
        );
        return;
      }
      try {
        _pcmBuffer = BytesBuilder();
        final audioStream = await capture.startCapture();
        _captureSubscription = audioStream.listen(
          (chunk) => _pcmBuffer?.add(chunk),
          onError: (e) {
            state = state.copyWith(
              isListening: false,
              statusMessage: () => 'Microphone error: ${e.toString()}',
            );
          },
        );
        state = state.copyWith(isListening: true);
      } catch (e) {
        state = state.copyWith(statusMessage: () => 'Failed to start microphone: ${e.toString()}');
      }
      return;
    }

    // Conversing phase — on-device, locale is whoever's turn it currently is.
    final stt = _ref.read(onDeviceSttServiceProvider);
    final sourceIso = state.currentTurnIsOwner ? state.ownerLanguageIso : state.personTwoLanguageIso!;
    final failure = await stt.startListening(sourceIso);
    if (failure != null) {
      state = state.copyWith(statusMessage: () => _onDeviceFailureMessage(failure.failureReason));
      return;
    }
    state = state.copyWith(isListening: true);
  }

  Future<void> endTurn() async {
    if (!state.isListening) return;

    if (_isHandshakePhase) {
      await _endHandshakeTurn();
      return;
    }
    await _endConversingTurn();
  }

  Future<void> _endHandshakeTurn() async {
    final capture = _ref.read(micCaptureServiceProvider);
    await capture.stopCapture();
    await _captureSubscription?.cancel();
    _captureSubscription = null;
    state = state.copyWith(isListening: false);

    final pcmBytes = _pcmBuffer?.toBytes();
    _pcmBuffer = null;
    if (pcmBytes == null || pcmBytes.isEmpty) return;

    state = state.copyWith(isProcessing: true);
    try {
      final wavBytes = MicAudioCaptureService.wrapPcmAsWav(pcmBytes);
      final audioService = _ref.read(audioServiceProvider);
      final sttResult = await audioService.transcribe(wavBytes);

      if (sttResult.text == null) {
        state = state.copyWith(
          statusMessage: () => 'No speech detected — try again, closer to the mic.',
        );
        return;
      }
      await _handleIdentification(sttResult.text!);
    } catch (e) {
      state = state.copyWith(statusMessage: () => 'Voice pipeline error: ${e.toString()}');
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  Future<void> _endConversingTurn() async {
    state = state.copyWith(isListening: false);
    state = state.copyWith(isProcessing: true);
    try {
      final stt = _ref.read(onDeviceSttServiceProvider);
      final result = await stt.stopListening();
      if (result.text == null) {
        state = state.copyWith(statusMessage: () => _onDeviceFailureMessage(result.failureReason));
        return;
      }

      final isOwner = state.currentTurnIsOwner;
      final fromIso = isOwner ? state.ownerLanguageIso : state.personTwoLanguageIso!;
      final toIso = isOwner ? state.personTwoLanguageIso! : state.ownerLanguageIso;

      await _translateAndSpeak(result.text!, fromIso: fromIso, toIso: toIso, isOwner: isOwner);
      state = state.copyWith(currentTurnIsOwner: !isOwner);
    } catch (e) {
      state = state.copyWith(statusMessage: () => 'Voice pipeline error: ${e.toString()}');
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  String _onDeviceFailureMessage(OnDeviceSttFailureReason? reason) {
    switch (reason) {
      case OnDeviceSttFailureReason.unavailable:
        return 'Speech recognition is unavailable on this device — check microphone permission in system settings.';
      case OnDeviceSttFailureReason.unsupportedLanguage:
        return "This language isn't supported by your device's speech recognizer.";
      case OnDeviceSttFailureReason.noSpeechDetected:
        return 'No speech detected — try again, closer to the mic.';
      default:
        return 'Voice transcription failed.';
    }
  }

  Future<void> _handleIdentification(String transcript) async {
    // Client-side gate before spending an API call on something too short to
    // possibly identify — e.g. a single interjection.
    if (transcript.trim().split(RegExp(r'\s+')).length < 2) {
      state = state.copyWith(
        phase: ConversationPhase.needsMoreSample,
        statusMessage: () =>
            'Sample too small ("$transcript") — ask them to say a bit more so the language can be identified.',
      );
      return;
    }

    state = state.copyWith(phase: ConversationPhase.identifying);
    final worker = CloudflareWorkerService();
    final result = await worker.identifyLanguage(transcript);

    if (!result.sufficientSample) {
      state = state.copyWith(
        phase: ConversationPhase.needsMoreSample,
        statusMessage: () =>
            'Sample too small — ask them to say a bit more. ${result.reasoning}'.trim(),
      );
      return;
    }

    if (result.detectedIso == null || result.confidence < _confidenceThreshold) {
      state = state.copyWith(
        phase: ConversationPhase.noConsensus,
        statusMessage: () =>
            'Could not confidently identify the language yet. ${result.reasoning}'.trim(),
      );
      return;
    }

    final hasCard = await _hasDotCoverage(result.detectedIso!);
    if (!hasCard) {
      state = state.copyWith(
        phase: ConversationPhase.noDotCard,
        personTwoLanguageIso: () => result.detectedIso,
        personTwoLanguageName: () => result.detectedName,
        statusMessage: () =>
            'Identified as ${result.detectedName ?? result.detectedIso}, but Soutuk has no real grammar data for it yet — translation quality would not be reliable.',
      );
      return;
    }

    // Success — lock in Person Two's language and translate their intro
    // line immediately. It's the owner's turn next.
    state = state.copyWith(
      phase: ConversationPhase.conversing,
      personTwoLanguageIso: () => result.detectedIso,
      personTwoLanguageName: () => result.detectedName,
      currentTurnIsOwner: true,
      statusMessage: () => 'Identified ${result.detectedName ?? result.detectedIso} — conversing.',
    );
    await _translateAndSpeak(transcript, fromIso: result.detectedIso!, toIso: state.ownerLanguageIso, isOwner: false);
  }

  Future<void> _translateAndSpeak(
    String text, {
    required String fromIso,
    required String toIso,
    required bool isOwner,
  }) async {
    final repo = _ref.read(dotRepositoryProvider);
    final worker = CloudflareWorkerService();
    final ttsService = _ref.read(ttsServiceProvider);

    final payload = await repo.loadActivePayload(fromIso, toIso, text);
    final response = await worker.translateText(text, payload);

    final turn = ConversationTurn(
      id: 'turn_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      translated: response.translatedText,
      isOwner: isOwner,
    );
    state = state.copyWith(turns: [...state.turns, turn]);

    await ttsService.speak(response.translatedText, voice: toIso);
  }
}
