// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'language_option_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LanguageOption _$LanguageOptionFromJson(Map<String, dynamic> json) {
  return _LanguageOption.fromJson(json);
}

/// @nodoc
mixin _$LanguageOption {
  String get name => throw _privateConstructorUsedError;
  String get iso => throw _privateConstructorUsedError;

  /// Serializes this LanguageOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LanguageOptionCopyWith<LanguageOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanguageOptionCopyWith<$Res> {
  factory $LanguageOptionCopyWith(
    LanguageOption value,
    $Res Function(LanguageOption) then,
  ) = _$LanguageOptionCopyWithImpl<$Res, LanguageOption>;
  @useResult
  $Res call({String name, String iso});
}

/// @nodoc
class _$LanguageOptionCopyWithImpl<$Res, $Val extends LanguageOption>
    implements $LanguageOptionCopyWith<$Res> {
  _$LanguageOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? iso = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            iso: null == iso
                ? _value.iso
                : iso // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LanguageOptionImplCopyWith<$Res>
    implements $LanguageOptionCopyWith<$Res> {
  factory _$$LanguageOptionImplCopyWith(
    _$LanguageOptionImpl value,
    $Res Function(_$LanguageOptionImpl) then,
  ) = __$$LanguageOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String iso});
}

/// @nodoc
class __$$LanguageOptionImplCopyWithImpl<$Res>
    extends _$LanguageOptionCopyWithImpl<$Res, _$LanguageOptionImpl>
    implements _$$LanguageOptionImplCopyWith<$Res> {
  __$$LanguageOptionImplCopyWithImpl(
    _$LanguageOptionImpl _value,
    $Res Function(_$LanguageOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? iso = null}) {
    return _then(
      _$LanguageOptionImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        iso: null == iso
            ? _value.iso
            : iso // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LanguageOptionImpl implements _LanguageOption {
  const _$LanguageOptionImpl({required this.name, required this.iso});

  factory _$LanguageOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LanguageOptionImplFromJson(json);

  @override
  final String name;
  @override
  final String iso;

  @override
  String toString() {
    return 'LanguageOption(name: $name, iso: $iso)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LanguageOptionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iso, iso) || other.iso == iso));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, iso);

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LanguageOptionImplCopyWith<_$LanguageOptionImpl> get copyWith =>
      __$$LanguageOptionImplCopyWithImpl<_$LanguageOptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LanguageOptionImplToJson(this);
  }
}

abstract class _LanguageOption implements LanguageOption {
  const factory _LanguageOption({
    required final String name,
    required final String iso,
  }) = _$LanguageOptionImpl;

  factory _LanguageOption.fromJson(Map<String, dynamic> json) =
      _$LanguageOptionImpl.fromJson;

  @override
  String get name;
  @override
  String get iso;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LanguageOptionImplCopyWith<_$LanguageOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
