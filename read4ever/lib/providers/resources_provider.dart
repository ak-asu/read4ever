import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database.dart';
import '../models/resource_with_status.dart';
import '../models/resource_with_chapter.dart';
import 'database_provider.dart';

final resourcesProvider = StreamProvider<List<ResourceWithStatus>>((ref) {
  return ref.watch(appDatabaseProvider).resourcesDao.watchAll();
});

final continueReadingProvider =
    StreamProvider<List<ResourceWithChapter>>((ref) {
  return ref.watch(appDatabaseProvider).resourcesDao.watchContinueReading();
});

/// Watches a single resource by ID. Used by the Resource Detail screen.
final resourceStreamProvider =
    StreamProvider.autoDispose.family<Resource?, int>((ref, id) {
  return ref.watch(appDatabaseProvider).resourcesDao.watchById(id);
});

/// Watches the ordered chapter list for a resource. Used by the Resource Detail screen.
final resourceChaptersProvider =
    StreamProvider.autoDispose.family<List<Chapter>, int>((ref, id) {
  return ref.watch(appDatabaseProvider).chaptersDao.watchByResource(id);
});
