import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// The real per-language/family translation reference, generated from the
/// linguistics_blade pipeline's Memory Alpha knowledge base (WALS-sourced
/// typology data, curated and indexed by ISO code). Replaces reliance on the
/// AI model's own training knowledge with an actual lookup — 182 of the
/// app's 188 languages have direct cards; the other 6 fall back through
/// [LinguisticsMemoryAlpha]'s hand-written entries (fra, lat, vat, grc, arc,
/// egy). Languages with neither were removed from the picker entirely
/// rather than silently served a generic default — see
/// dot_pending_languages.json at the repo root for what's still missing.
class RealDotKnowledge {
  static Map<String, String>? _languageCards;
  static Map<String, String>? _familyCards;

  static Future<void> ensureLoaded() async {
    if (_languageCards != null) return;
    final langRaw = await rootBundle.loadString('assets/data/dot_language_cards.json');
    final famRaw = await rootBundle.loadString('assets/data/dot_family_cards.json');
    _languageCards = Map<String, String>.from(jsonDecode(langRaw) as Map);
    _familyCards = Map<String, String>.from(jsonDecode(famRaw) as Map);
  }

  static String? languageCard(String iso) => _languageCards?[iso.toLowerCase()];

  static String? familyCard(String family) => _familyCards?[family.toLowerCase()];
}
