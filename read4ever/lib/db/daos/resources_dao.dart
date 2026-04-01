import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/resources.dart';
import '../tables/chapters.dart';
import '../../models/resource_with_status.dart';
import '../../models/resource_with_chapters.dart';
import '../../models/resource_with_chapter.dart';

part 'resources_dao.g.dart';

@DriftAccessor(tables: [Resources, Chapters])
class ResourcesDao extends DatabaseAccessor<AppDatabase>
    with _$ResourcesDaoMixin {
  ResourcesDao(super.db);

  // Implemented in step 4 — complex sort + GROUP BY query
  // ORDER: in-progress → not-started → done, then by lastAccessedAt DESC
  Stream<List<ResourceWithStatus>> watchAll() => throw UnimplementedError();

  // Implemented in step 4 — resource row + ordered chapter list
  Stream<ResourceWithChapters> watchById(int id) => throw UnimplementedError();

  // Implemented in step 4 — last 3 in-progress by lastAccessedAt DESC
  Stream<List<ResourceWithChapter>> watchContinueReading() =>
      throw UnimplementedError();

  Future<int> insertResource(ResourcesCompanion entry) =>
      into(resources).insert(entry);

  Future<bool> updateResource(ResourcesCompanion entry) =>
      update(resources).replace(entry);

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
