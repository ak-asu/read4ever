// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReaderContext {
  ReaderSource get source => throw _privateConstructorUsedError;
  List<int>? get adjacentChapterIds => throw _privateConstructorUsedError;
  int? get scrollToHighlightId => throw _privateConstructorUsedError;

  /// Create a copy of ReaderContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReaderContextCopyWith<ReaderContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReaderContextCopyWith<$Res> {
  factory $ReaderContextCopyWith(
          ReaderContext value, $Res Function(ReaderContext) then) =
      _$ReaderContextCopyWithImpl<$Res, ReaderContext>;
  @useResult
  $Res call(
      {ReaderSource source,
      List<int>? adjacentChapterIds,
      int? scrollToHighlightId});
}

/// @nodoc
class _$ReaderContextCopyWithImpl<$Res, $Val extends ReaderContext>
    implements $ReaderContextCopyWith<$Res> {
  _$ReaderContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReaderContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? adjacentChapterIds = freezed,
    Object? scrollToHighlightId = freezed,
  }) {
    return _then(_value.copyWith(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as ReaderSource,
      adjacentChapterIds: freezed == adjacentChapterIds
          ? _value.adjacentChapterIds
          : adjacentChapterIds // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      scrollToHighlightId: freezed == scrollToHighlightId
          ? _value.scrollToHighlightId
          : scrollToHighlightId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReaderContextImplCopyWith<$Res>
    implements $ReaderContextCopyWith<$Res> {
  factory _$$ReaderContextImplCopyWith(
          _$ReaderContextImpl value, $Res Function(_$ReaderContextImpl) then) =
      __$$ReaderContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ReaderSource source,
      List<int>? adjacentChapterIds,
      int? scrollToHighlightId});
}

/// @nodoc
class __$$ReaderContextImplCopyWithImpl<$Res>
    extends _$ReaderContextCopyWithImpl<$Res, _$ReaderContextImpl>
    implements _$$ReaderContextImplCopyWith<$Res> {
  __$$ReaderContextImplCopyWithImpl(
      _$ReaderContextImpl _value, $Res Function(_$ReaderContextImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReaderContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? adjacentChapterIds = freezed,
    Object? scrollToHighlightId = freezed,
  }) {
    return _then(_$ReaderContextImpl(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as ReaderSource,
      adjacentChapterIds: freezed == adjacentChapterIds
          ? _value._adjacentChapterIds
          : adjacentChapterIds // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      scrollToHighlightId: freezed == scrollToHighlightId
          ? _value.scrollToHighlightId
          : scrollToHighlightId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$ReaderContextImpl implements _ReaderContext {
  const _$ReaderContextImpl(
      {this.source = ReaderSource.library,
      final List<int>? adjacentChapterIds,
      this.scrollToHighlightId})
      : _adjacentChapterIds = adjacentChapterIds;

  @override
  @JsonKey()
  final ReaderSource source;
  final List<int>? _adjacentChapterIds;
  @override
  List<int>? get adjacentChapterIds {
    final value = _adjacentChapterIds;
    if (value == null) return null;
    if (_adjacentChapterIds is EqualUnmodifiableListView)
      return _adjacentChapterIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? scrollToHighlightId;

  @override
  String toString() {
    return 'ReaderContext(source: $source, adjacentChapterIds: $adjacentChapterIds, scrollToHighlightId: $scrollToHighlightId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReaderContextImpl &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality()
                .equals(other._adjacentChapterIds, _adjacentChapterIds) &&
            (identical(other.scrollToHighlightId, scrollToHighlightId) ||
                other.scrollToHighlightId == scrollToHighlightId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      source,
      const DeepCollectionEquality().hash(_adjacentChapterIds),
      scrollToHighlightId);

  /// Create a copy of ReaderContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReaderContextImplCopyWith<_$ReaderContextImpl> get copyWith =>
      __$$ReaderContextImplCopyWithImpl<_$ReaderContextImpl>(this, _$identity);
}

abstract class _ReaderContext implements ReaderContext {
  const factory _ReaderContext(
      {final ReaderSource source,
      final List<int>? adjacentChapterIds,
      final int? scrollToHighlightId}) = _$ReaderContextImpl;

  @override
  ReaderSource get source;
  @override
  List<int>? get adjacentChapterIds;
  @override
  int? get scrollToHighlightId;

  /// Create a copy of ReaderContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReaderContextImplCopyWith<_$ReaderContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReaderState {
  int get chapterId => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  ReaderContext get context => throw _privateConstructorUsedError;

  /// Create a copy of ReaderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReaderStateCopyWith<ReaderState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReaderStateCopyWith<$Res> {
  factory $ReaderStateCopyWith(
          ReaderState value, $Res Function(ReaderState) then) =
      _$ReaderStateCopyWithImpl<$Res, ReaderState>;
  @useResult
  $Res call({int chapterId, bool isLoading, ReaderContext context});

  $ReaderContextCopyWith<$Res> get context;
}

/// @nodoc
class _$ReaderStateCopyWithImpl<$Res, $Val extends ReaderState>
    implements $ReaderStateCopyWith<$Res> {
  _$ReaderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReaderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapterId = null,
    Object? isLoading = null,
    Object? context = null,
  }) {
    return _then(_value.copyWith(
      chapterId: null == chapterId
          ? _value.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as ReaderContext,
    ) as $Val);
  }

  /// Create a copy of ReaderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReaderContextCopyWith<$Res> get context {
    return $ReaderContextCopyWith<$Res>(_value.context, (value) {
      return _then(_value.copyWith(context: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReaderStateImplCopyWith<$Res>
    implements $ReaderStateCopyWith<$Res> {
  factory _$$ReaderStateImplCopyWith(
          _$ReaderStateImpl value, $Res Function(_$ReaderStateImpl) then) =
      __$$ReaderStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int chapterId, bool isLoading, ReaderContext context});

  @override
  $ReaderContextCopyWith<$Res> get context;
}

/// @nodoc
class __$$ReaderStateImplCopyWithImpl<$Res>
    extends _$ReaderStateCopyWithImpl<$Res, _$ReaderStateImpl>
    implements _$$ReaderStateImplCopyWith<$Res> {
  __$$ReaderStateImplCopyWithImpl(
      _$ReaderStateImpl _value, $Res Function(_$ReaderStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReaderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapterId = null,
    Object? isLoading = null,
    Object? context = null,
  }) {
    return _then(_$ReaderStateImpl(
      chapterId: null == chapterId
          ? _value.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as ReaderContext,
    ));
  }
}

/// @nodoc

class _$ReaderStateImpl implements _ReaderState {
  const _$ReaderStateImpl(
      {required this.chapterId, this.isLoading = true, required this.context});

  @override
  final int chapterId;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final ReaderContext context;

  @override
  String toString() {
    return 'ReaderState(chapterId: $chapterId, isLoading: $isLoading, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReaderStateImpl &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.context, context) || other.context == context));
  }

  @override
  int get hashCode => Object.hash(runtimeType, chapterId, isLoading, context);

  /// Create a copy of ReaderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReaderStateImplCopyWith<_$ReaderStateImpl> get copyWith =>
      __$$ReaderStateImplCopyWithImpl<_$ReaderStateImpl>(this, _$identity);
}

abstract class _ReaderState implements ReaderState {
  const factory _ReaderState(
      {required final int chapterId,
      final bool isLoading,
      required final ReaderContext context}) = _$ReaderStateImpl;

  @override
  int get chapterId;
  @override
  bool get isLoading;
  @override
  ReaderContext get context;

  /// Create a copy of ReaderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReaderStateImplCopyWith<_$ReaderStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
