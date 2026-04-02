import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/import_provider.dart';
import '../../../theme/app_colors.dart';

class SitemapChapterList extends ConsumerWidget {
  const SitemapChapterList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importNotifierProvider);
    final notifier = ref.read(importNotifierProvider.notifier);
    final isStandalone = state.allPages.length == 1;
    final deselected = state.deselectedUrls.toSet();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return ListView.builder(
      primary: false,
      itemCount: state.allPages.length,
      itemBuilder: (context, index) {
        final page = state.allPages[index];
        final isSelected = !deselected.contains(page.url);

        return CheckboxListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          activeColor: AppColors.accent,
          // Standalone mode: lock the only checkbox — can't deselect it
          value: isStandalone ? true : isSelected,
          onChanged: isStandalone ? null : (_) => notifier.togglePage(page),
          title: Text(
            page.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            page.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: secondaryColor),
          ),
        );
      },
    );
  }
}
