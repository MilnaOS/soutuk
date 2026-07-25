import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:kilonova_ondevice/kilonova_ondevice.dart';
import 'hf_model_downloader.dart';
import 'on_device_llamacppdart_provider.dart';

/// One entry in the hardwired on-device lineup — a real, verified
/// HuggingFace GGUF repo + filename bound permanently to one Artaxia leg
/// role. Deliberately not user-configurable: Jeremy does not want end users
/// able to swap models or otherwise change Artaxia's architecture, so there
/// is no settings surface for this anywhere in the app — this list is the
/// only place the lineup is defined.
class OnDeviceModelSpec {
  final String legName;
  final LegRole role;
  final String repoId;
  final String filename;
  final int contextSize;

  const OnDeviceModelSpec({
    required this.legName,
    required this.role,
    required this.repoId,
    required this.filename,
    this.contextSize = 4096,
  });
}

/// Combined progress across the whole hardwired lineup, for a single
/// overall progress bar rather than three separate ones.
class ModelDownloadProgress {
  final int modelIndex; // 0-based index of the model currently downloading
  final int modelCount;
  final String legName;
  final double fileProgress; // 0.0-1.0, current file only

  const ModelDownloadProgress({
    required this.modelIndex,
    required this.modelCount,
    required this.legName,
    required this.fileProgress,
  });

  double get overallProgress => (modelIndex + fileProgress) / modelCount;
}

/// Locates (and downloads, if missing) the three hardwired on-device GGUF
/// models, and builds Artaxia's [LegRegistry] from them once all three are
/// present. All three repos/filenames below were verified against their
/// real HuggingFace file listings.
///
/// Q8_0 (8-bit), not fp16/bf16 — switched 2026-07-19 after real on-device
/// testing showed fp16 CPU-only inference genuinely crawling (5+ min of
/// active compute without finishing one leg) and the two full-precision
/// translator weights alone (7.1GB) not fitting the phone's available RAM
/// (~4.2GB free out of ~11.4GB total) at the same time. 8-bit roughly
/// halves both, at a real but much smaller quality cost than 4-bit.
///
/// Context sizes are deliberately generous (8192) across all three legs
/// right now, not tightly tuned — early passes with a smaller context hit
/// real trouble on more than one leg before other bugs (chat template,
/// JSON extraction, UTF-8 token decoding — all since fixed) were found
/// and ruled out as the actual cause. `OnDeviceLlamaProvider` now logs
/// real promptTokens/generatedTokens per call — once a few clean passes
/// are captured under the current (Gemma4-based) lineup, right-size these
/// down from 8192 to whatever's actually needed instead of guessing again.
class OnDeviceModelRegistry {
  // Q4_K_M across all three legs + nCtx 4096 (2026-07-20) — real measurement
  // of all 1,216 DOT language cards (assets/data/dot_language_cards.json)
  // found p99 two-card-sum ~1290 tokens and the true worst-case pairing
  // (tur+rus, the two largest cards in the dataset) ~1990 tokens; 4096
  // comfortably covers that plus the 512-token generation budget with real
  // headroom, versus the old unverified 8192 guess. Real per-model KV cache
  // math (from each model's actual config.json: layers/kv_heads/head_dim)
  // showed the combined resident footprint (weights + KV cache, all three
  // loaded at once under llama_cpp_dart's persistent-engine design) was
  // ~10.2GB at the old Q8_0/Q5_K_M/Q8_0 + 8192 lineup -- Q4_K_M + 4096 cuts
  // that to ~6.63GB combined, and combined with making the arbiter
  // non-persistent (see OnDeviceLlamaCppDartProvider usage in
  // kilonova_ondevice's arbitrate()), translators-only resting state lands
  // at ~4.23GB -- right at the phone's measured ~4.2GB free-RAM ceiling.
  static const List<OnDeviceModelSpec> lineup = [
    OnDeviceModelSpec(
      legName: 'translatorA',
      role: LegRole.translatorA,
      repoId: 'Qwen/Qwen2.5-1.5B-Instruct-GGUF',
      filename: 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
      contextSize: 4096,
    ),
    OnDeviceModelSpec(
      legName: 'translatorB',
      role: LegRole.translatorB,
      // Swapped from Gemma4 on 2026-07-20 — real on-device evidence via
      // llama_cpp_dart's ChatTemplate.apply() threw ChatTemplateException
      // (rc=-1): confirmed via llama.cpp's actual src/llama-chat.cpp source
      // that the low-level llama_chat_apply_template() table this call
      // wraps has no "gemma4" entry at all (only generic "gemma", i.e.
      // Gemma/Gemma2/Gemma3-era). Gemma4's real format is different enough
      // that llama.cpp's own authors gave it a dedicated handler
      // (COMMON_CHAT_FORMAT_PEG_GEMMA4) in the newer common/chat.cpp layer,
      // which llama_cpp_dart doesn't call. Faking the metadata to force a
      // match would silently feed the model a prompt shaped for its
      // predecessor -- the exact silent-wrong-template failure mode fixed
      // in llm_llamacpp earlier tonight, not something to reintroduce.
      // Phi is explicitly recognized ("phi3"/"phi4" in that same table),
      // MIT licensed, non-reasoning instruction-tuned, and a genuinely
      // different architecture family from both translatorA's Qwen2.5 and
      // the arbiter's Granite.
      repoId: 'unsloth/Phi-4-mini-instruct-GGUF',
      filename: 'Phi-4-mini-instruct-Q4_K_M.gguf',
      contextSize: 4096,
    ),
    OnDeviceModelSpec(
      legName: 'arbiter',
      role: LegRole.arbiter,
      repoId: 'ibm-granite/granite-4.1-3b-GGUF',
      filename: 'granite-4.1-3b-Q4_K_M.gguf',
      contextSize: 4096,
    ),
  ];

