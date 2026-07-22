import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/dtos/language_option_dto.dart';
import '../../feature_flags.dart';

class LanguageCatalog {
  static Future<List<LanguageOption>> loadAll() async {
    final raw = await rootBundle.loadString('assets/data/languages.json');
    final List<dynamic> decoded = jsonDecode(raw);
    final all = decoded
        .map((e) => LanguageOption.fromJson(e as Map<String, dynamic>))
        .toList();
    if (kSignLanguagesEnabled) return all;
    // Sign languages need camera/visual translation, not text — see
    // feature_flags.dart. Held out of the picker, not deleted from data.
    return all.where((lang) => !kSignLanguageIsoCodes.contains(lang.iso)).toList();
  }
}
