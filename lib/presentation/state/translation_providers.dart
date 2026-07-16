import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/interfaces/i_translation_service.dart';
import '../../domain/interfaces/i_text_to_speech_service.dart';
import '../../domain/interfaces/i_mesh_coordinator.dart';
import '../../domain/interfaces/i_dot_repository.dart';
import '../../domain/dtos/language_option_dto.dart';
import '../../domain/dtos/translation_dto.dart';
import '../../data/services/mock_translation_service.dart';
import '../../data/services/noop_mesh_coordinator.dart';
import '../../data/repositories/dot_repository.dart';
import '../../data/services/cloudflare_worker_service.dart';
import '../../data/services/domain_detection_service.dart';
import '../../data/services/mic_audio_capture_service.dart';
import '../../data/services/openai_audio_service.dart';
import '../../data/services/on_device_stt_service.dart';
import '../../data/services/flutter_tts_service.dart';
import '../../data/datasources/language_catalog.dart';
import '../../data/datasources/linguistics_memory_alpha.dart';

// ==========================================
// 1. Dependency Injection Scaffolding Providers
// ==========================================

// Family, not a plain Provider watching conversationProvider — ConversationNotifier
// reads this from inside its own methods using conversationProvider's own Ref,
// so watching conversationProvider here would create a circular dependency
// (Riverpod throws CircularDependencyError). isOnline is passed explicitly by
// the caller instead, who already has it via state.isOnlineMode.
final translationServiceProvider = Provider.family<ITranslationService, bool>((ref, isOnline) {
  if (isOnline) {
    // Dev/testing default: routes through the Cloudflare Worker (Ollama
    // Cloud) instead of paying per-call OpenAI rates. Not the production
    // path — see D:\SoutukAPP\cloudflare\soutuk-worker\ and swap back to
    // OnlineOpenAiRealtimeTranslationService() when a launch process is
    // decided.
    return CloudflareWorkerService();
  } else {
    return MockTranslationService();
  }
});

final ttsServiceProvider = Provider<ITextToSpeechService>((ref) {
  // On-device, free, no network call — the actual "screen reader" mechanism.
  // No online/offline branching needed; this always works the same way.
  return FlutterTtsService();
});

final meshCoordinatorProvider = Provider<IMeshCoordinator>((ref) {
  // Defaults to Mock local NoOp coordinator. Swaps to P2pMeshCoordinator in Phase 5.
  final coordinator = NoOpMeshCoordinator();
  coordinator.initializeMesh(); // Trigger mock mesh states
  return coordinator;
});

final dotRepositoryProvider = Provider<IDotRepository>((ref) {
  return DotRepository();
});

final domainDetectionServiceProvider = Provider<DomainDetectionService>((ref) {
  return DomainDetectionService();
});

final micCaptureServiceProvider = Provider<MicAudioCaptureService>((ref) {
  return MicAudioCaptureService();
});

final audioServiceProvider = Provider<OpenAiAudioService>((ref) {
  return OpenAiAudioService();
});

// On-device, free, no API key — used everywhere the spoken language is
// already known. See OnDeviceSttService's doc comment for why
// OpenAiAudioService (above) is still needed for Conversation Mode's
// language-identification handshake specifically.
final onDeviceSttServiceProvider = Provider<OnDeviceSttService>((ref) {
  return OnDeviceSttService();
});

final languageCatalogProvider = FutureProvider<List<LanguageOption>>((ref) {
  return LanguageCatalog.loadAll();
});

// ==========================================
// 2. State Modeling for UI
// ==========================================

class UtteranceItem {
  final String id;
  final String text;
  final String translated;
  final bool isMe; // Local speaker vs target speaker
  final DateTime timestamp;
  final double confidence;
  final List<String> flags;

  UtteranceItem({
    required this.id,
    required this.text,
    required this.translated,
    this.isMe = true,
    required this.confidence,
    this.flags = const [],
  }) : timestamp = DateTime.now();
}

/// Which mic was tapped — determines translation direction. Push-to-Talk is
/// now a manual, always-on-device, two-language tool: the user already
/// knows both languages, so there's no auto-detection to do, just routing.
enum MicDirection { oneToTwo, twoToOne }

class ConversationState {
  final List<UtteranceItem> utterances;
  final bool isListening;
  final MicDirection? activeMicDirection;
  final bool isTranslating;
  final String languageOneIso;
  final String languageTwoIso;
  final String? activeWarning;
  final bool requiresSignature;
  final bool isSignatureCaptured;
  final String? capturedSignatureName;
  final bool isOnlineMode;

