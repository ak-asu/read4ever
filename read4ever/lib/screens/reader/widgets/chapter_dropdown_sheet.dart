import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/reader_provider.dart';
import '../../../theme/app_colors.dart';

class ChapterDropdownSheet extends ConsumerWidget {
  final int resourceId;
  final int currentChapterId;
  final void Function(int chapterId) onChapterSelected;

  const ChapterDropdownSheet({
    super.key,
    required this.resourceId,
    required this.currentChapterId,
    required this.onChapterSelected,
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
                    itemCount: chapters.length,
                    itemBuilder: (_, i) {
                      final chapter = chapters[i];
                      final isCurrent = chapter.id == currentChapterId;
                      return ListTile(
                        title: Text(
                          chapter.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isCurrent ? AppColors.accent : null,
                              ),
                        ),
                        trailing: chapter.isDone
                            ? Icon(Icons.check, color: AppColors.accent, size: 18)
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
