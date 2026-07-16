import '../../domain/dtos/dot_payload_dto.dart';
import '../../domain/dtos/dot_write_chunk_dto.dart';
import '../../domain/interfaces/i_dot_repository.dart';
import '../datasources/real_dot_knowledge.dart';
import '../services/dot_index_query_manager.dart';

class DotRepository implements IDotRepository {
  final Map<String, dynamic> _localDatabase = {};
  final DotIndexQueryManager _queryManager = DotIndexQueryManager();

  DotIndexQueryManager get queryManager => _queryManager;

  @override
  Future<DotPayloadDto> loadActivePayload(String sourceIso, String targetIso, [String queryText = '']) async {
    await RealDotKnowledge.ensureLoaded();
    return _queryManager.sliceActivePayload(queryText, sourceIso, targetIso);
  }

  @override
  Future<void> appendLocalChunk(DotWriteChunkDto chunk) async {
    _localDatabase[chunk.nodeTargetId] = chunk.deltaContent;
    _queryManager.registerCustomChunk(chunk);
  }
}
