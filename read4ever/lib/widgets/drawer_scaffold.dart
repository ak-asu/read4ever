import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DrawerScaffold extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const DrawerScaffold({
    super.key,
    required this.child,
    required this.state,
  });

  static const _destinations = [
    _DrawerDestination(label: 'Library', icon: Icons.menu_book_outlined, route: '/library'),
    _DrawerDestination(label: 'Bookmarks', icon: Icons.bookmark_outline, route: '/bookmarks'),
    _DrawerDestination(label: 'Highlights', icon: Icons.highlight_outlined, route: '/highlights'),
    _DrawerDestination(label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  ];

  String _titleFor(String location) {
    if (location.startsWith('/bookmarks')) return 'Bookmarks';
    if (location.startsWith('/highlights')) return 'Highlights';
    if (location.startsWith('/settings')) return 'Settings';
    return 'Library';
  }

  @override
  Widget build(BuildContext context) {
    final location = state.uri.toString();
    final title = _titleFor(location);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
