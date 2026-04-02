import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bookmarks_provider.dart';
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
}
