import '../../domain/dtos/dot_payload_dto.dart';
import '../../domain/dtos/dot_write_chunk_dto.dart';
import '../datasources/linguistics_memory_alpha.dart';
import '../datasources/real_dot_knowledge.dart';

class DotIndexQueryManager {
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
    // per-language card (182 of 188 picker languages, WALS-derived) ->
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

    // 6. Construct final contents
    final sourceContentBuffer = StringBuffer()
      ..writeln(sourceGrammar);
    if (sourceMatchedVocab.isNotEmpty) {
      sourceContentBuffer.writeln('\nMatched Sliced Vocabulary:');
      for (final vocab in sourceMatchedVocab) {
        sourceContentBuffer.writeln('- $vocab');
      }
    }

    final targetContentBuffer = StringBuffer()
      ..writeln(targetGrammar);
    if (targetMatchedVocab.isNotEmpty) {
      targetContentBuffer.writeln('\nMatched Sliced Vocabulary:');
      for (final vocab in targetMatchedVocab) {
        targetContentBuffer.writeln('- $vocab');
      }
    }

    // 7. Check high-stakes hazards
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
