import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/resource_with_chapter.dart';
import '../../../theme/app_colors.dart';

class ContinueReadingStrip extends StatelessWidget {
  final List<ResourceWithChapter> items;

  const ContinueReadingStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Continue Reading',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: secondaryColor,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ContinueReadingCard(item: item);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final ResourceWithChapter item;

  const _ContinueReadingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push('/reader/${item.resource.lastOpenedChapterId}'),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            item.resource.title,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
