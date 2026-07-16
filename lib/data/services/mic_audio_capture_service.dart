import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MicAudioCaptureService {
  final AudioRecorder _recorder = AudioRecorder();

  static const int _sampleRate = 16000;
  static const int _numChannels = 1;
  static const int _bitsPerSample = 16;

  Future<bool> hasPermission() async {
    // Check both permission_handler's view and record's own internal check —
    // the two plugins query the platform independently and can briefly
    // disagree right after a permission prompt is answered, which was
    // silently closing the capture stream immediately after it opened.
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final requested = await Permission.microphone.request();
      if (!requested.isGranted) {
        debugPrint('[mic] permission_handler denied microphone access');
        return false;
      }
    }
    final recordSeesPermission = await _recorder.hasPermission();
    if (!recordSeesPermission) {
      debugPrint('[mic] record plugin still reports no permission after grant');
    }
    return recordSeesPermission;
  }

  Future<Stream<List<int>>> startCapture() async {
    // 16kHz mono PCM16 — a sample rate every Android device's audio HAL
    // supports natively, unlike 24kHz which some hardware silently fails
    // to open at, closing the stream almost immediately after it starts.
    const config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );
    final stream = await _recorder.startStream(config);
    return stream.map((chunk) {
      debugPrint('[mic] chunk received: ${chunk.length} bytes');
      return chunk;
    });
  }

  Future<void> stopCapture() async {
    await _recorder.stop();
  }

  void dispose() {
    _recorder.dispose();
  }

  /// Wraps headerless PCM16 mono 16kHz bytes (as produced by startCapture())
  /// in a canonical 44-byte WAV header so OpenAI's transcription endpoint
  /// (which requires a real audio container, not raw PCM) can parse it.
  static Uint8List wrapPcmAsWav(Uint8List pcmBytes) {
    final byteRate = _sampleRate * _numChannels * (_bitsPerSample ~/ 8);
    final blockAlign = _numChannels * (_bitsPerSample ~/ 8);
    final dataSize = pcmBytes.length;
    final chunkSize = 36 + dataSize;

    final header = BytesBuilder();
    header.add(ascii.encode('RIFF'));
    header.add(_uint32le(chunkSize));
    header.add(ascii.encode('WAVE'));

    header.add(ascii.encode('fmt '));
    header.add(_uint32le(16)); // Subchunk1Size (16 for PCM)
    header.add(_uint16le(1)); // AudioFormat = 1 (PCM)
    header.add(_uint16le(_numChannels));
    header.add(_uint32le(_sampleRate));
    header.add(_uint32le(byteRate));
    header.add(_uint16le(blockAlign));
    header.add(_uint16le(_bitsPerSample));

    header.add(ascii.encode('data'));
    header.add(_uint32le(dataSize));

    final result = BytesBuilder();
    result.add(header.toBytes());
    result.add(pcmBytes);
    return result.toBytes();
  }

  static Uint8List _uint16le(int v) => Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little);

  static Uint8List _uint32le(int v) => Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little);
}
