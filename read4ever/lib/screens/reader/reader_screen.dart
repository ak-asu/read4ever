import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/reader_provider.dart';
import '../../theme/app_colors.dart';
import 'reader_toolbar.dart';
import 'widgets/reader_error_state.dart';

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
  bool _showErrorState = false;
  // Tracks whether the most recent load attempt ended with an error. Reset on
  // every onLoadStart so we can distinguish "retry succeeded" from "error page
  // finished loading" when onLoadStop fires.
  bool _lastLoadHadError = false;
  String? _chapterUrl;
  int? _resourceId;

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
    // Track which resource/chapter the user is currently reading.
    await db.resourcesDao.updateLastOpened(chapter.resourceId, chapter.id);
  }

  Future<void> _onPageLoaded(InAppWebViewController controller) async {
    ref.read(readerNotifierProvider(_args).notifier).setLoading(false);
    // If the load ended with an error, onReceivedError already set
    // _lastLoadHadError = true. Android then loads its native error page, which
    // fires onLoadStop — we skip here so the overlay stays and the title is
    // not clobbered. On a successful retry _lastLoadHadError is false, so we
    // fall through, clear the overlay, and update the title normally.
    if (_lastLoadHadError) return;
    if (mounted) setState(() => _showErrorState = false);

    final title = await controller.getTitle() ?? '';
    if (title.isNotEmpty && mounted) {
      await ref
          .read(appDatabaseProvider)
          .chaptersDao
          .updateTitle(widget.chapterId, title);
    }
    // Step 8 will add: inject selection_listener.js + highlight_restore.js
  }

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
            ),
            // Thin loading indicator — always in the tree, opacity controlled
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
                    initialUrlRequest: URLRequest(
                      url: WebUri(_chapterUrl!),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      supportZoom: false,
                      transparentBackground: false,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      _lastLoadHadError = false; // reset for each new navigation
                      ref
                          .read(readerNotifierProvider(_args).notifier)
                          .setLoading(true);
                      // Don't clear _showErrorState here — keep the overlay
                      // visible during retry until the page successfully loads.
                    },
                    onLoadStop: (controller, url) async {
                      await _onPageLoaded(controller);
                    },
                    onReceivedError: (controller, request, error) {
                      // Only handle main-frame failures.
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
          ],
        ),
      ),
    );
  }
}
