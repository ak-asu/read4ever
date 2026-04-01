import 'package:drift/drift.dart';
import '../db/database.dart';

class ResourceWithStatus {
  final Resource resource;
  final int totalCount;
  final int doneCount;

  const ResourceWithStatus({
    required this.resource,
    required this.totalCount,
    required this.doneCount,
  });

  bool get isDone => totalCount > 0 && doneCount == totalCount;
  bool get isInProgress => doneCount > 0 && doneCount < totalCount;
  double get progress => totalCount > 0 ? doneCount / totalCount : 0.0;

  factory ResourceWithStatus.fromRow(QueryRow row) {
    return ResourceWithStatus(
      resource: Resource(
        id: row.read<int>('id'),
        title: row.read<String>('title'),
        description: row.readNullable<String>('description'),
        url: row.read<String>('url'),
        createdAt: row.read<DateTime>('created_at'),
        lastAccessedAt: row.readNullable<DateTime>('last_accessed_at'),
        lastOpenedChapterId: row.readNullable<int>('last_opened_chapter_id'),
      ),
      totalCount: row.read<int>('total_count'),
      doneCount: row.read<int>('done_count'),
    );
  }
}
