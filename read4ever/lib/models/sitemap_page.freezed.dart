// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sitemap_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SitemapPage {
  String get url => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Create a copy of SitemapPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SitemapPageCopyWith<SitemapPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SitemapPageCopyWith<$Res> {
  factory $SitemapPageCopyWith(
          SitemapPage value, $Res Function(SitemapPage) then) =
      _$SitemapPageCopyWithImpl<$Res, SitemapPage>;
  @useResult
  $Res call({String url, String title});
}

/// @nodoc
class _$SitemapPageCopyWithImpl<$Res, $Val extends SitemapPage>
    implements $SitemapPageCopyWith<$Res> {
  _$SitemapPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SitemapPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? title = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SitemapPageImplCopyWith<$Res>
    implements $SitemapPageCopyWith<$Res> {
  factory _$$SitemapPageImplCopyWith(
          _$SitemapPageImpl value, $Res Function(_$SitemapPageImpl) then) =
      __$$SitemapPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String title});
}

/// @nodoc
class __$$SitemapPageImplCopyWithImpl<$Res>
    extends _$SitemapPageCopyWithImpl<$Res, _$SitemapPageImpl>
    implements _$$SitemapPageImplCopyWith<$Res> {
  __$$SitemapPageImplCopyWithImpl(
      _$SitemapPageImpl _value, $Res Function(_$SitemapPageImpl) _then)
      : super(_value, _then);

  /// Create a copy of SitemapPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? title = null,
  }) {
    return _then(_$SitemapPageImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SitemapPageImpl implements _SitemapPage {
  const _$SitemapPageImpl({required this.url, required this.title});

  @override
  final String url;
  @override
  final String title;

  @override
  String toString() {
    return 'SitemapPage(url: $url, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SitemapPageImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title));
  }

  @override
  int get hashCode => Object.hash(runtimeType, url, title);

  /// Create a copy of SitemapPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SitemapPageImplCopyWith<_$SitemapPageImpl> get copyWith =>
      __$$SitemapPageImplCopyWithImpl<_$SitemapPageImpl>(this, _$identity);
}

abstract class _SitemapPage implements SitemapPage {
  const factory _SitemapPage(
      {required final String url,
      required final String title}) = _$SitemapPageImpl;

  @override
  String get url;
  @override
  String get title;

  /// Create a copy of SitemapPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SitemapPageImplCopyWith<_$SitemapPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
