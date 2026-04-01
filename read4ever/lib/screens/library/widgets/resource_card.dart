import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/resource_with_status.dart';
import '../../../theme/app_colors.dart';

class ResourceCard extends StatelessWidget {
  final ResourceWithStatus item;

  const ResourceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final resource = item.resource;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final titleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          color: item.isDone ? secondaryColor : null,
        );
    final descStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: secondaryColor,
        );
    final metaStyle = Theme.of(context).textTheme.labelSmall!.copyWith(
          color: secondaryColor,
        );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/resource/${resource.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resource.title, style: titleStyle),
              if (resource.description != null &&
                  resource.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  resource.description!,
                  style: descStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${item.doneCount} / ${item.totalCount} chapters',
                    style: metaStyle,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              if (resource.lastOpenedChapterId != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/reader/${resource.lastOpenedChapterId}'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Resume'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
