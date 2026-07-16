// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discovery_crib_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DiscoveryCribDto _$DiscoveryCribDtoFromJson(Map<String, dynamic> json) {
  return _DiscoveryCribDto.fromJson(json);
}

/// @nodoc
mixin _$DiscoveryCribDto {
  String get symbolId => throw _privateConstructorUsedError;
  String get pictogramUrl => throw _privateConstructorUsedError;
  String get targetSentenceNorm => throw _privateConstructorUsedError;
  String? get elicitedAudioPath => throw _privateConstructorUsedError;
  String? get transcribedPhonemes => throw _privateConstructorUsedError;
  List<String> get inferredWordBoundaries => throw _privateConstructorUsedError;

  /// Serializes this DiscoveryCribDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscoveryCribDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoveryCribDtoCopyWith<DiscoveryCribDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoveryCribDtoCopyWith<$Res> {
  factory $DiscoveryCribDtoCopyWith(
    DiscoveryCribDto value,
    $Res Function(DiscoveryCribDto) then,
  ) = _$DiscoveryCribDtoCopyWithImpl<$Res, DiscoveryCribDto>;
  @useResult
  $Res call({
    String symbolId,
    String pictogramUrl,
    String targetSentenceNorm,
    String? elicitedAudioPath,
    String? transcribedPhonemes,
    List<String> inferredWordBoundaries,
  });
}

