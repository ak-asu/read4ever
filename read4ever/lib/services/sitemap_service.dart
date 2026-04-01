import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/sitemap_page.dart';

class SitemapService {
  final http.Client _client;

  SitemapService({http.Client? client}) : _client = client ?? http.Client();

  /// Rejects empty strings, non-HTTP/S schemes, and malformed URIs.
  bool isValidUrl(String url) {
    if (url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    if (!uri.hasScheme || !uri.hasAuthority) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    return true;
  }

  /// Tries five discovery strategies in order:
  ///   1. GET {baseUrl}/robots.txt → parse `Sitemap:` directive
  ///   2. GET {baseUrl}/sitemap.xml
  ///   3. GET {baseUrl}/sitemap_index.xml
  ///   4. GET {url} → parse `<link rel="sitemap">` from `<head>`
  ///   5. GET {url} → extract same-origin `<a href>` links (fallback for sites with no sitemap)
  ///
  /// Returns null if all strategies fail or the result is empty.
  Future<List<SitemapPage>?> discover(String url, {int maxDepth = 2}) async {
    final baseUrl = _normalizeBase(url);

    // Strategy 1: robots.txt — most reliable; nearly all doc sites list sitemap here
    final robotsSitemapUrl = await _discoverFromRobots(baseUrl);
    if (robotsSitemapUrl != null) {
      final pages =
          await _tryParseSitemap(robotsSitemapUrl, maxDepth: maxDepth);
      if (pages != null && pages.isNotEmpty) return pages;
    }

    // Strategy 2 & 3: well-known paths
    for (final path in ['/sitemap.xml', '/sitemap_index.xml']) {
      final candidate = '$baseUrl$path';
      final pages = await _tryParseSitemap(candidate, maxDepth: maxDepth);
      if (pages != null && pages.isNotEmpty) return pages;
    }

    // Strategy 4: scrape `<link rel="sitemap">` from the page itself
    final linkedSitemapUrl = await _discoverFromPage(url);
    if (linkedSitemapUrl != null) {
      final pages =
          await _tryParseSitemap(linkedSitemapUrl, maxDepth: maxDepth);
      if (pages != null && pages.isNotEmpty) return pages;
    }

    // Strategy 5: extract same-origin <a href> links — catches doc sites with no sitemap
    return _discoverFromLinks(url);
  }

  /// Fetches [url] and extracts all same-origin `<a href>` links.
  /// Used as a last-resort fallback for documentation sites that skip sitemap generation.
  Future<List<SitemapPage>?> _discoverFromLinks(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final baseUri = Uri.parse(url);
      final hrefPattern = RegExp(
        '<a[^>]+href=["\']([^"\']+)["\']',
        caseSensitive: false,
      );
      final assetExtensions = RegExp(
        r'\.(css|js|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|eot|pdf|zip)(\?.*)?$',
        caseSensitive: false,
      );

      final seen = <String>{};
      final pages = <SitemapPage>[];

      for (final match in hrefPattern.allMatches(response.body)) {
        final href = match.group(1)!.trim();
        if (href.isEmpty ||
            href.startsWith('#') ||
            href.startsWith('mailto:') ||
            href.startsWith('javascript:')) {
          continue;
        }

        final resolved = baseUri.resolve(href);
        if (resolved.host != baseUri.host) continue;
        if (assetExtensions.hasMatch(resolved.path)) continue;

        // Strip query, fragment, and trailing slash for dedup
        final normalized = resolved
            .toString()
            .split('?')[0]
            .split('#')[0]
            .replaceAll(RegExp(r'/$'), '');
        if (seen.contains(normalized)) continue;
        seen.add(normalized);

        pages.add(
            SitemapPage(url: normalized, title: _titleFromUrl(normalized)));
      }

      return pages.isEmpty ? null : pages;
    } catch (_) {
      return null;
    }
  }

