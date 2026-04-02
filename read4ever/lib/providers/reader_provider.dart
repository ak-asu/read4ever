import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../db/database.dart';
import 'database_provider.dart';

part 'reader_provider.freezed.dart';

enum ReaderSource { library, resourceDetail, bookmarks, highlights }

@freezed
class ReaderContext with _$ReaderContext {
  const factory ReaderContext({
    @Default(ReaderSource.library) ReaderSource source,
    List<int>? adjacentChapterIds,
    int? scrollToHighlightId,
  }) = _ReaderContext;
}

@freezed
class ReaderState with _$ReaderState {
  const factory ReaderState({
    required int chapterId,
    @Default(true) bool isLoading,
    required ReaderContext context,
  }) = _ReaderState;
}

class ReaderNotifier
    extends AutoDisposeFamilyNotifier<ReaderState, (int, ReaderContext)> {
  @override
  ReaderState build((int, ReaderContext) arg) =>
      ReaderState(chapterId: arg.$1, context: arg.$2);

  void setLoading(bool loading) => state = state.copyWith(isLoading: loading);
}

final readerNotifierProvider = NotifierProvider.autoDispose
    .family<ReaderNotifier, ReaderState, (int, ReaderContext)>(
  ReaderNotifier.new,
);

/// Watches a single chapter — toolbar uses this for title, bookmark, done state.
final chapterStreamProvider =
    StreamProvider.autoDispose.family<Chapter, int>((ref, chapterId) {
  final db = ref.watch(appDatabaseProvider);
  return db.chaptersDao.watchById(chapterId);
});

/// Watches all chapters for a resource — chapter dropdown uses this.
final resourceChaptersProvider =
    StreamProvider.autoDispose.family<List<Chapter>, int>((ref, resourceId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.chapters)
        ..where((c) => c.resourceId.equals(resourceId))
        ..orderBy([(c) => OrderingTerm.asc(c.position)]))
      .watch();
});
