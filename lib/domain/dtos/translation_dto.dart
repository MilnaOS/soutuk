import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_dto.freezed.dart';
part 'translation_dto.g.dart';

@freezed
class TranslationResponseDto with _$TranslationResponseDto {
  const factory TranslationResponseDto({
    required String sourceText,
    required String translatedText,
    required double confidenceScore,
    required String confidenceTier, // 'CLEAN' | 'UNCERTAIN' | 'FLAG_FOR_REVIEW'
    @Default([]) List<String> appliedFlags,
    @Default([]) List<String> warningTokens,
  }) = _TranslationResponseDto;

  factory TranslationResponseDto.fromJson(Map<String, dynamic> json) => _$TranslationResponseDtoFromJson(json);
}
