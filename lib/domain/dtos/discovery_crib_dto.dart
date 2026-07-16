import 'package:freezed_annotation/freezed_annotation.dart';

part 'discovery_crib_dto.freezed.dart';
part 'discovery_crib_dto.g.dart';

@freezed
class DiscoveryCribDto with _$DiscoveryCribDto {
  const factory DiscoveryCribDto({
    required String symbolId,
    required String pictogramUrl,
    required String targetSentenceNorm,
    String? elicitedAudioPath,
    String? transcribedPhonemes,
    @Default([]) List<String> inferredWordBoundaries,
  }) = _DiscoveryCribDto;

  factory DiscoveryCribDto.fromJson(Map<String, dynamic> json) => _$DiscoveryCribDtoFromJson(json);
}
