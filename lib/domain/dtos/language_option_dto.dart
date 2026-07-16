import 'package:freezed_annotation/freezed_annotation.dart';

part 'language_option_dto.freezed.dart';
part 'language_option_dto.g.dart';

@freezed
class LanguageOption with _$LanguageOption {
  const factory LanguageOption({
    required String name,
    required String iso,
  }) = _LanguageOption;

  factory LanguageOption.fromJson(Map<String, dynamic> json) => _$LanguageOptionFromJson(json);
}
