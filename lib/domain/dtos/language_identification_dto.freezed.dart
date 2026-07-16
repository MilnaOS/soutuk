// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'language_identification_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LanguageIdentificationDto _$LanguageIdentificationDtoFromJson(
  Map<String, dynamic> json,
) {
  return _LanguageIdentificationDto.fromJson(json);
}

/// @nodoc
mixin _$LanguageIdentificationDto {
  String? get detectedIso => throw _privateConstructorUsedError;
  String? get detectedName => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  bool get sufficientSample => throw _privateConstructorUsedError;
  String get reasoning => throw _privateConstructorUsedError;

  /// Serializes this LanguageIdentificationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LanguageIdentificationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LanguageIdentificationDtoCopyWith<LanguageIdentificationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanguageIdentificationDtoCopyWith<$Res> {
  factory $LanguageIdentificationDtoCopyWith(
    LanguageIdentificationDto value,
    $Res Function(LanguageIdentificationDto) then,
  ) = _$LanguageIdentificationDtoCopyWithImpl<$Res, LanguageIdentificationDto>;
  @useResult
  $Res call({
    String? detectedIso,
    String? detectedName,
    double confidence,
    bool sufficientSample,
    String reasoning,
  });
}

/// @nodoc
class _$LanguageIdentificationDtoCopyWithImpl<
  $Res,
  $Val extends LanguageIdentificationDto
>
    implements $LanguageIdentificationDtoCopyWith<$Res> {
  _$LanguageIdentificationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LanguageIdentificationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detectedIso = freezed,
    Object? detectedName = freezed,
    Object? confidence = null,
    Object? sufficientSample = null,
    Object? reasoning = null,
  }) {
    return _then(
      _value.copyWith(
            detectedIso: freezed == detectedIso
                ? _value.detectedIso
                : detectedIso // ignore: cast_nullable_to_non_nullable
                      as String?,
            detectedName: freezed == detectedName
                ? _value.detectedName
                : detectedName // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            sufficientSample: null == sufficientSample
                ? _value.sufficientSample
                : sufficientSample // ignore: cast_nullable_to_non_nullable
                      as bool,
            reasoning: null == reasoning
                ? _value.reasoning
                : reasoning // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LanguageIdentificationDtoImplCopyWith<$Res>
    implements $LanguageIdentificationDtoCopyWith<$Res> {
  factory _$$LanguageIdentificationDtoImplCopyWith(
    _$LanguageIdentificationDtoImpl value,
    $Res Function(_$LanguageIdentificationDtoImpl) then,
  ) = __$$LanguageIdentificationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? detectedIso,
    String? detectedName,
    double confidence,
    bool sufficientSample,
    String reasoning,
  });
}

/// @nodoc
class __$$LanguageIdentificationDtoImplCopyWithImpl<$Res>
    extends
        _$LanguageIdentificationDtoCopyWithImpl<
          $Res,
          _$LanguageIdentificationDtoImpl
        >
    implements _$$LanguageIdentificationDtoImplCopyWith<$Res> {
  __$$LanguageIdentificationDtoImplCopyWithImpl(
    _$LanguageIdentificationDtoImpl _value,
    $Res Function(_$LanguageIdentificationDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LanguageIdentificationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detectedIso = freezed,
    Object? detectedName = freezed,
    Object? confidence = null,
    Object? sufficientSample = null,
    Object? reasoning = null,
  }) {
    return _then(
      _$LanguageIdentificationDtoImpl(
        detectedIso: freezed == detectedIso
            ? _value.detectedIso
            : detectedIso // ignore: cast_nullable_to_non_nullable
                  as String?,
        detectedName: freezed == detectedName
            ? _value.detectedName
            : detectedName // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        sufficientSample: null == sufficientSample
            ? _value.sufficientSample
            : sufficientSample // ignore: cast_nullable_to_non_nullable
                  as bool,
        reasoning: null == reasoning
            ? _value.reasoning
            : reasoning // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LanguageIdentificationDtoImpl implements _LanguageIdentificationDto {
  const _$LanguageIdentificationDtoImpl({
    this.detectedIso,
    this.detectedName,
    required this.confidence,
    required this.sufficientSample,
    this.reasoning = '',
  });

  factory _$LanguageIdentificationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LanguageIdentificationDtoImplFromJson(json);

  @override
  final String? detectedIso;
  @override
  final String? detectedName;
  @override
  final double confidence;
  @override
  final bool sufficientSample;
  @override
  @JsonKey()
  final String reasoning;

  @override
  String toString() {
    return 'LanguageIdentificationDto(detectedIso: $detectedIso, detectedName: $detectedName, confidence: $confidence, sufficientSample: $sufficientSample, reasoning: $reasoning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LanguageIdentificationDtoImpl &&
            (identical(other.detectedIso, detectedIso) ||
                other.detectedIso == detectedIso) &&
            (identical(other.detectedName, detectedName) ||
                other.detectedName == detectedName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.sufficientSample, sufficientSample) ||
                other.sufficientSample == sufficientSample) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    detectedIso,
    detectedName,
    confidence,
    sufficientSample,
    reasoning,
  );

  /// Create a copy of LanguageIdentificationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LanguageIdentificationDtoImplCopyWith<_$LanguageIdentificationDtoImpl>
  get copyWith =>
      __$$LanguageIdentificationDtoImplCopyWithImpl<
        _$LanguageIdentificationDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LanguageIdentificationDtoImplToJson(this);
  }
}

abstract class _LanguageIdentificationDto implements LanguageIdentificationDto {
  const factory _LanguageIdentificationDto({
    final String? detectedIso,
    final String? detectedName,
    required final double confidence,
    required final bool sufficientSample,
    final String reasoning,
  }) = _$LanguageIdentificationDtoImpl;

  factory _LanguageIdentificationDto.fromJson(Map<String, dynamic> json) =
      _$LanguageIdentificationDtoImpl.fromJson;

  @override
  String? get detectedIso;
  @override
  String? get detectedName;
  @override
  double get confidence;
  @override
  bool get sufficientSample;
  @override
  String get reasoning;

  /// Create a copy of LanguageIdentificationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LanguageIdentificationDtoImplCopyWith<_$LanguageIdentificationDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
