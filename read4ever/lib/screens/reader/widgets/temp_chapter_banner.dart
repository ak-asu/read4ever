import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Persistent banner shown when the WebView is displaying a URL that isn't
/// part of the current resource. Styled to match the app's surface/sheet
/// aesthetic — not a high-contrast system snackbar.
class TempChapterBanner extends StatelessWidget {
  final String? pageTitle;
  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  const TempChapterBanner({
    super.key,
    required this.pageTitle,
    required this.onAdd,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.accent,
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              (pageTitle?.isNotEmpty ?? false)
                  ? '"$pageTitle" isn\'t in your library'
                  : 'This page isn\'t in your library',
              style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onDismiss,
            child: const Text('Dismiss'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onAdd,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
