// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dot_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DotCardImpl _$$DotCardImplFromJson(Map<String, dynamic> json) =>
    _$DotCardImpl(
      cardId: json['cardId'] as String,
      languageIso: json['languageIso'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$$DotCardImplToJson(_$DotCardImpl instance) =>
    <String, dynamic>{
      'cardId': instance.cardId,
      'languageIso': instance.languageIso,
      'content': instance.content,
    };

_$DotPayloadDtoImpl _$$DotPayloadDtoImplFromJson(Map<String, dynamic> json) =>
    _$DotPayloadDtoImpl(
      sourceLanguageIso: json['sourceLanguageIso'] as String,
      targetLanguageIso: json['targetLanguageIso'] as String,
      sourceCard: DotCard.fromJson(json['sourceCard'] as Map<String, dynamic>),
      targetCard: DotCard.fromJson(json['targetCard'] as Map<String, dynamic>),
      hazardCard: json['hazardCard'] == null
          ? null
          : DotCard.fromJson(json['hazardCard'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DotPayloadDtoImplToJson(_$DotPayloadDtoImpl instance) =>
    <String, dynamic>{
      'sourceLanguageIso': instance.sourceLanguageIso,
      'targetLanguageIso': instance.targetLanguageIso,
      'sourceCard': instance.sourceCard,
      'targetCard': instance.targetCard,
      'hazardCard': instance.hazardCard,
    };
