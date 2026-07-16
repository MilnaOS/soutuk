// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dot_payload_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DotCard _$DotCardFromJson(Map<String, dynamic> json) {
  return _DotCard.fromJson(json);
}

/// @nodoc
mixin _$DotCard {
  String get cardId => throw _privateConstructorUsedError;
  String get languageIso => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// Serializes this DotCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DotCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DotCardCopyWith<DotCard> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DotCardCopyWith<$Res> {
  factory $DotCardCopyWith(DotCard value, $Res Function(DotCard) then) =
      _$DotCardCopyWithImpl<$Res, DotCard>;
  @useResult
  $Res call({String cardId, String languageIso, String content});
}

/// @nodoc
class _$DotCardCopyWithImpl<$Res, $Val extends DotCard>
    implements $DotCardCopyWith<$Res> {
  _$DotCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DotCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? languageIso = null,
    Object? content = null,
  }) {
    return _then(
      _value.copyWith(
            cardId: null == cardId
                ? _value.cardId
                : cardId // ignore: cast_nullable_to_non_nullable
                      as String,
            languageIso: null == languageIso
                ? _value.languageIso
                : languageIso // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DotCardImplCopyWith<$Res> implements $DotCardCopyWith<$Res> {
  factory _$$DotCardImplCopyWith(
    _$DotCardImpl value,
    $Res Function(_$DotCardImpl) then,
  ) = __$$DotCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String cardId, String languageIso, String content});
}

