// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TranslationResponseDtoImpl _$$TranslationResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$TranslationResponseDtoImpl(
  sourceText: json['sourceText'] as String,
  translatedText: json['translatedText'] as String,
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  confidenceTier: json['confidenceTier'] as String,
  appliedFlags:
      (json['appliedFlags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  warningTokens:
      (json['warningTokens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$TranslationResponseDtoImplToJson(
  _$TranslationResponseDtoImpl instance,
) => <String, dynamic>{
  'sourceText': instance.sourceText,
  'translatedText': instance.translatedText,
  'confidenceScore': instance.confidenceScore,
  'confidenceTier': instance.confidenceTier,
  'appliedFlags': instance.appliedFlags,
  'warningTokens': instance.warningTokens,
};
