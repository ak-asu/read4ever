import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/resources.dart';
import '../tables/chapters.dart';
import '../../models/resource_with_status.dart';
import '../../models/resource_with_chapter.dart';

part 'resources_dao.g.dart';

@DriftAccessor(tables: [Resources, Chapters])
class ResourcesDao extends DatabaseAccessor<AppDatabase>
    with _$ResourcesDaoMixin {
  ResourcesDao(super.db);

  // ORDER: in-progress → not-started → done, then by lastAccessedAt DESC
  Stream<List<ResourceWithStatus>> watchAll() {
    final query = customSelect(
      '''
      SELECT sub.* FROM (
        SELECT
          r.id, r.title, r.description, r.url,
          r.created_at, r.last_accessed_at, r.last_opened_chapter_id,
          COUNT(c.id) AS total_count,
          COALESCE(SUM(c.is_done), 0) AS done_count,
          CASE
            WHEN COALESCE(SUM(c.is_done), 0) = COUNT(c.id) AND COUNT(c.id) > 0 THEN 2
            WHEN COALESCE(SUM(c.is_done), 0) > 0 THEN 0
            ELSE 1
          END AS sort_priority
        FROM resources r
        LEFT JOIN chapters c ON c.resource_id = r.id
        GROUP BY r.id
      ) sub
      ORDER BY sub.sort_priority ASC, sub.last_accessed_at DESC NULLS LAST
      ''',
      readsFrom: {resources, chapters},
    );
    return query.watch().map(
          (rows) => rows.map(ResourceWithStatus.fromRow).toList(),
        );
  }

  Stream<Resource?> watchById(int id) =>
      (select(resources)..where((r) => r.id.equals(id))).watchSingleOrNull();

  // Last 3 in-progress resources (at least 1 done, not all done) by lastAccessedAt DESC
  Stream<List<ResourceWithChapter>> watchContinueReading() {
    final query = customSelect(
      '''
      SELECT
        r.id, r.title, r.description, r.url,
        r.created_at, r.last_accessed_at, r.last_opened_chapter_id,
        c.id AS chapter_id,
        c.resource_id AS chapter_resource_id,
        c.title AS chapter_title,
        c.url AS chapter_url,
        c.position AS chapter_position,
        c.is_done AS chapter_is_done,
        c.bookmarked_at AS chapter_bookmarked_at,
        c.created_at AS chapter_created_at
      FROM resources r
      INNER JOIN chapters c ON c.id = r.last_opened_chapter_id
      WHERE (SELECT COALESCE(SUM(is_done), 0) FROM chapters WHERE resource_id = r.id) > 0
        AND (SELECT COALESCE(SUM(is_done), 0) FROM chapters WHERE resource_id = r.id) <
            (SELECT COUNT(*) FROM chapters WHERE resource_id = r.id)
      ORDER BY r.last_accessed_at DESC
      LIMIT 3
      ''',
      readsFrom: {resources, chapters},
    );
    return query.watch().map(
          (rows) => rows.map(ResourceWithChapter.fromRow).toList(),
        );
  }

  Future<int> insertResource(ResourcesCompanion entry) =>
      into(resources).insert(entry);

  Future<bool> updateResource(ResourcesCompanion entry) async {
    if (!entry.id.present) {
      throw ArgumentError('updateResource requires an id');
    }

    final hasFieldToUpdate = entry.title.present ||
        entry.description.present ||
        entry.url.present ||
        entry.createdAt.present ||
        entry.lastAccessedAt.present ||
        entry.lastOpenedChapterId.present;
    if (!hasFieldToUpdate) {
      throw ArgumentError(
          'updateResource requires at least one field to update');
    }

    final affected = await (update(resources)
          ..where((r) => r.id.equals(entry.id.value)))
        .write(entry.copyWith(id: const Value.absent()));
    return affected > 0;
  }

  Future<int> deleteById(int id) =>
      (delete(resources)..where((r) => r.id.equals(id))).go();

  Future<int> deleteAll() => delete(resources).go();

  Future<void> updateLastOpened(int resourceId, int chapterId) =>
      (update(resources)..where((r) => r.id.equals(resourceId))).write(
        ResourcesCompanion(
          lastOpenedChapterId: Value(chapterId),
          lastAccessedAt: Value(DateTime.now()),
        ),
      );

  // Used by duplicate detection in ImportNotifier (step 6)
  Future<Resource?> findByUrl(String url) =>
      (select(resources)..where((r) => r.url.equals(url))).getSingleOrNull();
}
