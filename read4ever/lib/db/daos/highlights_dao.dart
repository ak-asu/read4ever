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

  // Implemented in step 8 — full join with chapter + resource for display
  Stream<List<HighlightWithChapterAndResource>> watchAll() =>
      throw UnimplementedError();

  Stream<List<Highlight>> watchByChapter(int chapterId) => (select(highlights)
        ..where((h) => h.chapterId.equals(chapterId))
        ..orderBy([(h) => OrderingTerm.asc(h.createdAt)]))
      .watch();

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
