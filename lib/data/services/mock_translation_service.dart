import 'dart:async';
import '../../domain/dtos/translation_dto.dart';
import '../../domain/dtos/dot_payload_dto.dart';
import '../../domain/interfaces/i_translation_service.dart';

class MockTranslationService implements ITranslationService {
  @override
  Future<TranslationResponseDto> translateText(
    String text,
    DotPayloadDto context,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final normalized = text.toLowerCase();
    String translated = "Translated: $text";
    double score = 0.95;
    String tier = 'CLEAN';
    List<String> flags = [];
    List<String> warnings = [];

    // Rig some high-stakes triggers for mock testing
    if (normalized.contains('hospital') || normalized.contains('doctor') || normalized.contains('medicine')) {
      translated = "[MEDICAL SHIELD ACTIVE] $translated";
      score = 0.78;
      tier = 'FLAG_FOR_REVIEW';
      flags.add('MEDICAL_DOMAIN');
      warnings.add('High-risk medical terminology detected. Real-time consensus verification required.');
    } else if (normalized.contains('court') || normalized.contains('lawyer') || normalized.contains('arrest')) {
      translated = "[LEGAL SHIELD ACTIVE] $translated";
      score = 0.82;
      tier = 'FLAG_FOR_REVIEW';
      flags.add('LEGAL_DOMAIN');
      warnings.add('Legal domain terms matched. In-context liability signature required.');
    }

    return TranslationResponseDto(
      sourceText: text,
      translatedText: translated,
      confidenceScore: score,
      confidenceTier: tier,
      appliedFlags: flags,
      warningTokens: warnings,
    );
  }
}
