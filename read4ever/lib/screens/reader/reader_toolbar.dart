import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/database_provider.dart';
import '../../providers/reader_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/chapter_dropdown_sheet.dart';

class ReaderToolbar extends ConsumerWidget {
  final int chapterId;
  final int resourceId;
  final ReaderContext readerContext;

  /// Overrides the default back behavior. Used in temp mode to return to the
  /// original chapter instead of popping the reader.
  final VoidCallback? onBack;

  /// When set, shown instead of the DB chapter title (temp mode).
  final String? titleOverride;

  /// When set, shown instead of the DB-derived bookmark state (temp mode → false).
  final bool? bookmarkOverride;

  /// When set, shown instead of the DB-derived done state (temp mode → false).
  final bool? doneOverride;

  /// When set, called instead of the default toggleBookmark (temp mode auto-add).
  final VoidCallback? onBookmarkToggle;

  /// When set, called instead of the default setDone (temp mode auto-add).
  final void Function(bool currentIsDone)? onDoneToggle;

  /// When set, the chapter dropdown shows this as the currently-viewing temp
  /// entry and highlights no existing chapter.
  final String? tempChapterTitle;

  const ReaderToolbar({
    super.key,
    required this.chapterId,
    required this.resourceId,
    required this.readerContext,
    this.onBack,
    this.titleOverride,
    this.bookmarkOverride,
    this.doneOverride,
    this.onBookmarkToggle,
    this.onDoneToggle,
    this.tempChapterTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterAsync = ref.watch(chapterStreamProvider(chapterId));
    final chapter = chapterAsync.valueOrNull;

    final isBookmarked = bookmarkOverride ?? (chapter?.bookmarkedAt != null);
    final isDone = doneOverride ?? (chapter?.isDone ?? false);
    final title = titleOverride ?? chapter?.title ?? '';
    final isTempMode = tempChapterTitle != null;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack ?? () => context.pop(),
            tooltip: 'Back',
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Allow opening dropdown even in temp mode — the sheet shows the
              // temp entry plus the full saved chapter list.
              onTap: (chapter != null || isTempMode)
                  ? () => _showChapterDropdown(context, ref)
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.accent : null,
            ),
            onPressed: onBookmarkToggle ??
                (chapter != null
                    ? () => ref
                        .read(appDatabaseProvider)
                        .chaptersDao
                        .toggleBookmark(chapterId)
                    : null),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
          ),
          IconButton(
            icon: Icon(
              isDone ? Icons.check_circle : Icons.check_circle_outline,
              color: isDone ? AppColors.accent : null,
            ),
            onPressed: onDoneToggle != null
                ? () => onDoneToggle!(isDone)
                : (chapter != null
                    ? () => ref
                        .read(appDatabaseProvider)
                        .chaptersDao
                        .setDone(chapterId, !isDone)
                    : null),
            tooltip: isDone ? 'Mark not done' : 'Mark done',
          ),
        ],
      ),
    );
  }

  void _showChapterDropdown(BuildContext context, WidgetRef ref) async {
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChapterDropdownSheet(
        resourceId: resourceId,
        // In temp mode no existing chapter is "current".
        currentChapterId: tempChapterTitle != null ? null : chapterId,
        tempChapterTitle: tempChapterTitle,
        onChapterSelected: (id) => Navigator.of(context).pop(id),
      ),
    );

    if (selectedId != null && context.mounted) {
      context.pushReplacement(
        '/reader/$selectedId',
        extra: ReaderContext(source: readerContext.source),
      );
    }
  }
}
