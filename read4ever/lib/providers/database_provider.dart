import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../db/database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) => AppDatabase();
