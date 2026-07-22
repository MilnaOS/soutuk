/// Offline/on-device translation (Milna OS: Artaxia) is retired for now —
/// Android's llm_llamacpp has no GPU backend, so on-device model quality
/// is capped by phone-CPU-only inference and underperformed in testing.
/// Code stays intact; flip this back to true to re-enable the UI.
const bool kOfflineModeEnabled = false;

/// Sign languages need visual/camera-based translation, not text/speech —
/// the DOT cards for these are real and well-formed (not a data-quality
/// pending item, see dot_pending_languages.json for that separate concern),
/// they're just unusable until the camera project is wired up. Held back
/// from the picker here rather than removed from languages.json, so this
/// is a one-line flip once that project ships.
const bool kSignLanguagesEnabled = false;
const Set<String> kSignLanguageIsoCodes = {
  'ase', // American Sign Language
  'csl', // Chinese Sign Language
  'gss', // Greek Sign Language
  'hks', // Hong Kong Sign Language
  'ins', // Indo-Pakistani Sign Language
  'jsl', // Japanese Sign Language (Nihon Shuwa)
  'psd', // Plains Indians Sign Language
  'rsl', // Russian Sign Language
  'tss', // Taiwanese Sign Language (Ziran Shouyu)
};
