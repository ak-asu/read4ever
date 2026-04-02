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
                      ref
                          .read(readerNotifierProvider(_args).notifier)
                          .setLoading(true);
                      if (mounted) setState(() => _showErrorState = false);
                    },
                    onLoadStop: (controller, url) async {
                      await _onPageLoaded(controller);
                    },
                    onReceivedError: (controller, request, error) {
                      if (mounted) setState(() => _showErrorState = true);
                      ref
                          .read(readerNotifierProvider(_args).notifier)
                          .setLoading(false);
                    },
                  ),
                  if (_showErrorState)
                    ReaderErrorState(webViewController: _webViewController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
