import 'package:drift/drift.dart';
import '../db/database.dart';

class ResourceWithChapter {
  final Resource resource;
  final Chapter lastOpenedChapter;

  const ResourceWithChapter({
    required this.resource,
    required this.lastOpenedChapter,
  });

  factory ResourceWithChapter.fromRow(QueryRow row) {
    return ResourceWithChapter(
      resource: Resource(
        id: row.read<int>('id'),
        title: row.read<String>('title'),
        description: row.readNullable<String>('description'),
        url: row.read<String>('url'),
        createdAt: row.read<DateTime>('created_at'),
        lastAccessedAt: row.readNullable<DateTime>('last_accessed_at'),
        lastOpenedChapterId: row.readNullable<int>('last_opened_chapter_id'),
      ),
      lastOpenedChapter: Chapter(
        id: row.read<int>('chapter_id'),
        resourceId: row.read<int>('chapter_resource_id'),
        title: row.read<String>('chapter_title'),
        url: row.read<String>('chapter_url'),
        position: row.read<int>('chapter_position'),
        isDone: row.read<int>('chapter_is_done') == 1,
        bookmarkedAt: row.readNullable<DateTime>('chapter_bookmarked_at'),
        createdAt: row.read<DateTime>('chapter_created_at'),
      ),
    );
  }
}
