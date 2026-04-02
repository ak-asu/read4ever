import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database.dart';
import 'database_provider.dart';

/// All tags — used by the autocomplete input on the Resource Detail screen.
final allTagsProvider = StreamProvider.autoDispose<List<Tag>>((ref) {
  return ref.watch(appDatabaseProvider).tagsDao.watchAll();
});

/// Tags attached to a specific resource. Used by the Resource Detail screen.
final tagsForResourceProvider =
    StreamProvider.autoDispose.family<List<Tag>, int>((ref, id) {
  return ref.watch(appDatabaseProvider).tagsDao.watchByResource(id);
});
