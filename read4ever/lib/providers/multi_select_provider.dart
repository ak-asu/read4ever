import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bookmarks_provider.dart';
import 'highlights_provider.dart';

/// Shared multi-select notifier used across list screens.
///
/// State is the set of currently-selected IDs.
/// Multi-select mode is considered active when [state] is non-empty.
/// Exits naturally when [clear] is called or the last item is deselected.
class MultiSelectNotifier extends AutoDisposeNotifier<Set<int>> {
  @override
  Set<int> build() => const {};

  void toggle(int id) {
    final next = Set<int>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  void selectAll(List<int> ids) {
    state = Set<int>.from(ids);
  }

  /// Selects all if not every id is currently selected; deselects all otherwise.
  void toggleSelectAll(List<int> ids) {
    if (ids.isNotEmpty &&
        state.length == ids.length &&
        state.containsAll(ids)) {
      state = const {};
    } else {
      state = Set<int>.from(ids);
    }
  }

  void clear() {
    state = const {};
  }
}

/// Multi-select state for the Highlights screen.
final highlightsMultiSelectProvider =
    AutoDisposeNotifierProvider<MultiSelectNotifier, Set<int>>(
  MultiSelectNotifier.new,
);

/// Multi-select state for the Bookmarks screen.
final bookmarksMultiSelectProvider =
    AutoDisposeNotifierProvider<MultiSelectNotifier, Set<int>>(
  MultiSelectNotifier.new,
);

/// Multi-select state for the ResourceDetail chapter list.
final resourceDetailMultiSelectProvider =
    AutoDisposeNotifierProvider<MultiSelectNotifier, Set<int>>(
  MultiSelectNotifier.new,
);

/// Derived list of highlight IDs that match the current filter.
/// Used by DrawerScaffold to drive the select-all toggle.
final highlightsFilteredIdsProvider = AutoDisposeProvider<List<int>>((ref) {
  final allAsync = ref.watch(highlightsProvider);
  final filter = ref.watch(highlightFilterNotifierProvider);
  return allAsync.when(
    data: (all) => all
        .where((item) {
          if (filter.resourceId != null &&
              item.resource.id != filter.resourceId) {
            return false;
          }
          if (filter.chapterId != null && item.chapter.id != filter.chapterId) {
            return false;
          }
          return true;
        })
        .map((item) => item.highlight.id)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Derived list of bookmarked chapter IDs.
/// Used by DrawerScaffold to drive the select-all toggle.
final bookmarksAllIdsProvider = AutoDisposeProvider<List<int>>((ref) {
  final bookmarks = ref.watch(bookmarksProvider);
  return bookmarks.maybeWhen(
    data: (items) => items.map((i) => i.chapter.id).toList(),
    orElse: () => [],
  );
});
