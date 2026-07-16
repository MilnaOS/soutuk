// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dot_write_chunk_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DotWriteChunkDtoImpl _$$DotWriteChunkDtoImplFromJson(
  Map<String, dynamic> json,
) => _$DotWriteChunkDtoImpl(
  chunkId: json['chunkId'] as String,
  nodeTargetId: json['nodeTargetId'] as String,
  deltaContent: json['deltaContent'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
  sourceConfidence: (json['sourceConfidence'] as num).toDouble(),
);

Map<String, dynamic> _$$DotWriteChunkDtoImplToJson(
  _$DotWriteChunkDtoImpl instance,
) => <String, dynamic>{
  'chunkId': instance.chunkId,
  'nodeTargetId': instance.nodeTargetId,
  'deltaContent': instance.deltaContent,
  'timestamp': instance.timestamp.toIso8601String(),
  'sourceConfidence': instance.sourceConfidence,
};
