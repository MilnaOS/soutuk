import '../dtos/dot_payload_dto.dart';
import '../dtos/dot_write_chunk_dto.dart';

abstract class IDotRepository {
  Future<DotPayloadDto> loadActivePayload(String sourceIso, String targetIso, [String queryText = '']);

  Future<void> appendLocalChunk(DotWriteChunkDto chunk);
}