/// @nodoc
class _$DiscoveryCribDtoCopyWithImpl<$Res, $Val extends DiscoveryCribDto>
    implements $DiscoveryCribDtoCopyWith<$Res> {
  _$DiscoveryCribDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoveryCribDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbolId = null,
    Object? pictogramUrl = null,
    Object? targetSentenceNorm = null,
    Object? elicitedAudioPath = freezed,
    Object? transcribedPhonemes = freezed,
    Object? inferredWordBoundaries = null,
  }) {
    return _then(
      _value.copyWith(
            symbolId: null == symbolId
                ? _value.symbolId
                : symbolId // ignore: cast_nullable_to_non_nullable
                      as String,
            pictogramUrl: null == pictogramUrl
                ? _value.pictogramUrl
                : pictogramUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            targetSentenceNorm: null == targetSentenceNorm
                ? _value.targetSentenceNorm
                : targetSentenceNorm // ignore: cast_nullable_to_non_nullable
                      as String,
            elicitedAudioPath: freezed == elicitedAudioPath
                ? _value.elicitedAudioPath
                : elicitedAudioPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            transcribedPhonemes: freezed == transcribedPhonemes
                ? _value.transcribedPhonemes
                : transcribedPhonemes // ignore: cast_nullable_to_non_nullable
                      as String?,
            inferredWordBoundaries: null == inferredWordBoundaries
                ? _value.inferredWordBoundaries
                : inferredWordBoundaries // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscoveryCribDtoImplCopyWith<$Res>
    implements $DiscoveryCribDtoCopyWith<$Res> {
  factory _$$DiscoveryCribDtoImplCopyWith(
    _$DiscoveryCribDtoImpl value,
    $Res Function(_$DiscoveryCribDtoImpl) then,
  ) = __$$DiscoveryCribDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String symbolId,
    String pictogramUrl,
    String targetSentenceNorm,
    String? elicitedAudioPath,
    String? transcribedPhonemes,
    List<String> inferredWordBoundaries,
  });
}

/// @nodoc
class __$$DiscoveryCribDtoImplCopyWithImpl<$Res>
    extends _$DiscoveryCribDtoCopyWithImpl<$Res, _$DiscoveryCribDtoImpl>
    implements _$$DiscoveryCribDtoImplCopyWith<$Res> {
  __$$DiscoveryCribDtoImplCopyWithImpl(
    _$DiscoveryCribDtoImpl _value,
    $Res Function(_$DiscoveryCribDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscoveryCribDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbolId = null,
    Object? pictogramUrl = null,
    Object? targetSentenceNorm = null,
    Object? elicitedAudioPath = freezed,
    Object? transcribedPhonemes = freezed,
    Object? inferredWordBoundaries = null,
  }) {
    return _then(
      _$DiscoveryCribDtoImpl(
        symbolId: null == symbolId
            ? _value.symbolId
            : symbolId // ignore: cast_nullable_to_non_nullable
                  as String,
        pictogramUrl: null == pictogramUrl
            ? _value.pictogramUrl
            : pictogramUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        targetSentenceNorm: null == targetSentenceNorm
            ? _value.targetSentenceNorm
            : targetSentenceNorm // ignore: cast_nullable_to_non_nullable
                  as String,
        elicitedAudioPath: freezed == elicitedAudioPath
            ? _value.elicitedAudioPath
            : elicitedAudioPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        transcribedPhonemes: freezed == transcribedPhonemes
            ? _value.transcribedPhonemes
            : transcribedPhonemes // ignore: cast_nullable_to_non_nullable
                  as String?,
        inferredWordBoundaries: null == inferredWordBoundaries
            ? _value._inferredWordBoundaries
            : inferredWordBoundaries // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoveryCribDtoImpl implements _DiscoveryCribDto {
  const _$DiscoveryCribDtoImpl({
    required this.symbolId,
    required this.pictogramUrl,
    required this.targetSentenceNorm,
    this.elicitedAudioPath,
    this.transcribedPhonemes,
    final List<String> inferredWordBoundaries = const [],
  }) : _inferredWordBoundaries = inferredWordBoundaries;

  factory _$DiscoveryCribDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoveryCribDtoImplFromJson(json);

  @override
  final String symbolId;
  @override
  final String pictogramUrl;
  @override
  final String targetSentenceNorm;
  @override
  final String? elicitedAudioPath;
  @override
  final String? transcribedPhonemes;
  final List<String> _inferredWordBoundaries;
  @override
  @JsonKey()
  List<String> get inferredWordBoundaries {
    if (_inferredWordBoundaries is EqualUnmodifiableListView)
      return _inferredWordBoundaries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inferredWordBoundaries);
  }

  @override
  String toString() {
    return 'DiscoveryCribDto(symbolId: $symbolId, pictogramUrl: $pictogramUrl, targetSentenceNorm: $targetSentenceNorm, elicitedAudioPath: $elicitedAudioPath, transcribedPhonemes: $transcribedPhonemes, inferredWordBoundaries: $inferredWordBoundaries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoveryCribDtoImpl &&
            (identical(other.symbolId, symbolId) ||
                other.symbolId == symbolId) &&
            (identical(other.pictogramUrl, pictogramUrl) ||
                other.pictogramUrl == pictogramUrl) &&
            (identical(other.targetSentenceNorm, targetSentenceNorm) ||
                other.targetSentenceNorm == targetSentenceNorm) &&
            (identical(other.elicitedAudioPath, elicitedAudioPath) ||
                other.elicitedAudioPath == elicitedAudioPath) &&
            (identical(other.transcribedPhonemes, transcribedPhonemes) ||
                other.transcribedPhonemes == transcribedPhonemes) &&
            const DeepCollectionEquality().equals(
              other._inferredWordBoundaries,
              _inferredWordBoundaries,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    symbolId,
    pictogramUrl,
    targetSentenceNorm,
    elicitedAudioPath,
    transcribedPhonemes,
    const DeepCollectionEquality().hash(_inferredWordBoundaries),
  );

  /// Create a copy of DiscoveryCribDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoveryCribDtoImplCopyWith<_$DiscoveryCribDtoImpl> get copyWith =>
      __$$DiscoveryCribDtoImplCopyWithImpl<_$DiscoveryCribDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoveryCribDtoImplToJson(this);
  }
}

abstract class _DiscoveryCribDto implements DiscoveryCribDto {
  const factory _DiscoveryCribDto({
    required final String symbolId,
    required final String pictogramUrl,
    required final String targetSentenceNorm,
    final String? elicitedAudioPath,
    final String? transcribedPhonemes,
    final List<String> inferredWordBoundaries,
  }) = _$DiscoveryCribDtoImpl;

  factory _DiscoveryCribDto.fromJson(Map<String, dynamic> json) =
      _$DiscoveryCribDtoImpl.fromJson;

  @override
  String get symbolId;
  @override
  String get pictogramUrl;
  @override
  String get targetSentenceNorm;
  @override
  String? get elicitedAudioPath;
  @override
  String? get transcribedPhonemes;
  @override
  List<String> get inferredWordBoundaries;

  /// Create a copy of DiscoveryCribDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoveryCribDtoImplCopyWith<_$DiscoveryCribDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
