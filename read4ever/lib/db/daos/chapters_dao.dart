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

  Stream<List<Chapter>> watchByResource(int resourceId) => (select(chapters)
        ..where((c) => c.resourceId.equals(resourceId))
        ..orderBy([(c) => OrderingTerm.asc(c.position)]))
      .watch();

  static const _bookmarkedQuery = '''
    SELECT
      c.id              AS c_id,
      c.resource_id     AS c_resource_id,
      c.title           AS c_title,
      c.url             AS c_url,
      c.position        AS c_position,
      c.is_done         AS c_is_done,
      c.bookmarked_at   AS c_bookmarked_at,
      c.created_at      AS c_created_at,
      r.id              AS r_id,
      r.title           AS r_title,
      r.description     AS r_description,
      r.url             AS r_url,
      r.created_at      AS r_created_at,
      r.last_accessed_at        AS r_last_accessed_at,
      r.last_opened_chapter_id  AS r_last_opened_chapter_id
    FROM chapters c
    INNER JOIN resources r ON r.id = c.resource_id
    WHERE c.bookmarked_at IS NOT NULL
    ORDER BY c.bookmarked_at ASC
  ''';

  Stream<List<ChapterWithResource>> watchBookmarked() {
    return customSelect(
      _bookmarkedQuery,
      readsFrom: {chapters, resources},
    ).watch().map((rows) => rows.map(ChapterWithResource.fromRow).toList());
  }

  /// Non-streaming fetch — used by reader FABs to compute adjacents on navigation.
  Future<List<ChapterWithResource>> getBookmarked() {
    return customSelect(
      _bookmarkedQuery,
      readsFrom: {chapters, resources},
    ).get().then((rows) => rows.map(ChapterWithResource.fromRow).toList());
  }

  Future<int> insertChapter(ChaptersCompanion entry) =>
      into(chapters).insert(entry);

  Future<void> insertAll(List<ChaptersCompanion> entries) async {
    await batch((b) => b.insertAll(chapters, entries));
  }

  Future<void> setDone(int id, bool done) =>
      (update(chapters)..where((c) => c.id.equals(id)))
          .write(ChaptersCompanion(isDone: Value(done)));

  Future<void> toggleBookmark(int id) async {
    final chapter =
        await (select(chapters)..where((c) => c.id.equals(id))).getSingle();
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

  Stream<Chapter> watchById(int id) =>
      (select(chapters)..where((c) => c.id.equals(id))).watchSingle();

  Future<Chapter> getById(int id) =>
      (select(chapters)..where((c) => c.id.equals(id))).getSingle();

  // Used by duplicate detection in ImportNotifier (step 6)
  Future<Chapter?> findByUrl(String url) =>
      (select(chapters)..where((c) => c.url.equals(url))).getSingleOrNull();

  // Used by ResourceDetail delete confirmation dialog (step 11)
  Future<void> deleteById(int id) =>
      (delete(chapters)..where((c) => c.id.equals(id))).go();
}
