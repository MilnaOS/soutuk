import '../../domain/dtos/dot_payload_dto.dart';
import '../../domain/dtos/dot_write_chunk_dto.dart';
import '../datasources/linguistics_memory_alpha.dart';
import '../datasources/real_dot_knowledge.dart';

class DotIndexQueryManager {
  // Real measurement (2026-07-20) of all 1,216 real DOT language cards
  // (assets/data/dot_language_cards.json): p99 combined source+target card
  // size is ~5,150 chars, and the true worst-case pairing in the dataset
  // (Turkish + Russian, the two largest cards) is ~7,971 chars. This cap
  // sits comfortably above both with real headroom, while still leaving
  // most of the 4096-token context (~14,336 chars minus the 512-token
  // generation budget) free for task/source-text/chat-template overhead.
  // Indexing already ensures everything included is genuinely relevant —
  // this only guards against the rare case where relevant content still
  // adds up to more than the model's context can hold. See memory
  // artaxia_llamacpp_binding_path.
  static const int _combinedCardCharBudget = 9000;

  // Store custom vocabulary chunks injected during Discovery elicitation
  final List<DotWriteChunkDto> _customChunks = [];

  void registerCustomChunk(DotWriteChunkDto chunk) {
    _customChunks.add(chunk);
  }

  void clearCustomChunks() {
    _customChunks.clear();
  }

