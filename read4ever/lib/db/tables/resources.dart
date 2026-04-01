import 'package:drift/drift.dart';

// Note: Resources has a nullable FK to Chapters (lastOpenedChapterId).
// To avoid a circular import between resources.dart and chapters.dart,
// this FK is expressed as a raw SQL customConstraint rather than .references().
// DB-level behavior is identical; Drift just won't auto-generate the join helper.
class Resources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get url => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()();
  IntColumn get lastOpenedChapterId => integer()
      .nullable()
      .customConstraint('REFERENCES chapters(id) ON DELETE SET NULL')();
}
