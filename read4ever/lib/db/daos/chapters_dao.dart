import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/chapters.dart';
import '../tables/resources.dart';
import '../../models/chapter_with_resource.dart';

part 'chapters_dao.g.dart';

@DriftAccessor(tables: [Chapters, Resources])
class ChaptersDao extends DatabaseAccessor<AppDatabase>
    with _$ChaptersDaoMixin {
  ChaptersDao(super.db);

  Stream<List<Chapter>> watchByResource(int resourceId) =>
      (select(chapters)
            ..where((c) => c.resourceId.equals(resourceId))
            ..orderBy([(c) => OrderingTerm.asc(c.position)]))
          .watch();

  // Implemented in step 9 — chapters WHERE bookmarkedAt IS NOT NULL ORDER BY bookmarkedAt ASC
  Stream<List<ChapterWithResource>> watchBookmarked() =>
      throw UnimplementedError();

  Future<int> insertChapter(ChaptersCompanion entry) =>
      into(chapters).insert(entry);

  Future<void> insertAll(List<ChaptersCompanion> entries) async {
    await batch((b) => b.insertAll(chapters, entries));
  }

  Future<void> setDone(int id, bool done) =>
      (update(chapters)..where((c) => c.id.equals(id)))
          .write(ChaptersCompanion(isDone: Value(done)));

  Future<void> toggleBookmark(int id) async {
    final chapter = await (select(chapters)..where((c) => c.id.equals(id)))
        .getSingle();
    final newBookmarkedAt =
        chapter.bookmarkedAt == null ? DateTime.now() : null;
    await (update(chapters)..where((c) => c.id.equals(id)))
        .write(ChaptersCompanion(bookmarkedAt: Value(newBookmarkedAt)));
  }

  // Reorders chapters by assigning each id its new position index
  Future<void> reorder(List<int> orderedIds) async {
    await batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          chapters,
          ChaptersCompanion(position: Value(i)),
          where: (c) => c.id.equals(orderedIds[i]),
        );
      }
    });
  }

  Future<void> updateTitle(int id, String title) =>
      (update(chapters)..where((c) => c.id.equals(id)))
          .write(ChaptersCompanion(title: Value(title)));

  Future<void> bulkDelete(List<int> ids) async {
    await (delete(chapters)..where((c) => c.id.isIn(ids))).go();
  }

  Future<void> bulkUnbookmark(List<int> ids) async {
    await (update(chapters)..where((c) => c.id.isIn(ids)))
        .write(const ChaptersCompanion(bookmarkedAt: Value(null)));
  }

  Future<int> countBookmarkedByResource(int resourceId) async {
    final count = chapters.id.count();
    final query = selectOnly(chapters)
      ..addColumns([count])
      ..where(chapters.resourceId.equals(resourceId) &
          chapters.bookmarkedAt.isNotNull());
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // Used by duplicate detection in ImportNotifier (step 6)
  Future<Chapter?> findByUrl(String url) =>
      (select(chapters)..where((c) => c.url.equals(url))).getSingleOrNull();

  // Used by ResourceDetail delete confirmation dialog (step 11)
  Future<void> deleteById(int id) =>
      (delete(chapters)..where((c) => c.id.equals(id))).go();
}
