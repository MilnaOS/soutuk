/// Offline/on-device translation (Milna OS: Artaxia) is retired for now —
/// Android's llm_llamacpp has no GPU backend, so on-device model quality
/// is capped by phone-CPU-only inference and underperformed in testing.
/// Code stays intact; flip this back to true to re-enable the UI.
const bool kOfflineModeEnabled = false;