  ConversationState({
    this.utterances = const [],
    this.isListening = false,
    this.activeMicDirection,
    this.isTranslating = false,
    this.languageOneIso = 'eng',
    this.languageTwoIso = 'spa',
    this.activeWarning,
    this.requiresSignature = false,
    this.isSignatureCaptured = false,
    this.capturedSignatureName,
    // Defaults to true: offline mode routes through MockTranslationService,
    // which returns literal "Translated: $text" — a real user's first
    // translation attempt must hit the real (free, dev-path) online
    // translator, not a fake demo response they'd have no reason to expect.
    this.isOnlineMode = true,
  });

  ConversationState copyWith({
    List<UtteranceItem>? utterances,
    bool? isListening,
    MicDirection? Function()? activeMicDirection,
    bool? isTranslating,
    String? languageOneIso,
    String? languageTwoIso,
    String? Function()? activeWarning,
    bool? requiresSignature,
    bool? isSignatureCaptured,
    String? Function()? capturedSignatureName,
    bool? isOnlineMode,
  }) {
    return ConversationState(
      utterances: utterances ?? this.utterances,
      isListening: isListening ?? this.isListening,
      activeMicDirection:
          activeMicDirection != null ? activeMicDirection() : this.activeMicDirection,
      isTranslating: isTranslating ?? this.isTranslating,
      languageOneIso: languageOneIso ?? this.languageOneIso,
      languageTwoIso: languageTwoIso ?? this.languageTwoIso,
      activeWarning: activeWarning != null ? activeWarning() : this.activeWarning,
      requiresSignature: requiresSignature ?? this.requiresSignature,
      isSignatureCaptured: isSignatureCaptured ?? this.isSignatureCaptured,
      capturedSignatureName: capturedSignatureName != null ? capturedSignatureName() : this.capturedSignatureName,
      isOnlineMode: isOnlineMode ?? this.isOnlineMode,
    );
  }
}

// ==========================================
// 3. Conversation State Notifier
// ==========================================

class ConversationNotifier extends StateNotifier<ConversationState> {
  final Ref _ref;

  ConversationNotifier(this._ref) : super(ConversationState());

  void changeLanguageOne(String iso) {
    state = state.copyWith(languageOneIso: iso);
  }

  void changeLanguageTwo(String iso) {
    state = state.copyWith(languageTwoIso: iso);
  }

  /// Defaults to language-one -> language-two: typed input has no mic
  /// direction to infer from, and that's the more common "I speak language
  /// one, translate it" case. Voice input via a specific mic button passes
  /// its direction explicitly instead.
  Future<TranslationResponseDto?> translateMessage(
    String text, {
    String? sourceIso,
    String? targetIso,
    bool isMe = true,
  }) async {
    if (text.trim().isEmpty) return null;
    final from = sourceIso ?? state.languageOneIso;
    final to = targetIso ?? state.languageTwoIso;

    state = state.copyWith(isTranslating: true);

    try {
      final repo = _ref.read(dotRepositoryProvider);
      final translator = _ref.read(translationServiceProvider(state.isOnlineMode));
      final domainService = _ref.read(domainDetectionServiceProvider);

      // Perform local keyword-monitoring classifier analysis
      final assessment = domainService.analyzeText(text);

      // Load active context-specific sliced DOT cards from repository
      final payload = await repo.loadActivePayload(from, to, text);

      // Call abstract translator service
      final response = await translator.translateText(text, payload);

      // Merge local and remote flags/warnings. A flag can arrive from either
      // side without its warning text (e.g. the cloud model catches a
      // high-stakes term the local keyword list doesn't cover), so backfill
      // the canonical message for every merged flag rather than relying on
      // whichever side happened to attach one — otherwise the signature gate
      // can fire with a blank "No pending alerts." message.
      final mergedFlags = <String>{...assessment.activeFlags, ...response.appliedFlags}.toList();
      final mergedWarnings = <String>{
        ...assessment.warnings,
        ...response.warningTokens,
        for (final flag in mergedFlags)
          if (LinguisticsMemoryAlpha.highStakesWarnings.containsKey(flag))
            LinguisticsMemoryAlpha.highStakesWarnings[flag]!,
      }.toList();

      final newItem = UtteranceItem(
        id: "msg_${DateTime.now().millisecondsSinceEpoch}",
        text: text,
        translated: response.translatedText,
        isMe: isMe,
        confidence: response.confidenceScore,
        flags: mergedFlags,
      );

      // Hard block (signature gate) stays reserved for true high-stakes
      // domains. Other warnings — e.g. TRANSLATION_DISAGREEMENT from the
      // dual-isolate arbitration path — surface as a visible but
      // non-blocking banner instead; the two aren't the same severity and
      // shouldn't share one gate.
      final hasHighStakes = mergedFlags.contains('MEDICAL_DOMAIN') ||
          mergedFlags.contains('LEGAL_DOMAIN');

      state = state.copyWith(
        utterances: [...state.utterances, newItem],
        isTranslating: false,
        activeWarning: () => mergedWarnings.isNotEmpty ? mergedWarnings.first : null,
        requiresSignature: hasHighStakes,
        isSignatureCaptured: false, // Reset signature on new high-stakes match
        capturedSignatureName: () => null,
      );
      return response;
    } catch (e) {
      state = state.copyWith(
        isTranslating: false,
        activeWarning: () => "Translation Error: ${e.toString()}",
      );
      return null;
    }
  }

