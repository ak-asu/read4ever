// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ImportState {
  String get url => throw _privateConstructorUsedError;
  ImportStatus get status => throw _privateConstructorUsedError;
  List<SitemapPage> get allPages =>
      throw _privateConstructorUsedError; // URLs of pages the user has deselected; everything else is selected.
// URL-based (not index-based) so reordering in advanced mode doesn't affect selection.
  List<String> get deselectedUrls => throw _privateConstructorUsedError;
  String get resourceName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get maxDepth => throw _privateConstructorUsedError;
  bool get isAdvanced => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImportStateCopyWith<ImportState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportStateCopyWith<$Res> {
  factory $ImportStateCopyWith(
          ImportState value, $Res Function(ImportState) then) =
      _$ImportStateCopyWithImpl<$Res, ImportState>;
  @useResult
  $Res call(
      {String url,
      ImportStatus status,
      List<SitemapPage> allPages,
      List<String> deselectedUrls,
      String resourceName,
      String description,
      int maxDepth,
      bool isAdvanced,
      String? errorMessage});
}

/// @nodoc
class _$ImportStateCopyWithImpl<$Res, $Val extends ImportState>
    implements $ImportStateCopyWith<$Res> {
  _$ImportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? status = null,
    Object? allPages = null,
    Object? deselectedUrls = null,
    Object? resourceName = null,
    Object? description = null,
    Object? maxDepth = null,
    Object? isAdvanced = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ImportStatus,
      allPages: null == allPages
          ? _value.allPages
          : allPages // ignore: cast_nullable_to_non_nullable
              as List<SitemapPage>,
      deselectedUrls: null == deselectedUrls
          ? _value.deselectedUrls
          : deselectedUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      resourceName: null == resourceName
          ? _value.resourceName
          : resourceName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      maxDepth: null == maxDepth
          ? _value.maxDepth
          : maxDepth // ignore: cast_nullable_to_non_nullable
              as int,
      isAdvanced: null == isAdvanced
          ? _value.isAdvanced
          : isAdvanced // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImportStateImplCopyWith<$Res>
    implements $ImportStateCopyWith<$Res> {
  factory _$$ImportStateImplCopyWith(
          _$ImportStateImpl value, $Res Function(_$ImportStateImpl) then) =
      __$$ImportStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String url,
      ImportStatus status,
      List<SitemapPage> allPages,
      List<String> deselectedUrls,
      String resourceName,
      String description,
      int maxDepth,
      bool isAdvanced,
      String? errorMessage});
}

/// @nodoc
class __$$ImportStateImplCopyWithImpl<$Res>
    extends _$ImportStateCopyWithImpl<$Res, _$ImportStateImpl>
    implements _$$ImportStateImplCopyWith<$Res> {
  __$$ImportStateImplCopyWithImpl(
      _$ImportStateImpl _value, $Res Function(_$ImportStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? status = null,
    Object? allPages = null,
    Object? deselectedUrls = null,
    Object? resourceName = null,
    Object? description = null,
    Object? maxDepth = null,
    Object? isAdvanced = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$ImportStateImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ImportStatus,
      allPages: null == allPages
          ? _value._allPages
          : allPages // ignore: cast_nullable_to_non_nullable
              as List<SitemapPage>,
      deselectedUrls: null == deselectedUrls
          ? _value._deselectedUrls
          : deselectedUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      resourceName: null == resourceName
          ? _value.resourceName
          : resourceName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      maxDepth: null == maxDepth
          ? _value.maxDepth
          : maxDepth // ignore: cast_nullable_to_non_nullable
              as int,
      isAdvanced: null == isAdvanced
          ? _value.isAdvanced
          : isAdvanced // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ImportStateImpl implements _ImportState {
  const _$ImportStateImpl(
      {this.url = '',
      this.status = ImportStatus.idle,
      final List<SitemapPage> allPages = const [],
      final List<String> deselectedUrls = const [],
      this.resourceName = '',
      this.description = '',
      this.maxDepth = 2,
      this.isAdvanced = false,
      this.errorMessage})
      : _allPages = allPages,
        _deselectedUrls = deselectedUrls;

  @override
  @JsonKey()
  final String url;
  @override
  @JsonKey()
  final ImportStatus status;
  final List<SitemapPage> _allPages;
  @override
  @JsonKey()
  List<SitemapPage> get allPages {
    if (_allPages is EqualUnmodifiableListView) return _allPages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allPages);
  }

// URLs of pages the user has deselected; everything else is selected.
// URL-based (not index-based) so reordering in advanced mode doesn't affect selection.
  final List<String> _deselectedUrls;
// URLs of pages the user has deselected; everything else is selected.
// URL-based (not index-based) so reordering in advanced mode doesn't affect selection.
  @override
  @JsonKey()
  List<String> get deselectedUrls {
    if (_deselectedUrls is EqualUnmodifiableListView) return _deselectedUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deselectedUrls);
  }

  @override
  @JsonKey()
  final String resourceName;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final int maxDepth;
  @override
  @JsonKey()
  final bool isAdvanced;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ImportState(url: $url, status: $status, allPages: $allPages, deselectedUrls: $deselectedUrls, resourceName: $resourceName, description: $description, maxDepth: $maxDepth, isAdvanced: $isAdvanced, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportStateImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._allPages, _allPages) &&
            const DeepCollectionEquality()
                .equals(other._deselectedUrls, _deselectedUrls) &&
            (identical(other.resourceName, resourceName) ||
                other.resourceName == resourceName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.maxDepth, maxDepth) ||
                other.maxDepth == maxDepth) &&
            (identical(other.isAdvanced, isAdvanced) ||
                other.isAdvanced == isAdvanced) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      url,
      status,
      const DeepCollectionEquality().hash(_allPages),
      const DeepCollectionEquality().hash(_deselectedUrls),
      resourceName,
      description,
      maxDepth,
      isAdvanced,
      errorMessage);

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportStateImplCopyWith<_$ImportStateImpl> get copyWith =>
      __$$ImportStateImplCopyWithImpl<_$ImportStateImpl>(this, _$identity);
}

abstract class _ImportState implements ImportState {
  const factory _ImportState(
      {final String url,
      final ImportStatus status,
      final List<SitemapPage> allPages,
      final List<String> deselectedUrls,
      final String resourceName,
      final String description,
      final int maxDepth,
      final bool isAdvanced,
      final String? errorMessage}) = _$ImportStateImpl;

  @override
  String get url;
  @override
  ImportStatus get status;
  @override
  List<SitemapPage>
      get allPages; // URLs of pages the user has deselected; everything else is selected.
// URL-based (not index-based) so reordering in advanced mode doesn't affect selection.
  @override
  List<String> get deselectedUrls;
  @override
  String get resourceName;
  @override
  String get description;
  @override
  int get maxDepth;
  @override
  bool get isAdvanced;
  @override
  String? get errorMessage;

  /// Create a copy of ImportState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportStateImplCopyWith<_$ImportStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
