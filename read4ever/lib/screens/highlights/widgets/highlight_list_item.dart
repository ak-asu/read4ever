import 'package:flutter/material.dart';

import '../../../models/highlight_with_chapter_and_resource.dart';
import '../../../theme/app_colors.dart';

/// A single highlight entry in the Highlights screen list.
///
/// Normal mode:
///   Single-tap → [onTap] (opens detail bottom sheet)
///   Double-tap → toggles expand/collapse (local state)
///   Long-press → [onLongPress] (enters multi-select mode)
///
/// Multi-select mode ([isMultiSelectMode] == true):
///   Tap → [onToggleSelect]
///   Leading area shows a [Checkbox] instead of the teal accent bar.
class HighlightListItem extends StatefulWidget {
  final HighlightWithChapterAndResource item;

  /// Normal-mode callbacks
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Multi-select mode
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const HighlightListItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    required this.onToggleSelect,
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

    Widget leading;
    if (widget.isMultiSelectMode) {
      leading = Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Checkbox(
          value: widget.isSelected,
          onChanged: (_) => widget.onToggleSelect(),
          activeColor: AppColors.accent,
        ),
      );
    } else {
      leading = Container(
        width: 3,
        constraints: const BoxConstraints(minHeight: 36),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(2),
        ),
        margin: const EdgeInsets.only(right: 12, top: 2),
      );
    }

    return Material(
      color: widget.isSelected
          ? AppColors.accentSubtle.withValues(alpha: 0.4)
          : Colors.transparent,
      child: InkWell(
        onTap: widget.isMultiSelectMode ? widget.onToggleSelect : widget.onTap,
        onLongPress: widget.isMultiSelectMode ? null : widget.onLongPress,
        onDoubleTap: widget.isMultiSelectMode ? null : _toggleExpanded,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
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
                        if (!widget.isMultiSelectMode)
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