  void captureSignature(String name) {
    state = state.copyWith(
      isSignatureCaptured: true,
      requiresSignature: false, // Resolve the gating override
      capturedSignatureName: () => name,
    );
  }

  void clearWarning() {
    state = state.copyWith(
      activeWarning: () => null,
      requiresSignature: false,
    );
  }

  Future<void> startListening(MicDirection direction) async {
    if (state.isListening) return;

    final stt = _ref.read(onDeviceSttServiceProvider);
    final sourceIso = direction == MicDirection.oneToTwo ? state.languageOneIso : state.languageTwoIso;

    final failure = await stt.startListening(sourceIso);
    if (failure != null) {
      state = state.copyWith(
        activeWarning: () => _onDeviceSttFailureMessage(failure.failureReason),
      );
      return;
    }
    state = state.copyWith(isListening: true, activeMicDirection: () => direction);
  }

  Future<void> stopListening() async {
    if (!state.isListening) return;
    final direction = state.activeMicDirection;
    state = state.copyWith(isListening: false, activeMicDirection: () => null);
    if (direction == null) return;

    final stt = _ref.read(onDeviceSttServiceProvider);
    state = state.copyWith(isTranslating: true);
    try {
      final sttResult = await stt.stopListening();
      if (sttResult.text == null) {
        state = state.copyWith(
          activeWarning: () => _onDeviceSttFailureMessage(sttResult.failureReason),
        );
        return;
      }

      final sourceIso = direction == MicDirection.oneToTwo ? state.languageOneIso : state.languageTwoIso;
      final targetIso = direction == MicDirection.oneToTwo ? state.languageTwoIso : state.languageOneIso;

      // translateMessage manages its own isTranslating around the TTT step;
      // isTranslating is already true here, so its internal re-set is a
      // harmless no-op to the same value.
      final response = await translateMessage(sttResult.text!, sourceIso: sourceIso, targetIso: targetIso, isMe: true);
      if (response == null) return; // translateMessage already set an activeWarning

      final ttsService = _ref.read(ttsServiceProvider);
      final spoke = await ttsService.speak(
        response.translatedText,
        voice: targetIso,
      );
      if (!spoke) {
        state = state.copyWith(
          activeWarning: () =>
              "Translation succeeded but speech playback failed. Text is shown above.",
        );
        return;
      }
    } catch (e) {
      state = state.copyWith(
        activeWarning: () => "Voice pipeline error: ${e.toString()}",
      );
    } finally {
      state = state.copyWith(isTranslating: false);
    }
  }

  String _onDeviceSttFailureMessage(OnDeviceSttFailureReason? reason) {
    switch (reason) {
      case OnDeviceSttFailureReason.unavailable:
        return 'Speech recognition is unavailable on this device — check microphone permission in system settings, or use typed input instead.';
      case OnDeviceSttFailureReason.unsupportedLanguage:
        return "This language isn't supported by your device's speech recognizer yet — use typed input instead.";
      case OnDeviceSttFailureReason.noSpeechDetected:
        return 'No speech detected — try speaking closer to the mic.';
      default:
        return 'Voice transcription failed.';
    }
  }

  void toggleOnlineMode() {
    state = state.copyWith(isOnlineMode: !state.isOnlineMode);
  }

  void clearHistory() {
    state = ConversationState(
      languageOneIso: state.languageOneIso,
      languageTwoIso: state.languageTwoIso,
      isOnlineMode: state.isOnlineMode,
    );
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier(ref);
});
