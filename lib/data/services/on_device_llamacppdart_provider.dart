import 'dart:io';

import 'package:kilonova_ondevice/kilonova_ondevice.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart' as lcd;

/// Spike provider (2026-07-20) wrapping `llama_cpp_dart` 0.9.0-dev.9 instead
/// of `llm_llamacpp`. Real motivation: `llm_llamacpp`'s six patched bugs
/// never touched its two deepest architectural problems (singleton isolate,
/// full model reload per call) — this package solves both by design (real
/// off-thread worker isolate per `LlamaEngine`, persistent model+context via
/// `EngineSession`), plus auto-detects each model's own GGUF chat template
/// (`ChatTemplate.fromModel`/`engine.modelChatTemplate`) instead of the
/// null-pointer bug we hand-patched, and exposes a real repeat-penalty field
/// on `SamplerParams` (llm_llamacpp's primary streaming entry point had
/// none). See memory `artaxia_llamacpp_binding_path` for the full comparison
/// against `lib_llama_cpp` and why this package won out.
///
/// Not a Flutter plugin — `llama_cpp_dart` is a pure Dart FFI package, so
/// the native `.so` isn't bundled automatically. See
/// `android/app/build.gradle.kts` for the manual AAR wiring.
class OnDeviceLlamaCppDartProvider implements InferenceProvider {
  @override
  final String name;
  final String modelPath;
  final int contextSize;

  OnDeviceLlamaCppDartProvider({
    required this.name,
    required this.modelPath,
    this.contextSize = 4096,
  });

  lcd.LlamaEngine? _engine;
  bool _libraryLoaded = false;

  Future<lcd.LlamaEngine> _ensureEngine() async {
    if (_engine != null) return _engine!;
    if (!_libraryLoaded && Platform.isAndroid) {
      // CPU AAR only for this spike — Hexagon NPU acceleration is marked
      // "pending physical-device validation" upstream, not a safe first step.
      lcd.LlamaLibrary.load(path: 'libllama.so');
      _libraryLoaded = true;
    }
    final engine = await lcd.LlamaEngine.spawn(
      libraryPath: 'libllama.so',
      modelParams: lcd.ModelParams(path: modelPath, gpuLayers: 0),
      contextParams: lcd.ContextParams(
        nCtx: contextSize,
        nBatch: contextSize,
      ),
    );
    _engine = engine;
    return engine;
  }

  @override
  Future<String> complete({
    required String system,
    required List<ChatMessage> messages,
  }) async {
    final engine = await _ensureEngine();

    final lcdMessages = <lcd.ChatMessage>[
      lcd.ChatMessage.system(system),
      ...messages.map(
        (m) => lcd.ChatMessage(role: m.role, content: m.content),
      ),
    ];

    final template = engine.modelChatTemplate;
    if (template == null) {
      throw StateError(
        '[OnDeviceLlamaCppDartProvider:$name] model has no embedded GGUF '
        'chat template — real fallback (builtin template name or hand '
        'rendering) not implemented for this spike.',
      );
    }
    final prompt = lcd.ChatTemplate.apply(
      template: template,
      messages: lcdMessages,
      addAssistant: true,
    );

    final session = await engine.createSession();
    final buffer = StringBuffer();
    try {
      const sampler = lcd.SamplerParams(repeatPenalty: 1.15);
      await for (final event in session.generate(
        prompt: prompt,
        addSpecial: true,
        parseSpecial: true,
        sampler: sampler,
        maxTokens: 512,
      )) {
        switch (event) {
          case lcd.TokenEvent(:final text):
            buffer.write(text);
          case lcd.DoneEvent(:final trailingText):
            if (trailingText.isNotEmpty) buffer.write(trailingText);
          case lcd.ShiftEvent():
            break;
        }
      }
    } finally {
      await session.dispose();
    }

    final result = buffer.toString();
    // ignore: avoid_print
    print(
      '[OnDeviceLlamaCppDartProvider:$name] contextSize=$contextSize '
      'accelerator=${engine.primaryAcceleratorName} output="$result"',
    );
    return result;
  }

  @override
  Future<void> dispose() async {
    await _engine?.dispose();
    _engine = null;
  }
}
