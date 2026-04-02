import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/tags.dart';
import '../tables/resource_tags.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [Tags, ResourceTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Stream<List<Tag>> watchAll() => select(tags).watch();

  Stream<List<Tag>> watchByResource(int resourceId) {
    final query = select(tags).join([
      innerJoin(resourceTags, resourceTags.tagId.equalsExp(tags.id)),
    ])
      ..where(resourceTags.resourceId.equals(resourceId))
      ..orderBy([OrderingTerm.asc(tags.name)]);
    return query.watch().map((rows) => rows.map((r) => r.readTable(tags)).toList());
  }

  Stream<List<Tag>> watchByPrefix(String prefix) => (select(tags)
        ..where((t) => t.name.like('$prefix%'))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  // Upserts the tag by name, then inserts the junction row
  Future<void> addTagToResource(int resourceId, String name) async {
    final tagId = await into(tags).insertOnConflictUpdate(
      TagsCompanion.insert(name: name),
    );
    await into(resourceTags).insertOnConflictUpdate(
      ResourceTagsCompanion.insert(resourceId: resourceId, tagId: tagId),
    );
  }

  Future<void> removeTagFromResource(int resourceId, int tagId) =>
      (delete(resourceTags)
            ..where(
              (rt) => rt.resourceId.equals(resourceId) & rt.tagId.equals(tagId),
            ))
          .go();

  Future<int> deleteAll() => delete(tags).go();
}
