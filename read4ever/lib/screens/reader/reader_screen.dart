import 'package:drift/drift.dart' show Value, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../db/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/reader_provider.dart';
import '../../services/js_bridge.dart';
import '../../services/highlight_service.dart';
import '../../services/sitemap_service.dart';
import '../../theme/app_colors.dart';
import 'reader_toolbar.dart';
import 'widgets/reader_error_state.dart';
import 'widgets/reader_highlight_sheet.dart';
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
  JsBridge? _jsBridge;
  HighlightService? _highlightService;
  late final ContextMenu _contextMenu;

  // Error state
  bool _showErrorState = false;
  bool _lastLoadHadError = false;

  // Original chapter data — set once in _init
  String? _chapterUrl;
  int? _resourceId;

  // "Effective" chapter — starts as widget.chapterId but switches to a newly
  // inserted chapter ID when the user adds a temp chapter in-place.
  int? _effectiveChapterId;

  // Temp mode — non-null when the WebView is showing a URL not yet in the library.
  String? _tempChapterUrl;
  String? _tempChapterTitle;

  bool get _isInTempMode => _tempChapterUrl != null;

  (int, ReaderContext) get _args => (widget.chapterId, widget.readerContext);

  @override
  void initState() {
    super.initState();
    _effectiveChapterId = widget.chapterId;
    _contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
          id: 1,
          title: 'Highlight',
          action: _onHighlightTapped,
        ),
        ContextMenuItem(
          id: 2,
          title: 'Add Note',
          action: _onAddNoteTapped,
        ),
      ],
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
    );
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

  // ── ContextMenu action handlers ──────────────────────────────────────────

  Future<void> _onHighlightTapped() async {
    final sel = await _jsBridge?.getSelection();
    if (sel == null || !mounted) return;
    final chapterId = _effectiveChapterId;
    if (chapterId == null) return;
    await _highlightService?.createHighlight(chapterId, sel);
  }

  Future<void> _onAddNoteTapped() async {
    final sel = await _jsBridge?.getSelection();
    if (sel == null || !mounted) return;
    final chapterId = _effectiveChapterId;
    if (chapterId == null) return;
    _showNoteBottomSheet(chapterId, sel);
  }

  void _showNoteBottomSheet(int chapterId, sel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // _NoteSheet owns and disposes its TextEditingController via widget
      // lifecycle — avoids the use-after-dispose race that occurs when the
      // controller is created inline and disposed in whenComplete() while the
      // sheet's closing animation is still running.
      builder: (ctx) => _NoteSheet(
        onSave: (note) async {
          await _highlightService?.createHighlight(
            chapterId,
            sel,
            note: note,
          );
        },
      ),
    );
  }

  // ── Mark tap handler ────────────────────────────────────────────────────

  Future<void> _onMarkTapped(int id) async {
    final chapterId = _effectiveChapterId;
    final service = _highlightService;
    if (chapterId == null || service == null || !mounted) return;
    final highlights = await ref
        .read(appDatabaseProvider)
        .highlightsDao
        .getByChapter(chapterId);
    final idx = highlights.indexWhere((h) => h.id == id);
    if (idx < 0 || !mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ReaderHighlightSheet(
        highlights: highlights,
        initialIndex: idx,
        highlightService: service,
      ),
    );
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
    final existing = await db.chaptersDao.findByUrl(normalizedUrl) ??
        await db.chaptersDao.findByUrl('$normalizedUrl/');

    if (existing != null) {
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
      if (mounted && title.isNotEmpty) {
        setState(() => _tempChapterTitle = title);
      }
      return;
    }

    if (mounted) setState(() => _showErrorState = false);

    if (title.isNotEmpty && mounted) {
      await ref
          .read(appDatabaseProvider)
          .chaptersDao
          .updateTitle(_effectiveChapterId ?? widget.chapterId, title);
    }

    // Inject selection + highlight scripts, then restore saved highlights.
    final bridge = _jsBridge;
    final service = _highlightService;
    final chapterId = _effectiveChapterId;
    if (bridge != null && service != null && chapterId != null) {
      await bridge.injectScripts();
      await service.restoreForChapter(chapterId);

      // If opened from the Highlights screen, scroll to the target highlight.
      final scrollToId = widget.readerContext.scrollToHighlightId;
      if (scrollToId != null) {
        await bridge.scrollToHighlight(scrollToId);
      }
    }
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

  // ── Bookmark FAB navigation ──────────────────────────────────────────────

  bool get _hasPrevBookmark {
    final ids = widget.readerContext.adjacentChapterIds;
    return widget.readerContext.source == ReaderSource.bookmarks &&
        ids != null &&
        ids.isNotEmpty &&
        ids[0] > 0;
  }

  bool get _hasNextBookmark {
    final ids = widget.readerContext.adjacentChapterIds;
    return widget.readerContext.source == ReaderSource.bookmarks &&
        ids != null &&
        ids.length > 1 &&
        ids[1] > 0;
  }

  Future<void> _navigateViaBookmarkFab(int targetChapterId) async {
    // Re-query the full bookmark list so the target chapter's adjacents are
    // correct (prevents the FABs from disappearing after the first hop).
    final db = ref.read(appDatabaseProvider);
    final bookmarks = await db.chaptersDao.getBookmarked();
    final idx = bookmarks.indexWhere((b) => b.chapter.id == targetChapterId);
    if (!mounted) return;

    final prevId = idx > 0 ? bookmarks[idx - 1].chapter.id : 0;
    final nextId =
        idx < bookmarks.length - 1 ? bookmarks[idx + 1].chapter.id : 0;

    context.pushReplacement(
      '/reader/$targetChapterId',
      extra: ReaderContext(
        source: ReaderSource.bookmarks,
        adjacentChapterIds: [prevId, nextId],
      ),
    );
  }

  Widget? _buildBookmarkFabs() {
    if (widget.readerContext.source != ReaderSource.bookmarks) return null;
    final ids = widget.readerContext.adjacentChapterIds;
    if (ids == null) return null;

    final showPrev = _hasPrevBookmark;
    final showNext = _hasNextBookmark;
    if (!showPrev && !showNext) return null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPrev) ...[
          FloatingActionButton.small(
            heroTag: 'fab_prev',
            onPressed: () => _navigateViaBookmarkFab(ids[0]),
            tooltip: 'Previous bookmark',
            child: const Icon(Icons.arrow_upward),
          ),
          const SizedBox(height: 8),
        ],
        if (showNext)
          FloatingActionButton.small(
            heroTag: 'fab_next',
            onPressed: () => _navigateViaBookmarkFab(ids[1]),
            tooltip: 'Next bookmark',
            child: const Icon(Icons.arrow_downward),
          ),
      ],
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_chapterUrl == null ||
        _resourceId == null ||
        _effectiveChapterId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final readerState = ref.watch(readerNotifierProvider(_args));

    return Scaffold(
      floatingActionButton: _buildBookmarkFabs(),
      body: SafeArea(
        child: Column(
          children: [
            ReaderToolbar(
              chapterId: _effectiveChapterId!,
              resourceId: _resourceId!,
              readerContext: widget.readerContext,
              onBack: _isInTempMode ? _dismissTempChapter : null,
              titleOverride: _isInTempMode ? (_tempChapterTitle ?? '') : null,
              bookmarkOverride: _isInTempMode ? false : null,
              doneOverride: _isInTempMode ? false : null,
              onBookmarkToggle: _isInTempMode ? _handleBookmarkToggle : null,
              onDoneToggle: _isInTempMode ? _handleDoneToggle : null,
              tempChapterTitle:
                  _isInTempMode ? (_tempChapterTitle ?? '') : null,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              constraints: BoxConstraints(
                maxHeight: readerState.isLoading ? 2.0 : 0.0,
              ),
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
                    contextMenu: _contextMenu,
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      supportZoom: false,
                      transparentBackground: false,
                      useShouldOverrideUrlLoading: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      _jsBridge = JsBridge(controller);
                      _highlightService = HighlightService(
                        highlightsDao:
                            ref.read(appDatabaseProvider).highlightsDao,
                        jsBridge: _jsBridge!,
                      );
                      controller.addJavaScriptHandler(
                        handlerName: 'onHighlightTapped',
                        callback: (args) {
                          if (args.isEmpty) return;
                          final id = (args[0] as num).toInt();
                          _onMarkTapped(id);
                        },
                      );
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

/// Bottom sheet for adding a note to a new highlight.
///
/// Owns its [TextEditingController] so Flutter disposes it via the widget
/// lifecycle — only after the sheet's closing animation completes. This avoids
/// the use-after-dispose crash that occurs when disposing in whenComplete().
class _NoteSheet extends StatefulWidget {
  final Future<void> Function(String? note) onSave;

  const _NoteSheet({required this.onSave});

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Add a note...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final note = _controller.text.trim();
                  Navigator.of(context).pop();
                  await widget.onSave(note.isEmpty ? null : note);
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
