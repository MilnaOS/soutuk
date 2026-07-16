// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dot_write_chunk_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DotWriteChunkDto _$DotWriteChunkDtoFromJson(Map<String, dynamic> json) {
  return _DotWriteChunkDto.fromJson(json);
}

/// @nodoc
mixin _$DotWriteChunkDto {
  String get chunkId => throw _privateConstructorUsedError;
  String get nodeTargetId => throw _privateConstructorUsedError;
  Map<String, dynamic> get deltaContent => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get sourceConfidence => throw _privateConstructorUsedError;

  /// Serializes this DotWriteChunkDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DotWriteChunkDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DotWriteChunkDtoCopyWith<DotWriteChunkDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DotWriteChunkDtoCopyWith<$Res> {
  factory $DotWriteChunkDtoCopyWith(
    DotWriteChunkDto value,
    $Res Function(DotWriteChunkDto) then,
  ) = _$DotWriteChunkDtoCopyWithImpl<$Res, DotWriteChunkDto>;
  @useResult
  $Res call({
    String chunkId,
    String nodeTargetId,
    Map<String, dynamic> deltaContent,
    DateTime timestamp,
    double sourceConfidence,
  });
}

/// @nodoc
class _$DotWriteChunkDtoCopyWithImpl<$Res, $Val extends DotWriteChunkDto>
    implements $DotWriteChunkDtoCopyWith<$Res> {
  _$DotWriteChunkDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DotWriteChunkDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkId = null,
    Object? nodeTargetId = null,
    Object? deltaContent = null,
    Object? timestamp = null,
    Object? sourceConfidence = null,
  }) {
    return _then(
      _value.copyWith(
            chunkId: null == chunkId
                ? _value.chunkId
                : chunkId // ignore: cast_nullable_to_non_nullable
                      as String,
            nodeTargetId: null == nodeTargetId
                ? _value.nodeTargetId
                : nodeTargetId // ignore: cast_nullable_to_non_nullable
                      as String,
            deltaContent: null == deltaContent
                ? _value.deltaContent
                : deltaContent // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            sourceConfidence: null == sourceConfidence
                ? _value.sourceConfidence
                : sourceConfidence // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DotWriteChunkDtoImplCopyWith<$Res>
    implements $DotWriteChunkDtoCopyWith<$Res> {
  factory _$$DotWriteChunkDtoImplCopyWith(
    _$DotWriteChunkDtoImpl value,
    $Res Function(_$DotWriteChunkDtoImpl) then,
  ) = __$$DotWriteChunkDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String chunkId,
    String nodeTargetId,
    Map<String, dynamic> deltaContent,
    DateTime timestamp,
    double sourceConfidence,
  });
}

/// @nodoc
class __$$DotWriteChunkDtoImplCopyWithImpl<$Res>
    extends _$DotWriteChunkDtoCopyWithImpl<$Res, _$DotWriteChunkDtoImpl>
    implements _$$DotWriteChunkDtoImplCopyWith<$Res> {
  __$$DotWriteChunkDtoImplCopyWithImpl(
    _$DotWriteChunkDtoImpl _value,
    $Res Function(_$DotWriteChunkDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DotWriteChunkDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkId = null,
    Object? nodeTargetId = null,
    Object? deltaContent = null,
    Object? timestamp = null,
    Object? sourceConfidence = null,
  }) {
    return _then(
      _$DotWriteChunkDtoImpl(
        chunkId: null == chunkId
            ? _value.chunkId
            : chunkId // ignore: cast_nullable_to_non_nullable
                  as String,
        nodeTargetId: null == nodeTargetId
            ? _value.nodeTargetId
            : nodeTargetId // ignore: cast_nullable_to_non_nullable
                  as String,
        deltaContent: null == deltaContent
            ? _value._deltaContent
            : deltaContent // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        sourceConfidence: null == sourceConfidence
            ? _value.sourceConfidence
            : sourceConfidence // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DotWriteChunkDtoImpl implements _DotWriteChunkDto {
  const _$DotWriteChunkDtoImpl({
    required this.chunkId,
    required this.nodeTargetId,
    required final Map<String, dynamic> deltaContent,
    required this.timestamp,
    required this.sourceConfidence,
  }) : _deltaContent = deltaContent;

  factory _$DotWriteChunkDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DotWriteChunkDtoImplFromJson(json);

  @override
  final String chunkId;
  @override
  final String nodeTargetId;
  final Map<String, dynamic> _deltaContent;
  @override
  Map<String, dynamic> get deltaContent {
    if (_deltaContent is EqualUnmodifiableMapView) return _deltaContent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_deltaContent);
  }

  @override
  final DateTime timestamp;
  @override
  final double sourceConfidence;

  @override
  String toString() {
    return 'DotWriteChunkDto(chunkId: $chunkId, nodeTargetId: $nodeTargetId, deltaContent: $deltaContent, timestamp: $timestamp, sourceConfidence: $sourceConfidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DotWriteChunkDtoImpl &&
            (identical(other.chunkId, chunkId) || other.chunkId == chunkId) &&
            (identical(other.nodeTargetId, nodeTargetId) ||
                other.nodeTargetId == nodeTargetId) &&
            const DeepCollectionEquality().equals(
              other._deltaContent,
              _deltaContent,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.sourceConfidence, sourceConfidence) ||
                other.sourceConfidence == sourceConfidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    chunkId,
    nodeTargetId,
    const DeepCollectionEquality().hash(_deltaContent),
    timestamp,
    sourceConfidence,
  );

  /// Create a copy of DotWriteChunkDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DotWriteChunkDtoImplCopyWith<_$DotWriteChunkDtoImpl> get copyWith =>
      __$$DotWriteChunkDtoImplCopyWithImpl<_$DotWriteChunkDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DotWriteChunkDtoImplToJson(this);
  }
}

abstract class _DotWriteChunkDto implements DotWriteChunkDto {
  const factory _DotWriteChunkDto({
    required final String chunkId,
    required final String nodeTargetId,
    required final Map<String, dynamic> deltaContent,
    required final DateTime timestamp,
    required final double sourceConfidence,
  }) = _$DotWriteChunkDtoImpl;

  factory _DotWriteChunkDto.fromJson(Map<String, dynamic> json) =
      _$DotWriteChunkDtoImpl.fromJson;

  @override
  String get chunkId;
  @override
  String get nodeTargetId;
  @override
  Map<String, dynamic> get deltaContent;
  @override
  DateTime get timestamp;
  @override
  double get sourceConfidence;

  /// Create a copy of DotWriteChunkDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotWriteChunkDtoImplCopyWith<_$DotWriteChunkDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
