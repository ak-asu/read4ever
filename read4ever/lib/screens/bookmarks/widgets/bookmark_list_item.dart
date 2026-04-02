import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/chapter_with_resource.dart';
import '../../../providers/reader_provider.dart';
import '../../../theme/app_colors.dart';

class BookmarkListItem extends StatelessWidget {
  final ChapterWithResource item;

  /// Fixed-length 2-element list: [prevId_or_0, nextId_or_0].
  /// 0 means no chapter in that direction.
  final List<int> adjacentChapterIds;

  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;

  const BookmarkListItem({
    super.key,
    required this.item,
    required this.adjacentChapterIds,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected
          ? AppColors.accentSubtle.withValues(alpha: 0.4)
          : Colors.transparent,
      child: ListTile(
        leading: isMultiSelectMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelect(),
                activeColor: AppColors.accent,
              )
            : null,
        title: Text(item.chapter.title, style: theme.textTheme.bodyMedium),
        subtitle: Text(
          item.resource.title,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        onTap: isMultiSelectMode
            ? onToggleSelect
            : () => context.push(
                  '/reader/${item.chapter.id}',
                  extra: ReaderContext(
                    source: ReaderSource.bookmarks,
                    adjacentChapterIds: adjacentChapterIds,
                  ),
                ),
        onLongPress: isMultiSelectMode ? null : onLongPress,
      ),
    );
  }
}
