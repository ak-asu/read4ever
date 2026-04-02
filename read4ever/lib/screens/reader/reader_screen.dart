import 'package:drift/drift.dart' show Value, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../db/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/reader_provider.dart';
import '../../services/sitemap_service.dart';
import '../../theme/app_colors.dart';
import 'reader_toolbar.dart';
import 'widgets/reader_error_state.dart';
import 'widgets/temp_chapter_banner.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final int chapterId;
  final ReaderContext readerContext;

  const ReaderScreen({
    super.key,
    required this.chapterId,
    required this.readerContext,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  InAppWebViewController? _webViewController;

  // Error state
  bool _showErrorState = false;
  bool _lastLoadHadError = false;

  // Original chapter data — set once in _init, never changes for this screen
  String? _chapterUrl;
  int? _resourceId;

  // Temp chapter mode — non-null when WebView is showing a URL that isn't in
  // the current resource (user clicked an outbound link).
  String? _tempChapterUrl;
  String? _tempChapterTitle;

  (int, ReaderContext) get _args => (widget.chapterId, widget.readerContext);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = ref.read(appDatabaseProvider);
    final chapter = await db.chaptersDao.getById(widget.chapterId);
    if (!mounted) return;
    setState(() {
      _chapterUrl = chapter.url;
      _resourceId = chapter.resourceId;
    });
    await db.resourcesDao.updateLastOpened(chapter.resourceId, chapter.id);
  }

  // ── Navigation intercept ─────────────────────────────────────────────────

  Future<NavigationActionPolicy> _handleNavigation(
    NavigationAction navigationAction,
  ) async {
    // Only intercept main-frame navigations.
    if (!navigationAction.isForMainFrame) {
      return NavigationActionPolicy.ALLOW;
    }

    final uri = navigationAction.request.url;
    if (uri == null) return NavigationActionPolicy.ALLOW;
    final url = uri.toString();

    // Allow javascript: and about: URIs (page-internal, not real navigation).
    if (url.startsWith('javascript:') || url.startsWith('about:')) {
      return NavigationActionPolicy.ALLOW;
    }

    // Always allow our own programmatic loads (initial URL, temp URL, dismiss).
    if (url == _chapterUrl) {
      // If we're returning to the original chapter URL (e.g., user clicked a
      // back-link while in temp mode), exit temp mode.
      if (_tempChapterUrl != null) {
        setState(() {
          _tempChapterUrl = null;
          _tempChapterTitle = null;
        });
      }
      return NavigationActionPolicy.ALLOW;
    }
    if (url == _tempChapterUrl) return NavigationActionPolicy.ALLOW;

    // Allow anchor-only changes — same page, just a scroll.
    if (_isSamePageAnchor(_tempChapterUrl ?? _chapterUrl, url)) {
      return NavigationActionPolicy.CANCEL; // let JS handle the scroll
    }

    // Non-HTTP/S URLs can't be opened in the WebView.
    if (!SitemapService().isValidUrl(url)) {
      _promptExternalUrl(url);
      return NavigationActionPolicy.CANCEL;
    }

    // Check if the URL matches an existing chapter (any resource).
    final normalized = _normalizeUrl(url);
    final db = ref.read(appDatabaseProvider);
    final existing = await db.chaptersDao.findByUrl(normalized);

    if (existing != null) {
      if (mounted) {
        context.pushReplacement(
          '/reader/${existing.id}',
          extra: ReaderContext(source: widget.readerContext.source),
        );
      }
      return NavigationActionPolicy.CANCEL;
    }

    // New URL — load it in the WebView and show the "add to library?" banner.
    _loadTempChapter(url);
    return NavigationActionPolicy.CANCEL;
  }

  void _loadTempChapter(String url) {
    // Set _tempChapterUrl synchronously before calling loadUrl so that when
    // shouldOverrideUrlLoading fires for the loadUrl call, the allow-check
    // for `url == _tempChapterUrl` passes.
    _tempChapterUrl = url;
    _tempChapterTitle = null;
    setState(() {});
    _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  Future<void> _dismissTempChapter() async {
    _tempChapterUrl = null;
    _tempChapterTitle = null;
    setState(() {});
    if (_chapterUrl != null) {
      await _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(_chapterUrl!)),
      );
    }
  }

  Future<void> _addTempChapterToResource() async {
    if (_tempChapterUrl == null || _resourceId == null) return;
    final db = ref.read(appDatabaseProvider);

    // Find the highest chapter position so we can append at the end.
    final existing = await (db.select(db.chapters)
          ..where((c) => c.resourceId.equals(_resourceId!))
          ..orderBy([(c) => OrderingTerm.desc(c.position)])
          ..limit(1))
        .get();
    final nextPosition = existing.isEmpty ? 0 : existing.first.position + 1;

    final normalizedUrl = _normalizeUrl(_tempChapterUrl!);
    final title = (_tempChapterTitle?.isNotEmpty ?? false)
        ? _tempChapterTitle!
        : normalizedUrl;

    final newChapterId = await db.chaptersDao.insertChapter(ChaptersCompanion(
      resourceId: Value(_resourceId!),
      title: Value(title),
      url: Value(normalizedUrl),
      position: Value(nextPosition),
      createdAt: Value(DateTime.now()),
    ));

    if (mounted) {
      context.pushReplacement(
        '/reader/$newChapterId',
        extra: widget.readerContext,
      );
    }
  }

  // ── Page load callbacks ──────────────────────────────────────────────────

  Future<void> _onPageLoaded(InAppWebViewController controller) async {
    ref.read(readerNotifierProvider(_args).notifier).setLoading(false);

    // Android loads its native error page after onReceivedError, which fires
    // onLoadStop — skip everything so the overlay stays and the title is safe.
    if (_lastLoadHadError) return;

    final title = await controller.getTitle() ?? '';

    if (_tempChapterUrl != null) {
      // In temp mode — update the banner title but don't touch the chapter record.
      if (mounted && title.isNotEmpty) {
        setState(() => _tempChapterTitle = title);
      }
      return;
    }

    // Back to real chapter — clear any lingering error overlay.
    if (mounted) setState(() => _showErrorState = false);

    if (title.isNotEmpty && mounted) {
      await ref
          .read(appDatabaseProvider)
          .chaptersDao
          .updateTitle(widget.chapterId, title);
    }
    // Step 8 will add: inject selection_listener.js + highlight_restore.js
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns true when [newUrl] differs from [currentUrl] only in its fragment
  /// (anchor navigation within the same page).
  bool _isSamePageAnchor(String? currentUrl, String newUrl) {
    if (currentUrl == null) return false;
    try {
      final a = Uri.parse(currentUrl);
      final b = Uri.parse(newUrl);
      return a.scheme == b.scheme &&
          a.host == b.host &&
          a.port == b.port &&
          a.path == b.path &&
          a.query == b.query;
    } catch (_) {
      return false;
    }
  }

  /// Strips fragment and trailing slash — used before querying the DB and
  /// before storing a temp chapter URL.
  String _normalizeUrl(String url) {
    var result = url.contains('#') ? url.substring(0, url.indexOf('#')) : url;
    if (result.endsWith('/')) result = result.substring(0, result.length - 1);
    return result;
  }

  void _promptExternalUrl(String url) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Open external link?'),
        content: const Text("This link can't be opened inside the app."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uri = Uri.tryParse(url);
              if (uri != null) {
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {
                  // Swallow if the OS can't handle the scheme.
                }
              }
            },
            child: const Text('Open in browser'),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_chapterUrl == null || _resourceId == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final readerState = ref.watch(readerNotifierProvider(_args));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ReaderToolbar(
              chapterId: widget.chapterId,
              resourceId: _resourceId!,
              readerContext: widget.readerContext,
              // In temp mode, back returns to original chapter instead of
              // popping the reader screen entirely.
              onBack: _tempChapterUrl != null ? _dismissTempChapter : null,
            ),
            AnimatedOpacity(
              opacity: readerState.isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.accent,
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest:
                        URLRequest(url: WebUri(_chapterUrl!)),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      supportZoom: false,
                      transparentBackground: false,
                      // Required for shouldOverrideUrlLoading to fire.
                      useShouldOverrideUrlLoading: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      return await _handleNavigation(navigationAction);
                    },
                    onLoadStart: (controller, url) {
                      _lastLoadHadError = false;
                      ref
                          .read(readerNotifierProvider(_args).notifier)
                          .setLoading(true);
                    },
                    onLoadStop: (controller, url) async {
                      await _onPageLoaded(controller);
                    },
                    onReceivedError: (controller, request, error) {
                      if (!(request.isForMainFrame ?? false)) return;
                      _lastLoadHadError = true;
                      if (mounted) setState(() => _showErrorState = true);
                      ref
                          .read(readerNotifierProvider(_args).notifier)
                          .setLoading(false);
                    },
                  ),
                  if (_showErrorState)
                    Positioned.fill(
                      child: ReaderErrorState(
                          webViewController: _webViewController),
                    ),
                ],
              ),
            ),
            if (_tempChapterUrl != null)
              TempChapterBanner(
                pageTitle: _tempChapterTitle,
                onAdd: _addTempChapterToResource,
                onDismiss: _dismissTempChapter,
              ),
          ],
        ),
      ),
    );
  }
}
