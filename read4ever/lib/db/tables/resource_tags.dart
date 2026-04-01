import 'package:drift/drift.dart';
import 'resources.dart';
import 'tags.dart';

class ResourceTags extends Table {
  IntColumn get resourceId => integer().references(Resources, #id,
      onDelete: KeyAction.cascade)();
  IntColumn get tagId      => integer().references(Tags, #id,
      onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {resourceId, tagId};
}
