import 'package:kilonova_ondevice/kilonova_ondevice.dart' as artaxia;
import '../../domain/dtos/translation_dto.dart';
import '../../domain/dtos/dot_payload_dto.dart';
import '../../domain/interfaces/i_translation_service.dart';
import 'artaxia_dot_payload_source.dart';
import 'on_device_model_registry.dart';

/// Real on-device translation backend — the actual "Milna OS: Artaxia"
/// path: two independent translators
/// (Qwen2.5-1.5B, DeepSeek-R1-Distill-1.5B) attempt the same translation,
/// Granite4.1:3b arbitrates between them, all grounded by Soutuk's real
/// DOT grammar cards via [ArtaxiaDotPayloadSource]. No network call, no
/// API key.
///
/// Deliberately waits for the full arbitrated verdict before returning
/// (ArtaxiaEngine's fast-path-now/arbitrate-later split is designed for a
/// streaming UI this app doesn't have yet — ITranslationService is a
/// single-shot Future, so there's no fast path to show early here).
class ArtaxiaTranslationService implements ITranslationService {
  final ArtaxiaDotPayloadSource _dotSource;
  final OnDeviceModelRegistry _modelRegistry;
  artaxia.ArtaxiaEngine? _engine;

  ArtaxiaTranslationService(this._dotSource, this._modelRegistry);

  Future<artaxia.ArtaxiaEngine> _ensureEngine() async {
    if (_engine != null) return _engine!;
    final registry = await _modelRegistry.buildRegistry();
    if (registry == null) {
      throw StateError(
        'On-device models are not downloaded yet. Download them from '
        'Settings before using offline translation.',
      );
    }
    _engine = artaxia.ArtaxiaEngine(
      registry: registry,
      notebook: artaxia.ArbitrationNotebook(),
      dotSource: _dotSource,
    );
    return _engine!;
  }

  @override
  Future<TranslationResponseDto> translateText(
    String text,
    DotPayloadDto context,
  ) async {
    final engine = await _ensureEngine();
    final turnId = 'artaxia_${DateTime.now().microsecondsSinceEpoch}';

    final turn = await engine.translate(
      turnId: turnId,
      sourceText: text,
      sourceLanguageIso: context.sourceLanguageIso,
      targetLanguageIso: context.targetLanguageIso,
    );
    final verdict = await turn.verdict;

    return TranslationResponseDto(
      sourceText: text,
      translatedText: verdict.bestTranslation,
      confidenceScore: verdict.confidenceScore,
      confidenceTier: verdict.agree ? 'CLEAN' : 'UNCERTAIN',
      appliedFlags: verdict.agree ? const [] : const ['TRANSLATION_DISAGREEMENT'],
      warningTokens: verdict.agree ? const [] : [verdict.reasoning],
    );
  }
}
