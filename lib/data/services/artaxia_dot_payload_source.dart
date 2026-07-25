import 'package:kilonova_ondevice/kilonova_ondevice.dart' as artaxia;
import '../../domain/interfaces/i_dot_repository.dart';
import '../../domain/dtos/dot_payload_dto.dart' as soutuk;

/// Adapts Soutuk's real [IDotRepository] (backed by
/// [DotIndexQueryManager.sliceActivePayload] — vocabulary token-matching,
/// hazard-term detection, custom-chunk merging) to Artaxia's
/// [artaxia.DotPayloadSource]. The two DTOs are field-for-field identical by
/// design (see kilonova_ondevice's dot.dart doc comment), so this is a
/// straight copy, not a real translation.
class ArtaxiaDotPayloadSource implements artaxia.DotPayloadSource {
  final IDotRepository _repo;

  ArtaxiaDotPayloadSource(this._repo);

  @override
  Future<artaxia.DotPayload> loadActivePayload(
    String sourceIso,
    String targetIso, [
    String queryText = '',
  ]) async {
    final dto = await _repo.loadActivePayload(sourceIso, targetIso, queryText);
    return artaxia.DotPayload(
      sourceLanguageIso: dto.sourceLanguageIso,
      targetLanguageIso: dto.targetLanguageIso,
      sourceCard: _toArtaxiaCard(dto.sourceCard),
      targetCard: _toArtaxiaCard(dto.targetCard),
      hazardCard: dto.hazardCard == null ? null : _toArtaxiaCard(dto.hazardCard!),
    );
  }

  artaxia.DotCard _toArtaxiaCard(soutuk.DotCard card) {
    return artaxia.DotCard(
      cardId: card.cardId,
      languageIso: card.languageIso,
      content: card.content,
    );
  }
}
