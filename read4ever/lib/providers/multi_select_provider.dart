import 'package:flutter_riverpod/flutter_riverpod.dart';

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
