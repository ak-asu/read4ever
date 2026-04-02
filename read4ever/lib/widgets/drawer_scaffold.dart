import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/database_provider.dart';
import '../providers/multi_select_provider.dart';

class DrawerScaffold extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const DrawerScaffold({
    super.key,
    required this.child,
    required this.state,
  });

  static const _destinations = [
    _DrawerDestination(
        label: 'Library', icon: Icons.menu_book_outlined, route: '/library'),
    _DrawerDestination(
        label: 'Bookmarks', icon: Icons.bookmark_outline, route: '/bookmarks'),
    _DrawerDestination(
        label: 'Highlights',
        icon: Icons.highlight_outlined,
        route: '/highlights'),
    _DrawerDestination(
        label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  ];

  String _titleFor(String location) {
    if (location.startsWith('/bookmarks')) return 'Bookmarks';
    if (location.startsWith('/highlights')) return 'Highlights';
    if (location.startsWith('/settings')) return 'Settings';
    return 'Library';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = state.uri.toString();

    AppBar appBar;

    if (location.startsWith('/highlights')) {
      final selected = ref.watch(highlightsMultiSelectProvider);
      final selectNotifier = ref.read(highlightsMultiSelectProvider.notifier);
      final allIds = ref.watch(highlightsFilteredIdsProvider);

      if (selected.isNotEmpty) {
        final allSelected =
            allIds.isNotEmpty && selected.length == allIds.length;
        appBar = AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Clear selection',
            onPressed: selectNotifier.clear,
          ),
          title: Text('${selected.length} selected'),
          actions: [
            TextButton(
              onPressed: () => selectNotifier.toggleSelectAll(allIds),
              child: Text(allSelected ? 'Deselect all' : 'Select all'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete selected',
              onPressed: () => _confirmDeleteHighlights(
                context,
                ref,
                selected.toList(),
                selectNotifier,
              ),
            ),
          ],
        );
      } else {
        appBar = AppBar(title: Text(_titleFor(location)));
      }
    } else if (location.startsWith('/bookmarks')) {
      final selected = ref.watch(bookmarksMultiSelectProvider);
      final selectNotifier = ref.read(bookmarksMultiSelectProvider.notifier);
      final allIds = ref.watch(bookmarksAllIdsProvider);

      if (selected.isNotEmpty) {
        final allSelected =
            allIds.isNotEmpty && selected.length == allIds.length;
        appBar = AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Clear selection',
            onPressed: selectNotifier.clear,
          ),
          title: Text('${selected.length} selected'),
          actions: [
            TextButton(
              onPressed: () => selectNotifier.toggleSelectAll(allIds),
              child: Text(allSelected ? 'Deselect all' : 'Select all'),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_remove_outlined),
              tooltip: 'Remove bookmarks',
              onPressed: () => _confirmUnbookmark(
                context,
                ref,
                selected.toList(),
                selectNotifier,
              ),
            ),
          ],
        );
      } else {
        appBar = AppBar(title: Text(_titleFor(location)));
      }
    } else {
      appBar = AppBar(title: Text(_titleFor(location)));
    }

    return Scaffold(
      appBar: appBar,
      drawer: NavigationDrawer(
        selectedIndex: _destinations.indexWhere(
          (d) => location.startsWith(d.route),
        ),
        onDestinationSelected: (index) {
          Navigator.of(context).pop(); // close drawer
          context.go(_destinations[index].route);
        },
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'LearnStack',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          ..._destinations.map(
            (d) => NavigationDrawerDestination(
              icon: Icon(d.icon),
              label: Text(d.label),
            ),
          ),
        ],
      ),
      body: child,
    );
  }

  Future<void> _confirmDeleteHighlights(
    BuildContext context,
    WidgetRef ref,
    List<int> ids,
    MultiSelectNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete highlights?'),
        content: Text(
          'Delete ${ids.length} highlight${ids.length == 1 ? '' : 's'}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).highlightsDao.bulkDelete(ids);
      notifier.clear();
    }
  }

  Future<void> _confirmUnbookmark(
    BuildContext context,
    WidgetRef ref,
    List<int> ids,
    MultiSelectNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove bookmarks?'),
        content: Text(
          'Remove ${ids.length} bookmark${ids.length == 1 ? '' : 's'}? The chapters will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).chaptersDao.bulkUnbookmark(ids);
      notifier.clear();
    }
  }
}

class _DrawerDestination {
  final String label;
  final IconData icon;
  final String route;
  const _DrawerDestination({
    required this.label,
    required this.icon,
    required this.route,
  });
}
