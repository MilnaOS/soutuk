// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_identification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LanguageIdentificationDtoImpl _$$LanguageIdentificationDtoImplFromJson(
  Map<String, dynamic> json,
) => _$LanguageIdentificationDtoImpl(
  detectedIso: json['detectedIso'] as String?,
  detectedName: json['detectedName'] as String?,
  confidence: (json['confidence'] as num).toDouble(),
  sufficientSample: json['sufficientSample'] as bool,
  reasoning: json['reasoning'] as String? ?? '',
);

Map<String, dynamic> _$$LanguageIdentificationDtoImplToJson(
  _$LanguageIdentificationDtoImpl instance,
) => <String, dynamic>{
  'detectedIso': instance.detectedIso,
  'detectedName': instance.detectedName,
  'confidence': instance.confidence,
  'sufficientSample': instance.sufficientSample,
  'reasoning': instance.reasoning,
};
