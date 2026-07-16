import 'package:freezed_annotation/freezed_annotation.dart';

part 'dot_payload_dto.freezed.dart';
part 'dot_payload_dto.g.dart';

@freezed
class DotCard with _$DotCard {
  const DotCard._();

  const factory DotCard({
    required String cardId,
    required String languageIso,
    required String content,
  }) = _DotCard;

  factory DotCard.fromJson(Map<String, dynamic> json) => _$DotCardFromJson(json);
}

@freezed
class DotPayloadDto with _$DotPayloadDto {
  const factory DotPayloadDto({
    required String sourceLanguageIso,
    required String targetLanguageIso,
    required DotCard sourceCard,
    required DotCard targetCard,
    DotCard? hazardCard,
  }) = _DotPayloadDto;

  factory DotPayloadDto.fromJson(Map<String, dynamic> json) => _$DotPayloadDtoFromJson(json);
}
