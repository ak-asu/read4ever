import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/resources.dart';
import 'tables/chapters.dart';
import 'tables/highlights.dart';
import 'tables/tags.dart';
import 'tables/resource_tags.dart';
import 'daos/resources_dao.dart';
import 'daos/chapters_dao.dart';
import 'daos/highlights_dao.dart';
import 'daos/tags_dao.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'read4ever.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [Resources, Chapters, Highlights, Tags, ResourceTags],
  daos: [ResourcesDao, ChaptersDao, HighlightsDao, TagsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
