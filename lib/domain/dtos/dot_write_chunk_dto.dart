import 'package:freezed_annotation/freezed_annotation.dart';

part 'dot_write_chunk_dto.freezed.dart';
part 'dot_write_chunk_dto.g.dart';

@freezed
class DotWriteChunkDto with _$DotWriteChunkDto {
  const factory DotWriteChunkDto({
    required String chunkId,
    required String nodeTargetId,
    required Map<String, dynamic> deltaContent,
    required DateTime timestamp,
    required double sourceConfidence,
  }) = _DotWriteChunkDto;

  factory DotWriteChunkDto.fromJson(Map<String, dynamic> json) => _$DotWriteChunkDtoFromJson(json);
}
