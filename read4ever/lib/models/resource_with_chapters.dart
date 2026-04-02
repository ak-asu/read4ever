import '../db/database.dart';

/// Holds a resource and its ordered chapters.
/// Used as the data shape for the Resource Detail screen.
class ResourceWithChapters {
  final Resource resource;
  final List<Chapter> chapters;

  const ResourceWithChapters({
    required this.resource,
    required this.chapters,
  });
}
