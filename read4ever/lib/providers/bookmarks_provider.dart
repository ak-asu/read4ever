import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chapter_with_resource.dart';
import 'database_provider.dart';

/// All bookmarked chapters ordered by bookmark time (oldest first).
/// Consumed by the Bookmarks screen.
final bookmarksProvider =
    StreamProvider.autoDispose<List<ChapterWithResource>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.chaptersDao.watchBookmarked();
});