/// @nodoc
class __$$DotCardImplCopyWithImpl<$Res>
    extends _$DotCardCopyWithImpl<$Res, _$DotCardImpl>
    implements _$$DotCardImplCopyWith<$Res> {
  __$$DotCardImplCopyWithImpl(
    _$DotCardImpl _value,
    $Res Function(_$DotCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DotCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? languageIso = null,
    Object? content = null,
  }) {
    return _then(
      _$DotCardImpl(
        cardId: null == cardId
            ? _value.cardId
            : cardId // ignore: cast_nullable_to_non_nullable
                  as String,
        languageIso: null == languageIso
            ? _value.languageIso
            : languageIso // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DotCardImpl extends _DotCard {
  const _$DotCardImpl({
    required this.cardId,
    required this.languageIso,
    required this.content,
  }) : super._();

  factory _$DotCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$DotCardImplFromJson(json);

  @override
  final String cardId;
  @override
  final String languageIso;
  @override
  final String content;

  @override
  String toString() {
    return 'DotCard(cardId: $cardId, languageIso: $languageIso, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DotCardImpl &&
            (identical(other.cardId, cardId) || other.cardId == cardId) &&
            (identical(other.languageIso, languageIso) ||
                other.languageIso == languageIso) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, cardId, languageIso, content);

  /// Create a copy of DotCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DotCardImplCopyWith<_$DotCardImpl> get copyWith =>
      __$$DotCardImplCopyWithImpl<_$DotCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DotCardImplToJson(this);
  }
}

abstract class _DotCard extends DotCard {
  const factory _DotCard({
    required final String cardId,
    required final String languageIso,
    required final String content,
  }) = _$DotCardImpl;
  const _DotCard._() : super._();

  factory _DotCard.fromJson(Map<String, dynamic> json) = _$DotCardImpl.fromJson;

  @override
  String get cardId;
  @override
  String get languageIso;
  @override
  String get content;

  /// Create a copy of DotCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotCardImplCopyWith<_$DotCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DotPayloadDto _$DotPayloadDtoFromJson(Map<String, dynamic> json) {
  return _DotPayloadDto.fromJson(json);
}

/// @nodoc
mixin _$DotPayloadDto {
  String get sourceLanguageIso => throw _privateConstructorUsedError;
  String get targetLanguageIso => throw _privateConstructorUsedError;
  DotCard get sourceCard => throw _privateConstructorUsedError;
  DotCard get targetCard => throw _privateConstructorUsedError;
  DotCard? get hazardCard => throw _privateConstructorUsedError;

  /// Serializes this DotPayloadDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DotPayloadDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DotPayloadDtoCopyWith<DotPayloadDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DotPayloadDtoCopyWith<$Res> {
  factory $DotPayloadDtoCopyWith(
    DotPayloadDto value,
    $Res Function(DotPayloadDto) then,
  ) = _$DotPayloadDtoCopyWithImpl<$Res, DotPayloadDto>;
  @useResult
  $Res call({
    String sourceLanguageIso,
    String targetLanguageIso,
    DotCard sourceCard,
    DotCard targetCard,
    DotCard? hazardCard,
  });

  $DotCardCopyWith<$Res> get sourceCard;
  $DotCardCopyWith<$Res> get targetCard;
  $DotCardCopyWith<$Res>? get hazardCard;
}

/// @nodoc
class _$DotPayloadDtoCopyWithImpl<$Res, $Val extends DotPayloadDto>
    implements $DotPayloadDtoCopyWith<$Res> {
  _$DotPayloadDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DotPayloadDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceLanguageIso = null,
    Object? targetLanguageIso = null,
    Object? sourceCard = null,
    Object? targetCard = null,
    Object? hazardCard = freezed,
  }) {
    return _then(
      _value.copyWith(
            sourceLanguageIso: null == sourceLanguageIso
                ? _value.sourceLanguageIso
                : sourceLanguageIso // ignore: cast_nullable_to_non_nullable
                      as String,
            targetLanguageIso: null == targetLanguageIso
                ? _value.targetLanguageIso
                : targetLanguageIso // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceCard: null == sourceCard
                ? _value.sourceCard
                : sourceCard // ignore: cast_nullable_to_non_nullable
                      as DotCard,
            targetCard: null == targetCard
                ? _value.targetCard
                : targetCard // ignore: cast_nullable_to_non_nullable
                      as DotCard,
            hazardCard: freezed == hazardCard
                ? _value.hazardCard
                : hazardCard // ignore: cast_nullable_to_non_nullable
                      as DotCard?,
          )
          as $Val,
    );
  }

  /// Create a copy of DotPayloadDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DotCardCopyWith<$Res> get sourceCard {
    return $DotCardCopyWith<$Res>(_value.sourceCard, (value) {
      return _then(_value.copyWith(sourceCard: value) as $Val);
    });
  }

  /// Create a copy of DotPayloadDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DotCardCopyWith<$Res> get targetCard {
    return $DotCardCopyWith<$Res>(_value.targetCard, (value) {
      return _then(_value.copyWith(targetCard: value) as $Val);
    });
  }

  /// Create a copy of DotPayloadDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DotCardCopyWith<$Res>? get hazardCard {
    if (_value.hazardCard == null) {
      return null;
    }

    return $DotCardCopyWith<$Res>(_value.hazardCard!, (value) {
      return _then(_value.copyWith(hazardCard: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DotPayloadDtoImplCopyWith<$Res>
    implements $DotPayloadDtoCopyWith<$Res> {
  factory _$$DotPayloadDtoImplCopyWith(
    _$DotPayloadDtoImpl value,
    $Res Function(_$DotPayloadDtoImpl) then,
  ) = __$$DotPayloadDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sourceLanguageIso,
    String targetLanguageIso,
    DotCard sourceCard,
    DotCard targetCard,
    DotCard? hazardCard,
  });

  @override
  $DotCardCopyWith<$Res> get sourceCard;
  @override
  $DotCardCopyWith<$Res> get targetCard;
  @override
  $DotCardCopyWith<$Res>? get hazardCard;
}

/// @nodoc
class __$$DotPayloadDtoImplCopyWithImpl<$Res>
    extends _$DotPayloadDtoCopyWithImpl<$Res, _$DotPayloadDtoImpl>
    implements _$$DotPayloadDtoImplCopyWith<$Res> {
  __$$DotPayloadDtoImplCopyWithImpl(
    _$DotPayloadDtoImpl _value,
    $Res Function(_$DotPayloadDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DotPayloadDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceLanguageIso = null,
    Object? targetLanguageIso = null,
    Object? sourceCard = null,
    Object? targetCard = null,
    Object? hazardCard = freezed,
  }) {
    return _then(
      _$DotPayloadDtoImpl(
        sourceLanguageIso: null == sourceLanguageIso
            ? _value.sourceLanguageIso
            : sourceLanguageIso // ignore: cast_nullable_to_non_nullable
                  as String,
        targetLanguageIso: null == targetLanguageIso
            ? _value.targetLanguageIso
            : targetLanguageIso // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceCard: null == sourceCard
            ? _value.sourceCard
            : sourceCard // ignore: cast_nullable_to_non_nullable
                  as DotCard,
        targetCard: null == targetCard
            ? _value.targetCard
            : targetCard // ignore: cast_nullable_to_non_nullable
                  as DotCard,
        hazardCard: freezed == hazardCard
            ? _value.hazardCard
            : hazardCard // ignore: cast_nullable_to_non_nullable
                  as DotCard?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DotPayloadDtoImpl implements _DotPayloadDto {
  const _$DotPayloadDtoImpl({
    required this.sourceLanguageIso,
    required this.targetLanguageIso,
    required this.sourceCard,
    required this.targetCard,
    this.hazardCard,
  });

  factory _$DotPayloadDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DotPayloadDtoImplFromJson(json);

  @override
  final String sourceLanguageIso;
  @override
  final String targetLanguageIso;
  @override
  final DotCard sourceCard;
  @override
  final DotCard targetCard;
  @override
  final DotCard? hazardCard;

  @override
  String toString() {
    return 'DotPayloadDto(sourceLanguageIso: $sourceLanguageIso, targetLanguageIso: $targetLanguageIso, sourceCard: $sourceCard, targetCard: $targetCard, hazardCard: $hazardCard)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DotPayloadDtoImpl &&
            (identical(other.sourceLanguageIso, sourceLanguageIso) ||
                other.sourceLanguageIso == sourceLanguageIso) &&
            (identical(other.targetLanguageIso, targetLanguageIso) ||
                other.targetLanguageIso == targetLanguageIso) &&
            (identical(other.sourceCard, sourceCard) ||
                other.sourceCard == sourceCard) &&
            (identical(other.targetCard, targetCard) ||
                other.targetCard == targetCard) &&
            (identical(other.hazardCard, hazardCard) ||
                other.hazardCard == hazardCard));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sourceLanguageIso,
    targetLanguageIso,
    sourceCard,
    targetCard,
    hazardCard,
  );

  /// Create a copy of DotPayloadDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DotPayloadDtoImplCopyWith<_$DotPayloadDtoImpl> get copyWith =>
      __$$DotPayloadDtoImplCopyWithImpl<_$DotPayloadDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DotPayloadDtoImplToJson(this);
  }
}

abstract class _DotPayloadDto implements DotPayloadDto {
  const factory _DotPayloadDto({
    required final String sourceLanguageIso,
    required final String targetLanguageIso,
    required final DotCard sourceCard,
    required final DotCard targetCard,
    final DotCard? hazardCard,
  }) = _$DotPayloadDtoImpl;

  factory _DotPayloadDto.fromJson(Map<String, dynamic> json) =
      _$DotPayloadDtoImpl.fromJson;

  @override
  String get sourceLanguageIso;
  @override
  String get targetLanguageIso;
  @override
  DotCard get sourceCard;
  @override
  DotCard get targetCard;
  @override
  DotCard? get hazardCard;

  /// Create a copy of DotPayloadDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotPayloadDtoImplCopyWith<_$DotPayloadDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
