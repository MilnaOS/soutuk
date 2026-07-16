import 'package:flutter/foundation.dart';
import '../dtos/dot_write_chunk_dto.dart';

abstract class IMeshCoordinator {
  ValueNotifier<Map<String, dynamic>> get meshTocNotifier;

  Future<void> initializeMesh();

  Future<bool> acquireLock(String nodeTargetId);

  Future<void> releaseAndSync(String nodeTargetId, DotWriteChunkDto chunk);

  Future<void> dispose();
}
