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

  /// Tries three discovery strategies in order:
  ///   1. GET {baseUrl}/sitemap.xml
  ///   2. GET {baseUrl}/sitemap_index.xml
  ///   3. GET {baseUrl} → parse <link rel="sitemap"> from <head>
  ///
  /// Returns null if all strategies fail or the result is empty.
  Future<List<SitemapPage>?> discover(String url, {int maxDepth = 2}) async {
    final baseUrl = _normalizeBase(url);

    // Strategy 1 & 2: well-known paths
    for (final path in ['/sitemap.xml', '/sitemap_index.xml']) {
      final candidate = '$baseUrl$path';
      final pages = await _tryParseSitemap(candidate, maxDepth: maxDepth);
      if (pages != null && pages.isNotEmpty) return pages;
    }

    // Strategy 3: scrape <link rel="sitemap"> from the page itself
    final linkedSitemapUrl = await _discoverFromPage(url);
    if (linkedSitemapUrl != null) {
      final pages =
          await _tryParseSitemap(linkedSitemapUrl, maxDepth: maxDepth);
      if (pages != null && pages.isNotEmpty) return pages;
    }

    return null;
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

  /// Public for testing. Handles both <sitemapindex> and <urlset>.
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
      return _parseSitemapIndex(root, currentDepth: currentDepth, maxDepth: maxDepth);
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
    return root.findAllElements('url').map((urlEl) {
      final loc = urlEl.findElements('loc').firstOrNull?.innerText.trim() ?? '';
      final title = _titleFromUrl(loc);
      return SitemapPage(url: loc, title: title);
    }).where((p) => p.url.isNotEmpty).toList();
  }

  /// Fetches the page and looks for <link rel="sitemap" href="..."> in <head>.
  Future<String?> _discoverFromPage(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      // Lightweight regex scan — no need for a full HTML parser for a single tag
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
      // Resolve relative hrefs against the base URL
      return Uri.parse(url).resolve(href).toString();
    } catch (_) {
      return null;
    }
  }

  /// Strips trailing slashes and paths to get the base origin.
  String _normalizeBase(String url) {
    final uri = Uri.parse(url.trim());
    return '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 && uri.port != 0 ? ':${uri.port}' : ''}';
  }

  /// Derives a human-readable title from a URL path segment.
  /// e.g. /docs/getting-started → "Getting Started"
  String _titleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments =
          uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) return uri.host;
      final last = segments.last;
      return last
          .replaceAll(RegExp(r'[-_]'), ' ')
          .replaceAll(RegExp(r'\.\w+$'), '') // strip .html etc.
          .split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
    } catch (_) {
      return url;
    }
  }
}
