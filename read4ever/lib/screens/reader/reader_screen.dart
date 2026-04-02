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

  // Original chapter data — set once in _init
  String? _chapterUrl;
  int? _resourceId;

  // "Effective" chapter — starts as widget.chapterId but switches to a newly
  // inserted chapter ID when the user adds a temp chapter in-place. The toolbar
  // watches this ID so it reflects the page currently shown in the WebView.
  int? _effectiveChapterId;

  // Temp mode — non-null when the WebView is showing a URL that isn't (yet)
  // in the library. Cleared when the chapter is added or dismissed.
  String? _tempChapterUrl;
  String? _tempChapterTitle;

  bool get _isInTempMode => _tempChapterUrl != null;

  (int, ReaderContext) get _args => (widget.chapterId, widget.readerContext);

  @override
  void initState() {
    super.initState();
    _effectiveChapterId = widget.chapterId;
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
    if (!navigationAction.isForMainFrame) return NavigationActionPolicy.ALLOW;

    final uri = navigationAction.request.url;
    if (uri == null) return NavigationActionPolicy.ALLOW;
    final url = uri.toString();

    // Allow in-page JS / blank targets.
    if (url.startsWith('javascript:') || url.startsWith('about:')) {
      return NavigationActionPolicy.ALLOW;
    }

    final normalizedUrl = _normalizeUrl(url);
    final normalizedChapterUrl =
        _chapterUrl != null ? _normalizeUrl(_chapterUrl!) : null;

    // ── Allow our own programmatic loads ──────────────────────────────────
    // Use normalized comparison so trailing-slash differences don't break
    // the check (the most common cause of the redirect-loop bug).
    if (normalizedUrl == normalizedChapterUrl) {
      if (_isInTempMode) {
        setState(() {
          _tempChapterUrl = null;
          _tempChapterTitle = null;
        });
      }
      return NavigationActionPolicy.ALLOW;
    }

    // Allow temp chapter URL (set before calling loadUrl so this fires first).
    if (_tempChapterUrl != null &&
        normalizedUrl == _normalizeUrl(_tempChapterUrl!)) {
      return NavigationActionPolicy.ALLOW;
    }

    // ── Anchor-only navigation: ALLOW (WebView handles the scroll) ─────────
    if (_isSamePageAnchor(_tempChapterUrl ?? _chapterUrl, url)) {
      return NavigationActionPolicy.ALLOW;
    }

    // ── Non-HTTP/S: prompt external app ──────────────────────────────────
    if (!SitemapService().isValidUrl(url)) {
      _promptExternalUrl(url);
      return NavigationActionPolicy.CANCEL;
    }

    // ── Check for existing chapter match (any resource) ──────────────────
    final db = ref.read(appDatabaseProvider);
    // Try both the normalized URL and the URL with a trailing slash, since
    // stored URLs may or may not have a trailing slash.
    final existing = await db.chaptersDao.findByUrl(normalizedUrl) ??
        await db.chaptersDao.findByUrl('$normalizedUrl/');

    if (existing != null) {
      // If it matches the chapter already showing, just allow the load.
      if (existing.id == _effectiveChapterId) {
        return NavigationActionPolicy.ALLOW;
      }
      if (mounted) {
        context.pushReplacement(
          '/reader/${existing.id}',
          extra: ReaderContext(source: widget.readerContext.source),
        );
      }
      return NavigationActionPolicy.CANCEL;
    }

    // ── New URL: show as temp chapter with banner ─────────────────────────
    _loadTempChapter(url);
    return NavigationActionPolicy.CANCEL;
  }

  void _loadTempChapter(String url) {
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

  /// Inserts the current temp page as a real chapter and updates
  /// [_effectiveChapterId] so the toolbar immediately reflects it.
  /// Returns the new chapter ID, or null on failure.
  Future<int?> _addTempChapterInPlace() async {
    if (_tempChapterUrl == null || _resourceId == null) return null;
    final db = ref.read(appDatabaseProvider);

    final allChapters = await (db.select(db.chapters)
          ..where((c) => c.resourceId.equals(_resourceId!))
          ..orderBy([(c) => OrderingTerm.desc(c.position)])
          ..limit(1))
        .get();
    final nextPosition =
        allChapters.isEmpty ? 0 : allChapters.first.position + 1;

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

    await db.resourcesDao.updateLastOpened(_resourceId!, newChapterId);

    if (mounted) {
      setState(() {
        _effectiveChapterId = newChapterId;
        _tempChapterUrl = null;
        _tempChapterTitle = null;
      });
    }
    return newChapterId;
  }

  // ── Toolbar action handlers (auto-add in temp mode) ─────────────────────

  Future<void> _handleBookmarkToggle() async {
    if (_isInTempMode) await _addTempChapterInPlace();
    final id = _effectiveChapterId;
    if (id != null) {
      await ref.read(appDatabaseProvider).chaptersDao.toggleBookmark(id);
    }
  }

  Future<void> _handleDoneToggle(bool currentIsDone) async {
    if (_isInTempMode) await _addTempChapterInPlace();
    final id = _effectiveChapterId;
    if (id != null) {
      await ref
          .read(appDatabaseProvider)
          .chaptersDao
          .setDone(id, !currentIsDone);
    }
  }

  // ── Page load callbacks ──────────────────────────────────────────────────

  Future<void> _onPageLoaded(InAppWebViewController controller) async {
    ref.read(readerNotifierProvider(_args).notifier).setLoading(false);

    if (_lastLoadHadError) return;

    final title = await controller.getTitle() ?? '';

    if (_isInTempMode) {
      if (mounted && title.isNotEmpty)
        setState(() => _tempChapterTitle = title);
      return;
    }

    if (mounted) setState(() => _showErrorState = false);

    if (title.isNotEmpty && mounted) {
      await ref
          .read(appDatabaseProvider)
          .chaptersDao
          .updateTitle(_effectiveChapterId ?? widget.chapterId, title);
    }
    // Step 8 will add: jsBridge.injectScripts() + highlightService.restoreForChapter()
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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
                } catch (_) {}
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
    if (_chapterUrl == null ||
        _resourceId == null ||
        _effectiveChapterId == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final readerState = ref.watch(readerNotifierProvider(_args));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ReaderToolbar(
              chapterId: _effectiveChapterId!,
              resourceId: _resourceId!,
              readerContext: widget.readerContext,
              onBack: _isInTempMode ? _dismissTempChapter : null,
              // Temp mode: override all state so the original chapter's
              // bookmark/done don't bleed through.
              titleOverride: _isInTempMode ? (_tempChapterTitle ?? '') : null,
              bookmarkOverride: _isInTempMode ? false : null,
              doneOverride: _isInTempMode ? false : null,
              onBookmarkToggle: _isInTempMode ? _handleBookmarkToggle : null,
              onDoneToggle: _isInTempMode ? _handleDoneToggle : null,
              // Passes the temp title to the chapter dropdown so it renders
              // the phantom "currently viewing" entry at the top.
              tempChapterTitle:
                  _isInTempMode ? (_tempChapterTitle ?? '') : null,
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
                    initialUrlRequest: URLRequest(url: WebUri(_chapterUrl!)),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      supportZoom: false,
                      transparentBackground: false,
                      useShouldOverrideUrlLoading: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    shouldOverrideUrlLoading: (controller, action) async =>
                        await _handleNavigation(action),
                    onLoadStart: (controller, url) {
                      _lastLoadHadError = false;
                      ref
                          .read(readerNotifierProvider(_args).notifier)
                          .setLoading(true);
                    },
                    onLoadStop: (controller, url) async =>
                        await _onPageLoaded(controller),
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
            if (_isInTempMode)
              TempChapterBanner(
                pageTitle: _tempChapterTitle,
                onAdd: () => _addTempChapterInPlace(),
                onDismiss: _dismissTempChapter,
              ),
          ],
        ),
      ),
    );
  }
}
