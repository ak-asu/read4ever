import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/reader_provider.dart';
import '../../../theme/app_colors.dart';

class ChapterDropdownSheet extends ConsumerWidget {
  final int resourceId;

  /// The chapter ID to highlight as current. Pass null when the WebView is
  /// showing a temp page so no existing chapter is highlighted.
  final int? currentChapterId;

  /// When non-null, a temporary "currently viewing" entry is shown at the top
  /// of the list representing the unsaved temp page.
  final String? tempChapterTitle;
  final void Function(int chapterId) onChapterSelected;

  const ChapterDropdownSheet({
    super.key,
    required this.resourceId,
    required this.currentChapterId,
    required this.onChapterSelected,
    this.tempChapterTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(resourceChaptersProvider(resourceId));

    return chaptersAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 200,
        child: Center(child: Text('Error loading chapters: $e')),
      ),
      data: (chapters) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Chapters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount:
                        chapters.length + (tempChapterTitle != null ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (tempChapterTitle != null) {
                        if (index == 0) {
                          return ListTile(
                            leading: Icon(
                              Icons.explore_outlined,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            title: Text(
                              tempChapterTitle!.isNotEmpty
                                  ? tempChapterTitle!
                                  : 'Loading…',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.accent,
                                  ),
                            ),
                            subtitle: Text(
                              'Not in library',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            dense: true,
                          );
                        }
                        if (index == 1) {
                          return const Divider(height: 1);
                        }
                      }

                      final chapterIndex =
                          tempChapterTitle != null ? index - 2 : index;
                      final chapter = chapters[chapterIndex];
                      final isCurrent = chapter.id == currentChapterId;

                      return ListTile(
                        title: Text(
                          chapter.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isCurrent ? AppColors.accent : null,
                                  ),
                        ),
                        trailing: chapter.isDone
                            ? Icon(Icons.check,
                                color: AppColors.accent, size: 18)
                            : null,
                        selected: isCurrent,
                        onTap: isCurrent
                            ? null
                            : () => onChapterSelected(chapter.id),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
