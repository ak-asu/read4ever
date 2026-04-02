import 'package:drift/drift.dart';

import '../db/database.dart';

/// Drift result class for a chapter joined with its parent resource.
/// Used by ChaptersDao.watchBookmarked() and consumed by the Bookmarks screen.
class ChapterWithResource {
  final Chapter chapter;
  final Resource resource;

  const ChapterWithResource({
    required this.chapter,
    required this.resource,
  });

  factory ChapterWithResource.fromRow(QueryRow row) {
    return ChapterWithResource(
      chapter: Chapter(
        id: row.read<int>('c_id'),
        resourceId: row.read<int>('c_resource_id'),
        title: row.read<String>('c_title'),
        url: row.read<String>('c_url'),
        position: row.read<int>('c_position'),
        isDone: row.read<bool>('c_is_done'),
        bookmarkedAt: row.readNullable<DateTime>('c_bookmarked_at'),
        createdAt: row.read<DateTime>('c_created_at'),
      ),
      resource: Resource(
        id: row.read<int>('r_id'),
        title: row.read<String>('r_title'),
        description: row.readNullable<String>('r_description'),
        url: row.read<String>('r_url'),
        createdAt: row.read<DateTime>('r_created_at'),
        lastAccessedAt: row.readNullable<DateTime>('r_last_accessed_at'),
        lastOpenedChapterId: row.readNullable<int>('r_last_opened_chapter_id'),
      ),
    );
  }
}
