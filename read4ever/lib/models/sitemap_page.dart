import 'package:freezed_annotation/freezed_annotation.dart';

part 'sitemap_page.freezed.dart';

@freezed
class SitemapPage with _$SitemapPage {
  const factory SitemapPage({
    required String url,
    required String title,
  }) = _SitemapPage;
}
