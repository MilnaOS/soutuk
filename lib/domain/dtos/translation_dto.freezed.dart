// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TranslationResponseDto _$TranslationResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _TranslationResponseDto.fromJson(json);
}

/// @nodoc
mixin _$TranslationResponseDto {
  String get sourceText => throw _privateConstructorUsedError;
  String get translatedText => throw _privateConstructorUsedError;
  double get confidenceScore => throw _privateConstructorUsedError;
  String get confidenceTier =>
      throw _privateConstructorUsedError; // 'CLEAN' | 'UNCERTAIN' | 'FLAG_FOR_REVIEW'
  List<String> get appliedFlags => throw _privateConstructorUsedError;
  List<String> get warningTokens => throw _privateConstructorUsedError;

  /// Serializes this TranslationResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TranslationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranslationResponseDtoCopyWith<TranslationResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationResponseDtoCopyWith<$Res> {
  factory $TranslationResponseDtoCopyWith(
    TranslationResponseDto value,
    $Res Function(TranslationResponseDto) then,
  ) = _$TranslationResponseDtoCopyWithImpl<$Res, TranslationResponseDto>;
  @useResult
  $Res call({
    String sourceText,
    String translatedText,
    double confidenceScore,
    String confidenceTier,
    List<String> appliedFlags,
    List<String> warningTokens,
  });
}

/// @nodoc
class _$TranslationResponseDtoCopyWithImpl<
  $Res,
  $Val extends TranslationResponseDto
