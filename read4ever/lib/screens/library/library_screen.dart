import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/resources_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/resource_card.dart';
import 'widgets/continue_reading_strip.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider);
    final continueReadingAsync = ref.watch(continueReadingProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'library_fab',
        onPressed: () => context.push('/import'),
        child: const Icon(Icons.add),
      ),
      body: resourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (resources) {
          if (resources.isEmpty) {
            return _EmptyState();
          }

          final continueReading = continueReadingAsync.valueOrNull ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ContinueReadingStrip(items: continueReading),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      ResourceCard(item: resources[index]),
                  childCount: resources.length,
                ),
              ),
              // Bottom padding so FAB doesn't overlap last card
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: secondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Your library is empty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to import your first resource',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: secondaryColor,
                ),
          ),
        ],
      ),
    );
  }
}
