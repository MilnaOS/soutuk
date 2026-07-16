// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_crib_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscoveryCribDtoImpl _$$DiscoveryCribDtoImplFromJson(
  Map<String, dynamic> json,
) => _$DiscoveryCribDtoImpl(
  symbolId: json['symbolId'] as String,
  pictogramUrl: json['pictogramUrl'] as String,
  targetSentenceNorm: json['targetSentenceNorm'] as String,
  elicitedAudioPath: json['elicitedAudioPath'] as String?,
  transcribedPhonemes: json['transcribedPhonemes'] as String?,
  inferredWordBoundaries:
      (json['inferredWordBoundaries'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$DiscoveryCribDtoImplToJson(
  _$DiscoveryCribDtoImpl instance,
) => <String, dynamic>{
  'symbolId': instance.symbolId,
  'pictogramUrl': instance.pictogramUrl,
  'targetSentenceNorm': instance.targetSentenceNorm,
  'elicitedAudioPath': instance.elicitedAudioPath,
  'transcribedPhonemes': instance.transcribedPhonemes,
  'inferredWordBoundaries': instance.inferredWordBoundaries,
};
