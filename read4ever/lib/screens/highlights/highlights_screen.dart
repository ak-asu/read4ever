import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/highlight_with_chapter_and_resource.dart';
import '../../providers/database_provider.dart';
import '../../providers/highlights_provider.dart';
import '../../providers/multi_select_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/highlight_bottom_sheet.dart';
import 'widgets/highlight_list_item.dart';

class HighlightsScreen extends ConsumerWidget {
  const HighlightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(highlightsProvider);
    final filter = ref.watch(highlightFilterNotifierProvider);
    final filterNotifier = ref.read(highlightFilterNotifierProvider.notifier);

    final selected = ref.watch(highlightsMultiSelectProvider);
    final selectNotifier = ref.read(highlightsMultiSelectProvider.notifier);
    final isMultiSelect = selected.isNotEmpty;

    return allAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (all) {
        // ── Apply filter ──────────────────────────────────────────────────
        final filtered = all.where((item) {
          if (filter.resourceId != null &&
              item.resource.id != filter.resourceId) {
            return false;
          }
          if (filter.chapterId != null && item.chapter.id != filter.chapterId) {
            return false;
          }
          return true;
        }).toList();

        final filteredIds = filtered.map((item) => item.highlight.id).toList();

        // ── Derive unique resources + chapters for filter pickers ─────────
        final resourceMap = <int, String>{};
        for (final item in all) {
          resourceMap[item.resource.id] = item.resource.title;
        }

        // Chapters available for chapter picker — scoped to selected resource
        final chapterMap = <int, String>{};
        for (final item in all) {
          if (filter.resourceId == null ||
              item.resource.id == filter.resourceId) {
            chapterMap[item.chapter.id] = item.chapter.title;
          }
        }

        final selectedResourceName =
            filter.resourceId != null ? resourceMap[filter.resourceId] : null;
        final selectedChapterName =
            filter.chapterId != null ? chapterMap[filter.chapterId] : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Multi-select action bar ───────────────────────────────────
            if (isMultiSelect)
              _MultiSelectBar(
                count: selected.length,
                onSelectAll: () => selectNotifier.selectAll(filteredIds),
                onClear: selectNotifier.clear,
                onDelete: () => _confirmBulkDelete(
                  context,
                  ref,
                  selected.toList(),
                  selectNotifier,
                ),
              ),

            // ── Filter bar — shown only when there are highlights ─────────
            if (all.isNotEmpty && !isMultiSelect)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(selectedResourceName ?? 'All resources'),
                      selected: filter.resourceId != null,
                      onSelected: (_) => _showResourcePicker(
                        context,
                        resourceMap,
                        filter.resourceId,
                        filterNotifier,
                      ),
                      selectedColor: AppColors.accentSubtle,
                      checkmarkColor: AppColors.accent,
                      showCheckmark: false,
                      avatar: filter.resourceId != null
                          ? const Icon(Icons.close, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(selectedChapterName ?? 'All chapters'),
                      selected: filter.chapterId != null,
                      onSelected: chapterMap.isEmpty
                          ? null
                          : (_) => _showChapterPicker(
                                context,
                                chapterMap,
                                filter.chapterId,
                                filterNotifier,
                              ),
                      selectedColor: AppColors.accentSubtle,
                      checkmarkColor: AppColors.accent,
                      showCheckmark: false,
                      avatar: filter.chapterId != null
                          ? const Icon(Icons.close, size: 14)
                          : null,
                    ),
                  ],
                ),
              ),

            // ── List or empty state ───────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(context, all.isEmpty)
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        final id = item.highlight.id;
                        return HighlightListItem(
                          key: ValueKey(id),
                          item: item,
                          onTap: () => _showDetailSheet(ctx, item),
                          onLongPress: () => selectNotifier.toggle(id),
                          isMultiSelectMode: isMultiSelect,
                          isSelected: selected.contains(id),
                          onToggleSelect: () => selectNotifier.toggle(id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Filter pickers ────────────────────────────────────────────────────────

  void _showResourcePicker(
    BuildContext context,
    Map<int, String> resourceMap,
    int? currentId,
    HighlightFilterNotifier notifier,
  ) {
    if (currentId != null) {
      notifier.setResource(null);
      notifier.setChapter(null);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          const _SheetHeader(title: 'Filter by resource'),
          ...resourceMap.entries.map(
            (e) => ListTile(
              title: Text(e.value),
              trailing: currentId == e.key
                  ? Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () {
                notifier.setResource(e.key);
                notifier.setChapter(null);
                Navigator.of(ctx).pop();
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showChapterPicker(
    BuildContext context,
    Map<int, String> chapterMap,
    int? currentId,
    HighlightFilterNotifier notifier,
  ) {
    if (currentId != null) {
      notifier.setChapter(null);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          const _SheetHeader(title: 'Filter by chapter'),
          ...chapterMap.entries.map(
            (e) => ListTile(
              title: Text(e.value),
              trailing: currentId == e.key
                  ? Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () {
                notifier.setChapter(e.key);
                Navigator.of(ctx).pop();
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showDetailSheet(
    BuildContext context,
    HighlightWithChapterAndResource item,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => HighlightBottomSheet(item: item),
    );
  }

  Future<void> _confirmBulkDelete(
    BuildContext context,
    WidgetRef ref,
    List<int> ids,
    MultiSelectNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete highlights?'),
        content: Text(
          'Delete ${ids.length} highlight${ids.length == 1 ? '' : 's'}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).highlightsDao.bulkDelete(ids);
      notifier.clear();
    }
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, bool noHighlightsAtAll) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.highlight_alt_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              noHighlightsAtAll
                  ? 'No highlights yet'
                  : 'No highlights match this filter',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              noHighlightsAtAll
                  ? 'Select text in the reader to highlight it'
                  : 'Try clearing the filter to see all highlights',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Multi-select action bar ───────────────────────────────────────────────────

class _MultiSelectBar extends StatelessWidget {
  final int count;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback onDelete;

  const _MultiSelectBar({
    required this.count,
    required this.onSelectAll,
    required this.onClear,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Material(
      elevation: 2,
      color: barColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Clear selection',
            onPressed: onClear,
          ),
          Text(
            '$count selected',
            style: theme.textTheme.titleSmall,
          ),
          const Spacer(),
          TextButton(
            onPressed: onSelectAll,
            child: const Text('Select all'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete selected',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// Small header widget for the filter picker bottom sheets
class _SheetHeader extends StatelessWidget {
  final String title;
  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
