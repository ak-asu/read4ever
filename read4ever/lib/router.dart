import 'package:go_router/go_router.dart';
import 'providers/reader_provider.dart';
import 'screens/library/library_screen.dart';
import 'screens/bookmarks/bookmarks_screen.dart';
import 'screens/highlights/highlights_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/resource_detail/resource_detail_screen.dart';
import 'screens/reader/reader_screen.dart';
import 'screens/import/import_screen.dart';
import 'widgets/drawer_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/library',
  routes: [
    ShellRoute(
      builder: (context, state, child) => DrawerScaffold(
        state: state,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/library',
          builder: (context, state) => const LibraryScreen(),
        ),
        GoRoute(
          path: '/bookmarks',
          builder: (context, state) => const BookmarksScreen(),
        ),
        GoRoute(
          path: '/highlights',
          builder: (context, state) => const HighlightsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/resource/:id',
      builder: (context, state) => ResourceDetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/reader/:chapterId',
      // CustomTransitionPage with zero duration — seamless chapter-to-chapter
      // navigation via pushReplacement in the chapter dropdown.
      pageBuilder: (context, state) {
        final chapterId = int.parse(state.pathParameters['chapterId']!);
        final readerContext =
            (state.extra as ReaderContext?) ?? const ReaderContext();
        return CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
          child: ReaderScreen(
            chapterId: chapterId,
            readerContext: readerContext,
          ),
        );
      },
    ),
    GoRoute(
      path: '/import',
      builder: (context, state) => const ImportScreen(),
    ),
  ],
);
