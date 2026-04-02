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

  const ReaderToolbar({
    super.key,
    required this.chapterId,
    required this.resourceId,
    required this.readerContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterAsync = ref.watch(chapterStreamProvider(chapterId));

    final chapter = chapterAsync.valueOrNull;
    final isBookmarked = chapter?.bookmarkedAt != null;
    final isDone = chapter?.isDone ?? false;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Back',
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: chapter != null
                  ? () => _showChapterDropdown(context, ref)
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chapter?.title ?? '',
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
            onPressed: chapter != null
                ? () => ref
                    .read(appDatabaseProvider)
                    .chaptersDao
                    .toggleBookmark(chapterId)
                : null,
            tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
          ),
          IconButton(
            icon: Icon(
              isDone ? Icons.check_circle : Icons.check_circle_outline,
              color: isDone ? AppColors.accent : null,
            ),
            onPressed: chapter != null
                ? () => ref
                    .read(appDatabaseProvider)
                    .chaptersDao
                    .setDone(chapterId, !isDone)
                : null,
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
      builder: (_) => ChapterDropdownSheet(
        resourceId: resourceId,
        currentChapterId: chapterId,
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
