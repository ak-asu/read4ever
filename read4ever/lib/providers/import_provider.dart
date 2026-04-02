import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

import '../db/database.dart';
import '../models/sitemap_page.dart';
import '../services/sitemap_service.dart';
import 'database_provider.dart';

part 'import_provider.freezed.dart';

enum ImportStatus { idle, loading, ready, error }

@freezed
class ImportState with _$ImportState {
  const factory ImportState({
    @Default('') String url,
    @Default(ImportStatus.idle) ImportStatus status,
    @Default([]) List<SitemapPage> allPages,
    // URLs of pages the user has deselected; everything else is selected.
    // URL-based (not index-based) so reordering in advanced mode doesn't affect selection.
    @Default([]) List<String> deselectedUrls,
    @Default('') String resourceName,
    @Default('') String description,
    @Default(2) int maxDepth,
    @Default(false) bool isAdvanced,
    String? errorMessage,
  }) = _ImportState;
}

extension ImportStateX on ImportState {
  List<SitemapPage> get selectedPages =>
      allPages.where((p) => !deselectedUrls.contains(p.url)).toList();

  bool isSelected(SitemapPage page) => !deselectedUrls.contains(page.url);
}

class ImportNotifier extends AutoDisposeNotifier<ImportState> {
  @override
  ImportState build() => const ImportState();

  void setUrl(String url) => state = state.copyWith(url: url);

  void setResourceName(String name) =>
      state = state.copyWith(resourceName: name);

  void setDescription(String desc) => state = state.copyWith(description: desc);

  void setMaxDepth(int depth) =>
      state = state.copyWith(maxDepth: depth.clamp(1, 4));

  void toggleAdvanced() =>
      state = state.copyWith(isAdvanced: !state.isAdvanced);

  /// Toggles a page's selection. Blocked when it would deselect the last selected page.
  void togglePage(SitemapPage page) {
    final isCurrentlySelected = state.isSelected(page);
    // Block deselecting the last selected page
    if (isCurrentlySelected && state.selectedPages.length == 1) return;

    final updated = List<String>.from(state.deselectedUrls);
    if (isCurrentlySelected) {
      updated.add(page.url);
    } else {
      updated.remove(page.url);
    }
    state = state.copyWith(deselectedUrls: updated);
  }

  /// Reorders the allPages list when the user drags in advanced mode.
  void reorderPage(int oldIndex, int newIndex) {
    final pages = List<SitemapPage>.from(state.allPages);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = pages.removeAt(oldIndex);
    pages.insert(newIndex, item);
    state = state.copyWith(allPages: pages);
  }

  /// Runs sitemap discovery from scratch:
  ///   1. Validate URL
  ///   2. Duplicate detection (chapter URL match → reader; resource URL match → resource detail)
  ///   3. Sitemap discovery
  ///   4. Single-page fallback on null result
  ///
  /// [excludeUrls] — chapter URLs already in an existing resource; filtered out
  /// from the discovered pages so the user only sees new chapters.
  Future<void> discover(BuildContext context,
      {List<String> excludeUrls = const []}) async {
    final url = state.url.trim();

    if (!SitemapService().isValidUrl(url)) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: 'Enter a valid http/https URL',
      );
      return;
    }

    state = state.copyWith(status: ImportStatus.loading, errorMessage: null);

    final db = ref.read(appDatabaseProvider);

    // --- Duplicate detection ---
    final existingChapter = await db.chaptersDao.findByUrl(url);
    if (existingChapter != null) {
      if (context.mounted) {
        context.pop();
        context.push('/reader/${existingChapter.id}');
      }
      return;
    }

    final existingResource = await db.resourcesDao.findByUrl(url);
    if (existingResource != null) {
      if (context.mounted) {
        context.pop();
        context.push('/resource/${existingResource.id}');
      }
      return;
    }

    // --- Sitemap discovery ---
    // _runDiscovery returns true when the single-page fallback was used.
    final isFallback = await _runDiscovery(url, excludeUrls: excludeUrls);
    if (isFallback && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't detect other chapters — importing as a single resource",
          ),
        ),
      );
    }
  }

  /// Re-scans at the current maxDepth. Skips duplicate detection.
  Future<void> rescan(BuildContext context) async {
    final url = state.url.trim();
    state = state.copyWith(status: ImportStatus.loading, errorMessage: null);
    final isFallback = await _runDiscovery(url);
    if (isFallback && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't detect other chapters — importing as a single resource",
          ),
        ),
      );
    }
  }

  /// Runs sitemap discovery and updates state. Returns true if single-page fallback was used.
  /// [excludeUrls] are chapter URLs already present in a resource — filtered from results.
  Future<bool> _runDiscovery(String url,
      {List<String> excludeUrls = const []}) async {
    final rawPages =
        await SitemapService().discover(url, maxDepth: state.maxDepth);
    final pages = excludeUrls.isEmpty
        ? rawPages
        : rawPages?.where((p) => !excludeUrls.contains(p.url)).toList();

    if (pages == null || pages.isEmpty) {
      final title = _titleFromUrl(url);
      final singlePage = SitemapPage(url: url, title: title);
      state = state.copyWith(
        status: ImportStatus.ready,
        allPages: [singlePage],
        deselectedUrls: [],
        resourceName: state.resourceName.isEmpty ? title : state.resourceName,
      );
      return true; // single-page fallback
    } else {
      final derivedName = pages.isNotEmpty ? pages.first.title : '';
      state = state.copyWith(
        status: ImportStatus.ready,
        allPages: pages,
        deselectedUrls: [],
        resourceName:
            state.resourceName.isEmpty ? derivedName : state.resourceName,
      );
      return false;
    }
  }

  /// Writes the resource + selected chapters to the DB, then navigates to the reader.
  Future<void> confirm(BuildContext context) async {
    final selected = state.selectedPages;
    if (selected.isEmpty) return;

    state = state.copyWith(status: ImportStatus.loading);

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();

    // Derive resource title from field or first page title
    final resourceTitle = state.resourceName.trim().isNotEmpty
        ? state.resourceName.trim()
        : selected.first.title;

    // 1. Insert resource
    final resourceId = await db.resourcesDao.insertResource(
      ResourcesCompanion(
        title: Value(resourceTitle),
        description: state.description.trim().isEmpty
            ? const Value.absent()
            : Value(state.description.trim()),
        url: Value(state.url.trim()),
        createdAt: Value(now),
      ),
    );

    // 2. Insert chapters one at a time to capture the first ID
    int firstChapterId = -1;
    for (int i = 0; i < selected.length; i++) {
      final chapterId = await db.chaptersDao.insertChapter(
        ChaptersCompanion(
          resourceId: Value(resourceId),
          title: Value(selected[i].title),
          url: Value(selected[i].url),
          position: Value(i),
          createdAt: Value(now),
        ),
      );
      if (i == 0) firstChapterId = chapterId;
    }

    // 3. Set the first chapter as the resume target
    await db.resourcesDao.updateLastOpened(resourceId, firstChapterId);

    // 4. Navigate: close sheet → open reader
    if (context.mounted) {
      context.pop();
      context.push('/reader/$firstChapterId');
    }
  }

  void reset() => state = const ImportState();

  String _titleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) return uri.host;
      return segments.last
          .replaceAll(RegExp(r'[-_]'), ' ')
          .replaceAll(RegExp(r'\.\w+$'), '')
          .split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
    } catch (_) {
      return url;
    }
  }
}

final importNotifierProvider =
    NotifierProvider.autoDispose<ImportNotifier, ImportState>(
  ImportNotifier.new,
);
