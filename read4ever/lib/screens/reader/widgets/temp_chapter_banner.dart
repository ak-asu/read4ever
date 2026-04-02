import 'package:flutter/material.dart';

/// Persistent banner shown when the WebView is displaying a URL that isn't
/// part of the current resource. Offers to add the page as a new chapter or
/// return to the original chapter.
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.inverseSurface,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pageTitle != null && pageTitle!.isNotEmpty
                  ? '"$pageTitle" isn\'t in your library'
                  : 'This page isn\'t in your library',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onInverseSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.inversePrimary,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onDismiss,
            child: const Text('Dismiss'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.inversePrimary,
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
