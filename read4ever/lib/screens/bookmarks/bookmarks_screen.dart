import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bookmarks_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/multi_select_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/bookmark_list_item.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final selected = ref.watch(bookmarksMultiSelectProvider);
    final selectNotifier = ref.read(bookmarksMultiSelectProvider.notifier);
    final isMultiSelect = selected.isNotEmpty;

    return bookmarks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load bookmarks')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_border,
                    size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                Text(
                  'No bookmarks yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Bookmark chapters while reading to find them here',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final allIds = items.map((i) => i.chapter.id).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Multi-select action bar ─────────────────────────────────
            if (isMultiSelect)
              _MultiSelectBar(
                count: selected.length,
                onSelectAll: () => selectNotifier.selectAll(allIds),
                onClear: selectNotifier.clear,
                onUnbookmark: () => _confirmBulkUnbookmark(
                  context,
                  ref,
                  selected.toList(),
                  selectNotifier,
                ),
              ),

            // ── Bookmark list ───────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final prevId = index > 0 ? items[index - 1].chapter.id : 0;
                  final nextId = index < items.length - 1
                      ? items[index + 1].chapter.id
                      : 0;
                  final id = items[index].chapter.id;

                  return BookmarkListItem(
                    item: items[index],
                    adjacentChapterIds: [prevId, nextId],
                    isMultiSelectMode: isMultiSelect,
                    isSelected: selected.contains(id),
                    onLongPress: () => selectNotifier.toggle(id),
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

  Future<void> _confirmBulkUnbookmark(
    BuildContext context,
    WidgetRef ref,
    List<int> ids,
    MultiSelectNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove bookmarks?'),
        content: Text(
          'Remove ${ids.length} bookmark${ids.length == 1 ? '' : 's'}? The chapters will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).chaptersDao.bulkUnbookmark(ids);
      notifier.clear();
    }
  }
}

// ── Multi-select action bar ───────────────────────────────────────────────────

class _MultiSelectBar extends StatelessWidget {
  final int count;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback onUnbookmark;

  const _MultiSelectBar({
    required this.count,
    required this.onSelectAll,
    required this.onClear,
    required this.onUnbookmark,
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
            icon: const Icon(Icons.bookmark_remove_outlined),
            tooltip: 'Remove bookmarks',
            onPressed: onUnbookmark,
          ),
        ],
      ),
    );
  }
}
