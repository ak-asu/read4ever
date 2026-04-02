import 'package:flutter/material.dart';

import '../../../models/highlight_with_chapter_and_resource.dart';
import '../../../theme/app_colors.dart';

/// A single highlight entry in the Highlights screen list.
///
/// Single-tap → opens the detail bottom sheet (via [onTap]).
/// Double-tap → toggles between 2-line truncation and full text (local state).
///
/// Uses [GestureDetector] rather than [InkWell] with onDoubleTap because
/// InkWell delays the single-tap by kDoubleTapTimeout to distinguish the two
/// gestures — on MIUI this can conflict with the system's touch handling and
/// make double-tap unreliable. GestureDetector resolves both simultaneously
/// without the tap-delay side-effect.
class HighlightListItem extends StatefulWidget {
  final HighlightWithChapterAndResource item;
  final VoidCallback onTap;

  const HighlightListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<HighlightListItem> createState() => _HighlightListItemState();
}

class _HighlightListItemState extends State<HighlightListItem> {
  bool _expanded = false;

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = widget.item.highlight;
    final c = widget.item.chapter;
    final r = widget.item.resource;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onDoubleTap: _toggleExpanded,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teal accent bar on the left
              Container(
                width: 3,
                constraints: const BoxConstraints(minHeight: 36),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(right: 12, top: 2),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Highlighted text — truncated to 2 lines by default
                    Text(
                      h.selectedText,
                      style: theme.textTheme.bodyMedium,
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Resource · Chapter metadata + expand indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${r.title} · ${c.title}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Expand/collapse toggle — visible affordance for
                        // double-tap; also tappable directly for convenience.
                        GestureDetector(
                          onTap: _toggleExpanded,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              _expanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Note preview (if present)
                    if (h.note != null && h.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        h.note!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: _expanded ? null : 1,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