>
    implements $TranslationResponseDtoCopyWith<$Res> {
  _$TranslationResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranslationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceText = null,
    Object? translatedText = null,
    Object? confidenceScore = null,
    Object? confidenceTier = null,
    Object? appliedFlags = null,
    Object? warningTokens = null,
  }) {
    return _then(
      _value.copyWith(
            sourceText: null == sourceText
                ? _value.sourceText
                : sourceText // ignore: cast_nullable_to_non_nullable
                      as String,
            translatedText: null == translatedText
                ? _value.translatedText
                : translatedText // ignore: cast_nullable_to_non_nullable
                      as String,
            confidenceScore: null == confidenceScore
                ? _value.confidenceScore
                : confidenceScore // ignore: cast_nullable_to_non_nullable
                      as double,
            confidenceTier: null == confidenceTier
                ? _value.confidenceTier
                : confidenceTier // ignore: cast_nullable_to_non_nullable
                      as String,
            appliedFlags: null == appliedFlags
                ? _value.appliedFlags
                : appliedFlags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            warningTokens: null == warningTokens
                ? _value.warningTokens
                : warningTokens // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TranslationResponseDtoImplCopyWith<$Res>
    implements $TranslationResponseDtoCopyWith<$Res> {
  factory _$$TranslationResponseDtoImplCopyWith(
    _$TranslationResponseDtoImpl value,
    $Res Function(_$TranslationResponseDtoImpl) then,
  ) = __$$TranslationResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sourceText,
    String translatedText,
    double confidenceScore,
    String confidenceTier,
    List<String> appliedFlags,
    List<String> warningTokens,
  });
}

/// @nodoc
class __$$TranslationResponseDtoImplCopyWithImpl<$Res>
    extends
        _$TranslationResponseDtoCopyWithImpl<$Res, _$TranslationResponseDtoImpl>
    implements _$$TranslationResponseDtoImplCopyWith<$Res> {
  __$$TranslationResponseDtoImplCopyWithImpl(
    _$TranslationResponseDtoImpl _value,
    $Res Function(_$TranslationResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TranslationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceText = null,
    Object? translatedText = null,
    Object? confidenceScore = null,
    Object? confidenceTier = null,
    Object? appliedFlags = null,
    Object? warningTokens = null,
  }) {
    return _then(
      _$TranslationResponseDtoImpl(
        sourceText: null == sourceText
            ? _value.sourceText
            : sourceText // ignore: cast_nullable_to_non_nullable
                  as String,
        translatedText: null == translatedText
            ? _value.translatedText
            : translatedText // ignore: cast_nullable_to_non_nullable
                  as String,
        confidenceScore: null == confidenceScore
            ? _value.confidenceScore
            : confidenceScore // ignore: cast_nullable_to_non_nullable
                  as double,
        confidenceTier: null == confidenceTier
            ? _value.confidenceTier
            : confidenceTier // ignore: cast_nullable_to_non_nullable
                  as String,
        appliedFlags: null == appliedFlags
            ? _value._appliedFlags
            : appliedFlags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        warningTokens: null == warningTokens
            ? _value._warningTokens
            : warningTokens // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TranslationResponseDtoImpl implements _TranslationResponseDto {
  const _$TranslationResponseDtoImpl({
    required this.sourceText,
    required this.translatedText,
    required this.confidenceScore,
    required this.confidenceTier,
    final List<String> appliedFlags = const [],
    final List<String> warningTokens = const [],
  }) : _appliedFlags = appliedFlags,
       _warningTokens = warningTokens;

  factory _$TranslationResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranslationResponseDtoImplFromJson(json);

  @override
  final String sourceText;
  @override
  final String translatedText;
  @override
  final double confidenceScore;
  @override
  final String confidenceTier;
  // 'CLEAN' | 'UNCERTAIN' | 'FLAG_FOR_REVIEW'
  final List<String> _appliedFlags;
  // 'CLEAN' | 'UNCERTAIN' | 'FLAG_FOR_REVIEW'
  @override
  @JsonKey()
  List<String> get appliedFlags {
    if (_appliedFlags is EqualUnmodifiableListView) return _appliedFlags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_appliedFlags);
  }

  final List<String> _warningTokens;
  @override
  @JsonKey()
  List<String> get warningTokens {
    if (_warningTokens is EqualUnmodifiableListView) return _warningTokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warningTokens);
  }

  @override
  String toString() {
    return 'TranslationResponseDto(sourceText: $sourceText, translatedText: $translatedText, confidenceScore: $confidenceScore, confidenceTier: $confidenceTier, appliedFlags: $appliedFlags, warningTokens: $warningTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationResponseDtoImpl &&
            (identical(other.sourceText, sourceText) ||
                other.sourceText == sourceText) &&
            (identical(other.translatedText, translatedText) ||
                other.translatedText == translatedText) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.confidenceTier, confidenceTier) ||
                other.confidenceTier == confidenceTier) &&
            const DeepCollectionEquality().equals(
              other._appliedFlags,
              _appliedFlags,
            ) &&
            const DeepCollectionEquality().equals(
              other._warningTokens,
              _warningTokens,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sourceText,
    translatedText,
    confidenceScore,
    confidenceTier,
    const DeepCollectionEquality().hash(_appliedFlags),
    const DeepCollectionEquality().hash(_warningTokens),
  );

  /// Create a copy of TranslationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationResponseDtoImplCopyWith<_$TranslationResponseDtoImpl>
  get copyWith =>
      __$$TranslationResponseDtoImplCopyWithImpl<_$TranslationResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TranslationResponseDtoImplToJson(this);
  }
}

abstract class _TranslationResponseDto implements TranslationResponseDto {
  const factory _TranslationResponseDto({
    required final String sourceText,
    required final String translatedText,
    required final double confidenceScore,
    required final String confidenceTier,
    final List<String> appliedFlags,
    final List<String> warningTokens,
  }) = _$TranslationResponseDtoImpl;

  factory _TranslationResponseDto.fromJson(Map<String, dynamic> json) =
      _$TranslationResponseDtoImpl.fromJson;

  @override
  String get sourceText;
  @override
  String get translatedText;
  @override
  double get confidenceScore;
  @override
  String get confidenceTier; // 'CLEAN' | 'UNCERTAIN' | 'FLAG_FOR_REVIEW'
  @override
  List<String> get appliedFlags;
  @override
  List<String> get warningTokens;

  /// Create a copy of TranslationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranslationResponseDtoImplCopyWith<_$TranslationResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
