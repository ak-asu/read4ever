import 'package:drift/drift.dart';
import 'resources.dart';

class Chapters extends Table {
  IntColumn get id         => integer().autoIncrement()();
  IntColumn get resourceId => integer().references(Resources, #id,
      onDelete: KeyAction.cascade)();
  TextColumn get title     => text()();
  TextColumn get url       => text()();
  IntColumn  get position  => integer()();
  BoolColumn get isDone    => boolean().withDefault(const Constant(false))();
  DateTimeColumn get bookmarkedAt => dateTime().nullable()();
  DateTimeColumn get createdAt    => dateTime()();
}
