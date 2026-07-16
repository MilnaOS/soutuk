import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/dtos/discovery_crib_dto.dart';
import '../../domain/dtos/dot_write_chunk_dto.dart';
import 'translation_providers.dart';

// ==========================================
// 1. Discovery Session Models
// ==========================================

class DiscoveryCribItem {
  final String symbolId;
  final String title;
  final String emoji;
  final String referencePrompt; // What the TTS says
  final String englishConcept;

  const DiscoveryCribItem({
    required this.symbolId,
    required this.title,
    required this.emoji,
    required this.referencePrompt,
    required this.englishConcept,
  });
}

class DiscoveryState {
  final List<DiscoveryCribItem> cribs;
  final int currentIndex;
  final String targetLanguageName;
  final String targetLanguageIso;
  final bool isSessionActive;
  final bool isPrompting; // True when TTS is "speaking" prompt aloud
  final bool isListening; // True when passive mic is hot, listening for speech
  final String? activePromptText; // Current text spoken by TTS
  final DiscoveryCribDto? lastCapturedCrib;
  final Set<String> flaggedSymbolIds; // Symbol IDs explicitly rejected by interviewer
  final List<DiscoveryCribDto> sessionHistory;

  DiscoveryState({
    required this.cribs,
    this.currentIndex = 0,
    this.targetLanguageName = 'Mayan',
    this.targetLanguageIso = 'myn',
    this.isSessionActive = false,
    this.isPrompting = false,
    this.isListening = false,
    this.activePromptText,
    this.lastCapturedCrib,
    this.flaggedSymbolIds = const {},
    this.sessionHistory = const [],
  });

  DiscoveryCribItem get currentCribItem => cribs[currentIndex];

  DiscoveryState copyWith({
    List<DiscoveryCribItem>? cribs,
    int? currentIndex,
    String? targetLanguageName,
    String? targetLanguageIso,
    bool? isSessionActive,
    bool? isPrompting,
    bool? isListening,
    String? Function()? activePromptText,
    DiscoveryCribDto? Function()? lastCapturedCrib,
    Set<String>? flaggedSymbolIds,
    List<DiscoveryCribDto>? sessionHistory,
  }) {
    return DiscoveryState(
      cribs: cribs ?? this.cribs,
      currentIndex: currentIndex ?? this.currentIndex,
      targetLanguageName: targetLanguageName ?? this.targetLanguageName,
      targetLanguageIso: targetLanguageIso ?? this.targetLanguageIso,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isPrompting: isPrompting ?? this.isPrompting,
      isListening: isListening ?? this.isListening,
      activePromptText: activePromptText != null ? activePromptText() : this.activePromptText,
      lastCapturedCrib: lastCapturedCrib != null ? lastCapturedCrib() : this.lastCapturedCrib,
      flaggedSymbolIds: flaggedSymbolIds ?? this.flaggedSymbolIds,
      sessionHistory: sessionHistory ?? this.sessionHistory,
    );
  }
}

// ==========================================
// 2. Discovery State Notifier
// ==========================================

