import 'dart:io';

/// Replacement for llm_llamacpp's `LlamaCppRepository`/`DownloadProgress`
/// (2026-07-20) — llm_llamacpp was removed as a dependency for the
/// llama_cpp_dart spike (native lib collision, see
/// on_device_model_registry.dart), but its HuggingFace downloader was the
/// only piece of it still needed. Plain streamed HTTP GET against
/// HuggingFace's public `resolve/main` endpoint — no auth needed for
/// public repos, `HttpClient` follows the CDN redirect automatically.
class DownloadProgress {
  final double progress; // 0.0-1.0
  const DownloadProgress(this.progress);
}

class HfModelDownloader {
  Stream<DownloadProgress> downloadModel(
    String repoId,
    String filename,
    String destDir,
  ) async* {
    final uri = Uri.parse(
      'https://huggingface.co/$repoId/resolve/main/$filename',
    );
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException(
          'Model download failed: HTTP ${response.statusCode} for $uri',
        );
      }
      final total = response.contentLength;
      final file = File('$destDir/$filename');
      final sink = file.openWrite();
      var received = 0;
      try {
        await for (final chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) {
            yield DownloadProgress(received / total);
          }
        }
      } finally {
        await sink.close();
      }
      if (total <= 0) {
        yield const DownloadProgress(1.0);
      }
    } finally {
      client.close();
    }
  }

  void dispose() {}
}
