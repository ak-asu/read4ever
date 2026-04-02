import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../models/highlight_with_chapter_and_resource.dart';
import 'database_provider.dart';

/// All highlights across all resources, newest first.
/// Consumed by the Highlights screen (step 10).
final highlightsProvider =
    StreamProvider.autoDispose<List<HighlightWithChapterAndResource>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.highlightsDao.watchAll();
});

/// Highlights for a single chapter, ordered by creation time.
/// Used by the Highlights screen detail sheet and by HighlightService
/// indirectly via the DAO's getByChapter (non-streaming).
final chapterHighlightsProvider =
    StreamProvider.autoDispose.family<List<Highlight>, int>((ref, chapterId) {
  final db = ref.watch(appDatabaseProvider);
  return db.highlightsDao.watchByChapter(chapterId);
});

/// Filter state for the Highlights screen — resource + chapter filter.
/// Scaffolded here; fully wired in step 10.
class HighlightFilter {
  final int? resourceId;
  final int? chapterId;

  const HighlightFilter({this.resourceId, this.chapterId});
}

class HighlightFilterNotifier extends AutoDisposeNotifier<HighlightFilter> {
  @override
  HighlightFilter build() => const HighlightFilter();

  void setResource(int? id) => state = HighlightFilter(resourceId: id);

  void setChapter(int? id) =>
      state = HighlightFilter(resourceId: state.resourceId, chapterId: id);

  void clear() => state = const HighlightFilter();
}

final highlightFilterNotifierProvider =
    AutoDisposeNotifierProvider<HighlightFilterNotifier, HighlightFilter>(
  HighlightFilterNotifier.new,
);