  DotPayloadDto sliceActivePayload(
    String text,
    String sourceIso,
    String targetIso,
  ) {
    // 1. Tokenize query text to find matches
    final normalizedText = text.toLowerCase();
    final tokens = normalizedText.split(RegExp(r'[^a-zA-Z\u00C0-\u017F\u0250-\u02AF\[\]\(\)\?]+')).where((t) => t.isNotEmpty).toSet();

    // 2. Fetch grammar/hazard reference content. Priority: real blade-sourced
    // per-language card (183 of 189 picker languages, WALS-derived) ->
    // hand-written stub (covers ancient/liturgical languages WALS doesn't
    // catalog, e.g. Latin, Classical Greek) -> generic default. The generic
    // default should be unreachable now that languages with neither a card
    // nor a stub were removed from the picker (dot_pending_languages.json).
    final sourceGrammar = RealDotKnowledge.languageCard(sourceIso) ??
        LinguisticsMemoryAlpha.grammarRules[sourceIso] ??
        'SVO structure, standard morphological constraints.';
    final targetGrammar = RealDotKnowledge.languageCard(targetIso) ??
        LinguisticsMemoryAlpha.grammarRules[targetIso] ??
        'SVO structure, standard morphological constraints.';

    // 3. Slice matching vocabulary cards for source
    final sourceMatchedVocab = <String>[];
    final sourceVocabRules = LinguisticsMemoryAlpha.vocabularyRules[sourceIso];
    if (sourceVocabRules != null) {
      for (final entry in sourceVocabRules.entries) {
        if (tokens.contains(entry.key.toLowerCase())) {
          sourceMatchedVocab.add(entry.value);
        }
      }
    }

    // 4. Slice matching vocabulary cards for target
    final targetMatchedVocab = <String>[];
    final targetVocabRules = LinguisticsMemoryAlpha.vocabularyRules[targetIso];
    if (targetVocabRules != null) {
      final engVocabRules = LinguisticsMemoryAlpha.vocabularyRules['eng'];
      for (final entry in targetVocabRules.entries) {
        final keyLower = entry.key.toLowerCase();
        bool isMatch = tokens.contains(keyLower);
        if (!isMatch && engVocabRules != null) {
          for (final engEntry in engVocabRules.entries) {
            if (engEntry.key.toLowerCase() == keyLower && tokens.contains(engEntry.key.toLowerCase())) {
              isMatch = true;
              break;
            }
          }
        }
        if (isMatch) {
          targetMatchedVocab.add(entry.value);
        }
      }
    }

    // 5. MERGE DYNAMIC DISCOVERED VOCABULARY CARDS (Turing discovery injection loop)
    for (final chunk in _customChunks) {
      final data = chunk.deltaContent;
      final chunkLang = (data['languageIso'] as String?)?.toLowerCase();
      final concept = (data['concept'] as String?)?.toLowerCase();
      final translation = data['translation'] as String?;

      if (chunkLang == null || concept == null || translation == null) continue;

      // Check if the query tokens contain the English concept (e.g., "sun", "water")
      if (tokens.contains(concept)) {
        if (chunkLang == sourceIso.toLowerCase()) {
          sourceMatchedVocab.add("[DISCOVERED] $concept -> $translation");
        }
        if (chunkLang == targetIso.toLowerCase()) {
          targetMatchedVocab.add("[DISCOVERED] $concept -> $translation");
        }
      }
    }

    // 6. Trim safeguard: indexing already guarantees everything matched is
    // genuinely relevant, but relevance doesn't bound size — a dense
    // language pair's cards plus many vocabulary matches can still add up
    // to more than the model's context can hold (see _combinedCardCharBudget
    // doc comment). Drop matched vocabulary first (lowest priority, purely
    // additive) since the grammar cards are the stable baseline every turn
    // needs; only truncate the grammar cards themselves in the rare case
    // where they alone exceed budget.
    var effectiveSourceGrammar = sourceGrammar;
    var effectiveTargetGrammar = targetGrammar;
    final trimmedSourceVocab = List<String>.from(sourceMatchedVocab);
    final trimmedTargetVocab = List<String>.from(targetMatchedVocab);

    int currentTotal() =>
        effectiveSourceGrammar.length +
        effectiveTargetGrammar.length +
        trimmedSourceVocab.fold<int>(0, (sum, v) => sum + v.length) +
        trimmedTargetVocab.fold<int>(0, (sum, v) => sum + v.length);

    // Drop vocab entries alternately from whichever side is currently
    // larger, least-relevant-last-added first, until under budget or out
    // of vocab to drop.
    while (currentTotal() > _combinedCardCharBudget &&
        (trimmedSourceVocab.isNotEmpty || trimmedTargetVocab.isNotEmpty)) {
      if (trimmedSourceVocab.length >= trimmedTargetVocab.length &&
          trimmedSourceVocab.isNotEmpty) {
        trimmedSourceVocab.removeLast();
      } else if (trimmedTargetVocab.isNotEmpty) {
        trimmedTargetVocab.removeLast();
      }
    }

    // Rare fallback: even the bare grammar cards (no vocab at all) exceed
    // budget — truncate proportionally with a clear marker rather than let
    // the prompt silently blow the context window.
    if (currentTotal() > _combinedCardCharBudget) {
      final grammarBudget = (_combinedCardCharBudget / 2).floor();
      if (effectiveSourceGrammar.length > grammarBudget) {
        effectiveSourceGrammar =
            '${effectiveSourceGrammar.substring(0, grammarBudget)}\n[...truncated: card exceeded context budget...]';
      }
      if (effectiveTargetGrammar.length > grammarBudget) {
        effectiveTargetGrammar =
            '${effectiveTargetGrammar.substring(0, grammarBudget)}\n[...truncated: card exceeded context budget...]';
      }
    }

    // 7. Construct final contents
    final sourceContentBuffer = StringBuffer()
      ..writeln(effectiveSourceGrammar);
    if (trimmedSourceVocab.isNotEmpty) {
      sourceContentBuffer.writeln('\nMatched Sliced Vocabulary:');
      for (final vocab in trimmedSourceVocab) {
        sourceContentBuffer.writeln('- $vocab');
      }
    }

    final targetContentBuffer = StringBuffer()
      ..writeln(effectiveTargetGrammar);
    if (trimmedTargetVocab.isNotEmpty) {
      targetContentBuffer.writeln('\nMatched Sliced Vocabulary:');
      for (final vocab in trimmedTargetVocab) {
        targetContentBuffer.writeln('- $vocab');
      }
    }

    // 8. Check high-stakes hazards
    String hazardContent = 'No active safety hazard rules triggered for this context.';
    bool isHazardTriggered = false;

    final medicalTerms = {'hospital', 'doctor', 'medicine', 'physician', 'clinic', 'médico', 'medicina', 'clínica', 'hôpital', 'médecin', 'médicament', 'valetudinarium', 'iatros', 'pharmakon', 'swnw', 'pr-ankh', 'dayana', 'dayano'};
    final legalTerms = {'court', 'lawyer', 'arrest', 'prison', 'judge', 'tribunal', 'abogado', 'arrestar', 'prisión', 'juez', 'avocat', 'arrestation', 'patronus', 'advocatus', 'carcer', 'iudex', 'dikasterion', 'synegoros', 'desmoterion', 'dikastes', 'bema', 'hwt-wrt', 'hnrt'};

    final hasMedical = tokens.any((t) => medicalTerms.contains(t));
    final hasLegal = tokens.any((t) => legalTerms.contains(t));

    if (hasMedical || hasLegal) {
      isHazardTriggered = true;
      final hazardsList = <String>[];
      if (hasMedical) {
        hazardsList.add(LinguisticsMemoryAlpha.highStakesWarnings['MEDICAL_DOMAIN']!);
      }
      if (hasLegal) {
        hazardsList.add(LinguisticsMemoryAlpha.highStakesWarnings['LEGAL_DOMAIN']!);
      }
      hazardContent = hazardsList.join('\n');
    }

    return DotPayloadDto(
      sourceLanguageIso: sourceIso,
      targetLanguageIso: targetIso,
      sourceCard: DotCard(
        cardId: 'card_source_$sourceIso',
        languageIso: sourceIso,
        content: sourceContentBuffer.toString().trim(),
      ),
      targetCard: DotCard(
        cardId: 'card_target_$targetIso',
        languageIso: targetIso,
        content: targetContentBuffer.toString().trim(),
      ),
      hazardCard: isHazardTriggered
          ? DotCard(
              cardId: 'hazard_card_sliced',
              languageIso: 'ALL',
              content: hazardContent,
            )
          : null,
    );
  }
}
