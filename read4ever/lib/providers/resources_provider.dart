import 'package:flutter_riverpod/flutter_riverpod.dart';
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
