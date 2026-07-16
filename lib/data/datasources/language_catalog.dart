import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/dtos/language_option_dto.dart';

class LanguageCatalog {
  static Future<List<LanguageOption>> loadAll() async {
    final raw = await rootBundle.loadString('assets/data/languages.json');
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => LanguageOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
