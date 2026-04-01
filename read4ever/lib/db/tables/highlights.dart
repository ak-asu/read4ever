import 'package:drift/drift.dart';
import 'chapters.dart';

class Highlights extends Table {
  IntColumn get id          => integer().autoIncrement()();
  IntColumn get chapterId   => integer().references(Chapters, #id,
      onDelete: KeyAction.cascade)();
  TextColumn get selectedText => text()();
  TextColumn get xpathStart   => text()();
  TextColumn get xpathEnd     => text()();
  IntColumn  get startOffset  => integer()();
  IntColumn  get endOffset    => integer()();
  TextColumn get note         => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