  Future<Directory> modelsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/models');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<bool> allModelsPresent() async {
    final dir = await modelsDirectory();
    for (final spec in lineup) {
      if (!await File('${dir.path}/${spec.filename}').exists()) return false;
    }
    return true;
  }

  /// Downloads whichever models from [lineup] aren't already on disk.
  /// Already-present files are skipped (checking here avoids opening a
  /// pointless connection). Emits one combined progress stream across all
  /// three files, in lineup order.
  Stream<ModelDownloadProgress> downloadMissingModels() async* {
    final dir = await modelsDirectory();
    final repo = HfModelDownloader();
    try {
      for (var i = 0; i < lineup.length; i++) {
        final spec = lineup[i];
        final file = File('${dir.path}/${spec.filename}');
        if (await file.exists()) {
          yield ModelDownloadProgress(
            modelIndex: i,
            modelCount: lineup.length,
            legName: spec.legName,
            fileProgress: 1.0,
          );
          continue;
        }
        await for (final DownloadProgress p in repo.downloadModel(
          spec.repoId,
          spec.filename,
          dir.path,
        )) {
          yield ModelDownloadProgress(
            modelIndex: i,
            modelCount: lineup.length,
            legName: spec.legName,
            fileProgress: p.progress,
          );
        }
      }
    } finally {
      repo.dispose();
    }
  }

  /// Returns null if any of the three hardwired models are missing — the
  /// v2 lineup needs all three roles present (two translators to disagree
  /// or agree, one arbiter to judge), so a partial set isn't usable.
  Future<LegRegistry?> buildRegistry() async {
    final dir = await modelsDirectory();
    final legs = <Leg>[];
    for (final spec in lineup) {
      final file = File('${dir.path}/${spec.filename}');
      if (!await file.exists()) return null;
      // Spike (2026-07-20): all three legs on llama_cpp_dart, not just
      // translatorA. Originally planned as a mixed lineup (translatorA on
      // llama_cpp_dart, translatorB/arbiter on the patched llm_llamacpp)
      // for a live side-by-side, but the two packages' bundled native
      // libggml-base.so collide at Gradle's native-lib merge step (both
      // ship their own compiled core llama.cpp library at the same
      // jniLibs path, pinned to different upstream versions) -- can't
      // coexist in one APK without risking a silent ABI mismatch. See
      // memory artaxia_llamacpp_binding_path. Comparison against the old
      // llm_llamacpp baseline is now sequential (separate builds), not
      // simultaneous.
      final provider = OnDeviceLlamaCppDartProvider(
        name: spec.legName,
        modelPath: file.path,
        contextSize: spec.contextSize,
      );
      legs.add(Leg(name: spec.legName, role: spec.role, provider: provider));
    }
    return LegRegistry.fromLegs(legs);
  }
}
