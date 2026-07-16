import 'package:flutter/foundation.dart';
import '../../domain/dtos/dot_write_chunk_dto.dart';
import '../../domain/interfaces/i_mesh_coordinator.dart';

class NoOpMeshCoordinator implements IMeshCoordinator {
  @override
  final ValueNotifier<Map<String, dynamic>> meshTocNotifier =
      ValueNotifier<Map<String, dynamic>>({});

  @override
  Future<void> initializeMesh() async {
    // Scaffolded no-op setup
    meshTocNotifier.value = {
      'state_cards.lang.yag': 'READ_WRITE',
      'state_cards.lang.eng': 'READ_WRITE',
    };
  }

  @override
  Future<bool> acquireLock(String nodeTargetId) async {
    // No-op: instantly acquires the lock locally
    final current = Map<String, dynamic>.from(meshTocNotifier.value);
    current['state_$nodeTargetId'] = 'READ_ONLY';
    meshTocNotifier.value = current;
    return true;
  }

  @override
  Future<void> releaseAndSync(String nodeTargetId, DotWriteChunkDto chunk) async {
    // No-op: immediately releases the lock locally
    final current = Map<String, dynamic>.from(meshTocNotifier.value);
    current['state_$nodeTargetId'] = 'READ_WRITE';
    meshTocNotifier.value = current;
    debugPrint("MeshSync No-Op: Locally applied chunk ${chunk.chunkId} to $nodeTargetId");
  }

  @override
  Future<void> dispose() async {
    meshTocNotifier.dispose();
  }
}
