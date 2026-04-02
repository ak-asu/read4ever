import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/import_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/advanced_import_panel.dart';
import 'widgets/sitemap_chapter_list.dart';

/// Route-based entry point for `/import`. Used by the Android share intent handler (step 14).
/// Shows the import bottom sheet over a transparent scaffold and pops when the sheet closes.
/// [initialUrl] pre-fills the URL field; when set via a share intent, discovery also starts
/// automatically.
class ImportScreen extends StatefulWidget {
  final String? initialUrl;

  const ImportScreen({super.key, this.initialUrl});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showImportBottomSheet(
        context,
        initialUrl: widget.initialUrl,
        autoDiscover:
            widget.initialUrl != null && widget.initialUrl!.isNotEmpty,
      );
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}

/// Call this from any widget to open the import bottom sheet.
/// Set [autoDiscover] to true to kick off sitemap discovery immediately after
/// the sheet appears (used when a URL arrives via the Android share intent).
Future<void> showImportBottomSheet(
  BuildContext context, {
  String? initialUrl,
  List<String> excludeUrls = const [],
  bool autoDiscover = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => ImportBottomSheet(
      initialUrl: initialUrl,
      excludeUrls: excludeUrls,
      autoDiscover: autoDiscover,
    ),
  );
}

class ImportBottomSheet extends ConsumerStatefulWidget {
  /// Pre-fill the URL field — used by "Import more chapters" in Resource Detail.
  final String? initialUrl;

  /// Chapter URLs already in an existing resource; excluded from discovery results.
  final List<String> excludeUrls;

  /// When true, sitemap discovery starts automatically after the URL is set.
  /// Used when a URL arrives via the Android share intent.
  final bool autoDiscover;

  const ImportBottomSheet({
    super.key,
    this.initialUrl,
    this.excludeUrls = const [],
    this.autoDiscover = false,
  });

  @override
  ConsumerState<ImportBottomSheet> createState() => _ImportBottomSheetState();
}

class _ImportBottomSheetState extends ConsumerState<ImportBottomSheet> {
  late TextEditingController _urlController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Always initialise from widget.initialUrl (never stale provider state).
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    // Reset any stale discovery state from a previous import session, then
    // optionally sync the pre-filled URL and start auto-discovery.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(importNotifierProvider.notifier).reset();
      if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
        ref.read(importNotifierProvider.notifier).setUrl(widget.initialUrl!);
        if (widget.autoDiscover) {
          ref.read(importNotifierProvider.notifier).discover(
                context,
                excludeUrls: widget.excludeUrls,
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importNotifierProvider);
    final notifier = ref.read(importNotifierProvider.notifier);
    final isReady = state.status == ImportStatus.ready;
    final isLoading = state.status == ImportStatus.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Import resource',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // URL field + Discover button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'https://docs.example.com',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText: state.status == ImportStatus.error
                          ? state.errorMessage
                          : null,
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    onChanged: notifier.setUrl,
                    onSubmitted: (_) => _discover(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: isLoading ? null : _discover,
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Scan'),
                ),
              ],
            ),

            // Chapter list (shown when discovery is done)
            if (isReady) ...[
              const SizedBox(height: 16),

              // Chapter count summary + Advanced/Simple toggle on the same row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${state.selectedPages.length} of ${state.allPages.length} '
                      'chapter${state.allPages.length == 1 ? '' : 's'} selected',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: secondaryColor),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: notifier.toggleAdvanced,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      textStyle: Theme.of(context).textTheme.labelMedium,
                    ),
                    icon: Icon(
                      state.isAdvanced ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                    ),
                    label: Text(state.isAdvanced ? 'Simple' : 'Advanced'),
                    iconAlignment: IconAlignment.end,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Simple mode: checkbox list
              if (!state.isAdvanced) const SitemapChapterList(),

              // Advanced mode: form fields (name/desc/depth) then reorderable list
              if (state.isAdvanced) const AdvancedImportPanel(),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: isReady && !isLoading
                      ? () => notifier.confirm(context)
                      : null,
                  child: const Text('Import'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _discover() {
    final notifier = ref.read(importNotifierProvider.notifier);
    // Sync URL controller → state before discovery
    notifier.setUrl(_urlController.text);
    notifier.discover(context, excludeUrls: widget.excludeUrls);
  }
}
