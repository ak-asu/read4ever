import 'package:drift/drift.dart';

import '../db/database.dart';

/// Drift result class that joins a highlight with its parent chapter and resource.
/// Used by HighlightsDao.watchAll() and consumed by the Highlights screen.
class HighlightWithChapterAndResource {
  final Highlight highlight;
  final Chapter chapter;
  final Resource resource;

  const HighlightWithChapterAndResource({
    required this.highlight,
    required this.chapter,
    required this.resource,
  });

  factory HighlightWithChapterAndResource.fromRow(QueryRow row) {
    return HighlightWithChapterAndResource(
      highlight: Highlight(
        id: row.read<int>('h_id'),
        chapterId: row.read<int>('h_chapter_id'),
        selectedText: row.read<String>('h_selected_text'),
        xpathStart: row.read<String>('h_xpath_start'),
        xpathEnd: row.read<String>('h_xpath_end'),
        startOffset: row.read<int>('h_start_offset'),
        endOffset: row.read<int>('h_end_offset'),
        note: row.readNullable<String>('h_note'),
        createdAt: row.read<DateTime>('h_created_at'),
      ),
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