  /// Fetches robots.txt and extracts the first `Sitemap:` directive.
  Future<String?> _discoverFromRobots(String baseUrl) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/robots.txt'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      for (final line in response.body.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.toLowerCase().startsWith('sitemap:')) {
          final sitemapUrl = trimmed.substring('sitemap:'.length).trim();
          if (sitemapUrl.isNotEmpty) return sitemapUrl;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetches and parses a sitemap URL. Returns null on any network/parse error.
  Future<List<SitemapPage>?> _tryParseSitemap(
    String sitemapUrl, {
    required int maxDepth,
  }) async {
    try {
      return await parseSitemap(sitemapUrl,
          currentDepth: 0, maxDepth: maxDepth);
    } catch (_) {
      return null;
    }
  }

  /// Public for testing. Handles both `<sitemapindex>` and `<urlset>`.
  Future<List<SitemapPage>> parseSitemap(
    String sitemapUrl, {
    int currentDepth = 0,
    required int maxDepth,
  }) async {
    final response = await _client
        .get(Uri.parse(sitemapUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return [];

    final document = XmlDocument.parse(response.body);
    final root = document.rootElement;

    if (root.name.local == 'sitemapindex') {
      return _parseSitemapIndex(root,
          currentDepth: currentDepth, maxDepth: maxDepth);
    } else if (root.name.local == 'urlset') {
      return _parseUrlset(root);
    }

    return [];
  }

  Future<List<SitemapPage>> _parseSitemapIndex(
    XmlElement root, {
    required int currentDepth,
    required int maxDepth,
  }) async {
    if (currentDepth >= maxDepth) return [];

    final pages = <SitemapPage>[];
    final childUrls = root
        .findAllElements('loc')
        .map((e) => e.innerText.trim())
        .where((loc) => loc.isNotEmpty)
        .toList();

    for (final childUrl in childUrls) {
      try {
        final childPages = await parseSitemap(
          childUrl,
          currentDepth: currentDepth + 1,
          maxDepth: maxDepth,
        );
        pages.addAll(childPages);
      } catch (_) {
        // skip broken child sitemaps
      }
    }

    return pages;
  }

  List<SitemapPage> _parseUrlset(XmlElement root) {
    return root
        .findAllElements('url')
        .map((urlEl) {
          final loc =
              urlEl.findElements('loc').firstOrNull?.innerText.trim() ?? '';
          return SitemapPage(url: loc, title: _titleFromUrl(loc));
        })
        .where((p) => p.url.isNotEmpty)
        .toList();
  }

  /// Fetches the page and looks for `<link rel="sitemap" href="...">` in `<head>`.
  Future<String?> _discoverFromPage(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final linkPattern = RegExp(
        '<link[^>]+rel=["\']sitemap["\'][^>]+href=["\']([^"\']+)["\']',
        caseSensitive: false,
      );
      final altPattern = RegExp(
        '<link[^>]+href=["\']([^"\']+)["\'][^>]+rel=["\']sitemap["\']',
        caseSensitive: false,
      );

      final match = linkPattern.firstMatch(response.body) ??
          altPattern.firstMatch(response.body);
      if (match == null) return null;

      final href = match.group(1)!.trim();
      return Uri.parse(url).resolve(href).toString();
    } catch (_) {
      return null;
    }
  }

  /// Strips path and port to get the base origin.
  String _normalizeBase(String url) {
    final uri = Uri.parse(url.trim());
    return '${uri.scheme}://${uri.host}'
        '${uri.port != 80 && uri.port != 443 && uri.port != 0 ? ':${uri.port}' : ''}';
  }

  /// Derives a human-readable title from the last URL path segment.
  /// e.g. `/docs/getting-started` → `"Getting Started"`
  String _titleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) return uri.host;
      final last = segments.last;
      return last
          .replaceAll(RegExp(r'[-_]'), ' ')
          .replaceAll(RegExp(r'\.\w+$'), '')
          .split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
    } catch (_) {
      return url;
    }
  }
}
