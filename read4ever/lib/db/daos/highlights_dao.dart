import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/highlights.dart';
import '../tables/chapters.dart';
import '../tables/resources.dart';
import '../../models/highlight_with_chapter_and_resource.dart';

part 'highlights_dao.g.dart';

@DriftAccessor(tables: [Highlights, Chapters, Resources])
class HighlightsDao extends DatabaseAccessor<AppDatabase>
    with _$HighlightsDaoMixin {
  HighlightsDao(super.db);

  /// All highlights joined with their chapter and resource, newest first.
  /// Consumed by the Highlights screen.
  Stream<List<HighlightWithChapterAndResource>> watchAll() {
    final query = customSelect(
      '''
      SELECT
        h.id              AS h_id,
        h.chapter_id      AS h_chapter_id,
        h.selected_text   AS h_selected_text,
        h.xpath_start     AS h_xpath_start,
        h.xpath_end       AS h_xpath_end,
        h.start_offset    AS h_start_offset,
        h.end_offset      AS h_end_offset,
        h.note            AS h_note,
        h.created_at      AS h_created_at,
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
      FROM highlights h
      INNER JOIN chapters c ON c.id = h.chapter_id
      INNER JOIN resources r ON r.id = c.resource_id
      ORDER BY h.created_at DESC
      ''',
      readsFrom: {highlights, chapters, resources},
    );
    return query.watch().map(
          (rows) =>
              rows.map(HighlightWithChapterAndResource.fromRow).toList(),
        );
  }

  Stream<List<Highlight>> watchByChapter(int chapterId) => (select(highlights)
        ..where((h) => h.chapterId.equals(chapterId))
        ..orderBy([(h) => OrderingTerm.asc(h.createdAt)]))
      .watch();

  /// Non-streaming fetch — used by HighlightService.restoreForChapter().
  Future<List<Highlight>> getByChapter(int chapterId) =>
      (select(highlights)
            ..where((h) => h.chapterId.equals(chapterId))
            ..orderBy([(h) => OrderingTerm.asc(h.createdAt)]))
          .get();

  Future<int> insertHighlight(HighlightsCompanion entry) =>
      into(highlights).insert(entry);

  Future<void> updateNote(int id, String? note) =>
      (update(highlights)..where((h) => h.id.equals(id)))
          .write(HighlightsCompanion(note: Value(note)));

  Future<void> deleteHighlight(int id) =>
      (delete(highlights)..where((h) => h.id.equals(id))).go();

  Future<void> bulkDelete(List<int> ids) async {
    await (delete(highlights)..where((h) => h.id.isIn(ids))).go();
  }

  Future<int> deleteAll() => delete(highlights).go();

  // Used by ResourceDetail delete confirmation dialog (step 11)
  Future<int> countByResource(int resourceId) async {
    final count = highlights.id.count();
    final query = selectOnly(highlights).join([
      innerJoin(chapters, chapters.id.equalsExp(highlights.chapterId)),
    ])
      ..addColumns([count])
      ..where(chapters.resourceId.equals(resourceId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // Used by ResourceDetail chapter delete confirm (step 11)
  Future<int> countByChapter(int chapterId) async {
    final count = highlights.id.count();
    final query = selectOnly(highlights)
      ..addColumns([count])
      ..where(highlights.chapterId.equals(chapterId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