class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final Ref _ref;
  Timer? _sessionTimer;

  static const List<DiscoveryCribItem> _defaultCribs = [
    DiscoveryCribItem(
      symbolId: 'SYM_INTRO_SELF',
      title: 'Introduction (Self)',
      emoji: '👤',
      referencePrompt: 'Hello, my name is Soutuk. What is your name?',
      englishConcept: 'self_introduction',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_INTRO_YOU',
      title: 'Introduction (You)',
      emoji: '👥',
      referencePrompt: 'And what is your name?',
      englishConcept: 'you_introduction',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_SUN',
      title: 'The Sun',
      emoji: '☀️',
      referencePrompt: 'The Sun. How do you say Sun?',
      englishConcept: 'sun',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_WATER',
      title: 'Water',
      emoji: '💧',
      referencePrompt: 'Water. How do you say Water?',
      englishConcept: 'water',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_MAN',
      title: 'Man',
      emoji: '👨',
      referencePrompt: 'The Man. How do you say Man?',
      englishConcept: 'man',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_FOOD',
      title: 'Food',
      emoji: '🍎',
      referencePrompt: 'Food. How do you say Food?',
      englishConcept: 'food',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_ANIMAL',
      title: 'Animal',
      emoji: '🐆',
      referencePrompt: 'Animal. How do you say Animal?',
      englishConcept: 'animal',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_FIRE',
      title: 'Fire',
      emoji: '🔥',
      referencePrompt: 'Fire. How do you say Fire?',
      englishConcept: 'fire',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_HAND',
      title: 'Hand',
      emoji: '✋',
      referencePrompt: 'Hand. How do you say Hand?',
      englishConcept: 'hand',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_TREE',
      title: 'Tree',
      emoji: '🌳',
      referencePrompt: 'Tree. How do you say Tree?',
      englishConcept: 'tree',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_MOON',
      title: 'The Moon',
      emoji: '🌙',
      referencePrompt: 'The Moon. How do you say Moon?',
      englishConcept: 'moon',
    ),
    DiscoveryCribItem(
      symbolId: 'SYM_EYE',
      title: 'Eye',
      emoji: '👁️',
      referencePrompt: 'Eye. How do you say Eye?',
      englishConcept: 'eye',
    ),
  ];

  DiscoveryNotifier(this._ref)
      : super(DiscoveryState(cribs: _defaultCribs));

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  void changeTargetLanguage(String name, String iso) {
    if (state.isSessionActive) stopSession();
    state = state.copyWith(
      targetLanguageName: name,
      targetLanguageIso: iso,
    );
  }

  // Starts the fully-passive, hands-free voice-guided elicitation session
  void startSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      currentIndex: 0,
      isSessionActive: true,
      flaggedSymbolIds: {},
      sessionHistory: [],
      lastCapturedCrib: () => null,
    );
    _triggerPromptCycle();
  }

  void stopSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      isSessionActive: false,
      isPrompting: false,
      isListening: false,
      activePromptText: () => null,
    );
  }

  // Moves the session step-by-step automatically
  void _triggerPromptCycle() {
    if (!state.isSessionActive) return;

    final currentItem = state.currentCribItem;

    // 1. TTS Prompt Stage
    state = state.copyWith(
      isPrompting: true,
      isListening: false,
      activePromptText: () => currentItem.referencePrompt,
      lastCapturedCrib: () => null,
    );

    // Simulate speech synthesis speaking delay
    _sessionTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!state.isSessionActive) return;

      // 2. Passive Microphone Listening Stage (Hands-Free)
      state = state.copyWith(
        isPrompting: false,
        isListening: true,
        activePromptText: () => "[Listening for speaker vocalization...]",
      );

      // Simulate native speaker vocalization delay
      _sessionTimer = Timer(const Duration(milliseconds: 3000), () {
        if (!state.isSessionActive) return;
        _compileCurrentElicitation();
      });
    });
  }

  // Dynamic linguistic compilation & pattern boundary analysis
  void _compileCurrentElicitation() {
    final currentItem = state.currentCribItem;
    final iso = state.targetLanguageIso;

    // Generate high-fidelity realistic IPA mappings deterministically
    final ipa = _generatePhoneticIpa(iso, currentItem.symbolId);
    
    // Simple word boundary inference
    final wordBoundaries = ipa.split(RegExp(r'[\s\-]+')).map((w) => w.replaceAll(RegExp(r'[\[\]]'), '')).toList();

    final cribDto = DiscoveryCribDto(
      symbolId: currentItem.symbolId,
      pictogramUrl: currentItem.emoji,
      targetSentenceNorm: currentItem.referencePrompt,
      elicitedAudioPath: "elicitation_${iso}_${currentItem.symbolId}.wav",
      transcribedPhonemes: ipa,
      inferredWordBoundaries: wordBoundaries,
    );

    final isFlagged = state.flaggedSymbolIds.contains(currentItem.symbolId);

    // NOT calling _injectCardLive() here: there is no real microphone capture
    // or STT in this flow yet (isListening is a timer-driven state flag, not
    // real audio), and _generatePhoneticIpa() fabricates a phonetic
    // transcription via a deterministic hash for any language without a
    // hand-written example. Writing that into the real DotRepository would
    // silently contaminate live translation data with invented vocabulary.
    // Re-enable the write-back once this flow captures genuine audio + STT.

    state = state.copyWith(
      isListening: false,
      lastCapturedCrib: () => cribDto,
      sessionHistory: [...state.sessionHistory, cribDto],
      activePromptText: () => isFlagged
          ? "[Override Toggled: Card Flagged & Writing Blocked]"
          : "[DEMO] Simulated capture only — not written to the knowledge base",
    );

    // 3. Auto-progress to next step after a 2-second visual review delay
    _sessionTimer = Timer(const Duration(seconds: 2), () {
      if (!state.isSessionActive) return;

      if (state.currentIndex < state.cribs.length - 1) {
        state = state.copyWith(
          currentIndex: state.currentIndex + 1,
        );
        _triggerPromptCycle();
      } else {
        // Session Complete!
        state = state.copyWith(
          isSessionActive: false,
          activePromptText: () => "Session completed successfully! All cards mapped.",
        );
      }
    });
  }

  // Interviewer Override Flag toggling
  void toggleOverrideFlag() {
    final activeCrib = state.currentCribItem;
    final updatedFlagged = Set<String>.from(state.flaggedSymbolIds);

    if (updatedFlagged.contains(activeCrib.symbolId)) {
      updatedFlagged.remove(activeCrib.symbolId);
    } else {
      updatedFlagged.add(activeCrib.symbolId);
    }

    state = state.copyWith(flaggedSymbolIds: updatedFlagged);
  }

  // Compile & append newly discovered vocabulary card back into active
  // repository. Deliberately unused for now — see the comment in
  // _compileCurrentElicitation() above. Kept, not deleted: this is the real
  // write-back call once genuine audio + STT capture exists for this flow.
  // ignore: unused_element
  void _injectCardLive(DiscoveryCribDto crib, String conceptKey) {
    final repo = _ref.read(dotRepositoryProvider);

    final chunk = DotWriteChunkDto(
      chunkId: "discovered_${state.targetLanguageIso}_${crib.symbolId}",
      nodeTargetId: "discovered_cards",
      deltaContent: {
        "languageIso": state.targetLanguageIso,
        "concept": conceptKey,
        "phonetics": crib.transcribedPhonemes,
        "translation": "${state.targetLanguageName}: ${crib.transcribedPhonemes}",
      },
      timestamp: DateTime.now(),
      sourceConfidence: 0.98,
    );

    repo.appendLocalChunk(chunk);
  }

  // Realistic IPA phonetic dictionary for 153 languages (or deterministic generation)
  String _generatePhoneticIpa(String iso, String symbolId) {
    final normalizedIso = iso.toLowerCase().trim();

    // 1. Precoded real-world cases to ground the linguistic authenticity
    if (normalizedIso == 'myn' || normalizedIso == 'mayan') {
      switch (symbolId) {
        case 'SYM_INTRO_SELF': return '[baːʃ-aː-k’aːbaʔ-neːn-soutuk]';
        case 'SYM_INTRO_YOU': return '[baːʃ-aː-k’aːbaʔ]';
        case 'SYM_SUN': return "[k'iːniʃ]";
        case 'SYM_WATER': return "[haʔ]";
        case 'SYM_MAN': return "[wiːnik]";
        case 'SYM_FOOD': return "[wah]";
        case 'SYM_ANIMAL': return "[baːʔal-k'aːʃ]";
        case 'SYM_FIRE': return "[k'aːk']";
        case 'SYM_HAND': return "[k'ab]";
        case 'SYM_TREE': return "[tʃeʔ]";
        case 'SYM_MOON': return "[uːh]";
        case 'SYM_EYE': return "[itʃ]";
      }
    }

    if (normalizedIso == 'egy' || normalizedIso == 'egyptian') {
      switch (symbolId) {
        case 'SYM_INTRO_SELF': return '[mj-rn-j-soutuk]';
        case 'SYM_INTRO_YOU': return '[tr-rn-k]';
        case 'SYM_SUN': return "[raː]";
        case 'SYM_WATER': return "[muː]";
        case 'SYM_MAN': return "[ziː]";
        case 'SYM_FOOD': return "[t’æf]";
        case 'SYM_ANIMAL': return "[u̯n-m]";
        case 'SYM_FIRE': return "[xɛ́t]";
        case 'SYM_HAND': return "[ɟeːt]";
        case 'SYM_TREE': return "[xt]";
        case 'SYM_MOON': return "[jˁ-ˁx]";
        case 'SYM_EYE': return "[j-r-t]";
      }
    }

    // 2. Safe deterministic generation using phonetic rules based on the ISO and symbolId
    // to provide elegant plausible entries for any of the 153 languages in the system!
    final prefix = normalizedIso.padRight(3).substring(0, 3);
    final int hash = prefix.codeUnitAt(0) + prefix.codeUnitAt(1) + prefix.codeUnitAt(2) + symbolId.hashCode;
    final vowels = ['a', 'e', 'i', 'o', 'u', 'ai', 'ui', 'aa', 'oi'];
    final consonants = ['m', 'n', 't', 'k', 'p', 'l', 's', 'r', 'w', 'h', 'x', 'ts', 'kp'];

    final c1 = consonants[hash % consonants.length];
    final v1 = vowels[(hash ~/ 2) % vowels.length];
    final c2 = consonants[(hash ~/ 3) % consonants.length];
    final v2 = vowels[(hash ~/ 4) % vowels.length];

    if (symbolId.contains('INTRO')) {
      return '[$c1$v1$c2-$v2-$prefix-soutuk]';
    }

    return '[$c1$v1$c2$v2]';
  }
}

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  return DiscoveryNotifier(ref);
});
