import 'package:freezed_annotation/freezed_annotation.dart';

part 'language_identification_dto.freezed.dart';
part 'language_identification_dto.g.dart';

@freezed
class LanguageIdentificationDto with _$LanguageIdentificationDto {
  const factory LanguageIdentificationDto({
    String? detectedIso,
    String? detectedName,
    required double confidence,
    required bool sufficientSample,
    @Default('') String reasoning,
  }) = _LanguageIdentificationDto;

  factory LanguageIdentificationDto.fromJson(Map<String, dynamic> json) =>
      _$LanguageIdentificationDtoFromJson(json);
}
