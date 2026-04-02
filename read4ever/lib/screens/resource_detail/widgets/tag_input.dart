import 'package:flutter/material.dart';

import '../../../db/database.dart';
import '../../../theme/app_colors.dart';

/// Tag chip row + autocomplete text field.
/// Stateless regarding DB — parent owns the tag state and provides callbacks.
class TagInput extends StatefulWidget {
  final List<Tag> currentTags;
  final List<Tag> allTags;
  final void Function(String name) onAdd;
  final void Function(Tag tag) onRemove;

  const TagInput({
    super.key,
    required this.currentTags,
    required this.allTags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  // Captured from fieldViewBuilder so onSelected can clear + re-focus.
  FocusNode? _fieldFocusNode;
  TextEditingController? _fieldController;

  void _clearInputField() {
    final controller = _fieldController;
    if (controller == null) return;
    controller.value = const TextEditingValue();
  }

  void _submit(TextEditingController fieldController) {
    final text = fieldController.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    fieldController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fieldFocusNode?.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final currentTagNames =
        widget.currentTags.map((t) => t.name.toLowerCase()).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Chip row ──────────────────────────────────────────────────────
        if (widget.currentTags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.currentTags
                .map(
                  (tag) => InputChip(
                    label: Text(tag.name),
                    onDeleted: () => widget.onRemove(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        if (widget.currentTags.isNotEmpty) const SizedBox(height: 8),

        // ── Autocomplete + trailing + button ──────────────────────────────
        Autocomplete<Tag>(
          optionsBuilder: (textEditingValue) {
            final input = textEditingValue.text.trim().toLowerCase();
            if (input.isEmpty) return const Iterable.empty();
            return widget.allTags.where(
              (t) =>
                  t.name.toLowerCase().startsWith(input) &&
                  !currentTagNames.contains(t.name.toLowerCase()),
            );
          },
          displayStringForOption: (tag) => tag.name,
          onSelected: (tag) {
            widget.onAdd(tag.name);
            _clearInputField();
            // Clear the field text that Autocomplete fills in on selection.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _clearInputField();
              _fieldFocusNode?.requestFocus();
            });
          },
          fieldViewBuilder: (context, fieldController, fieldFocusNode, _) {
            _fieldFocusNode = fieldFocusNode;
            _fieldController = fieldController;
            return TextField(
              controller: fieldController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                hintText: 'Add tag…',
                hintStyle: TextStyle(color: secondaryColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add tag',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _submit(fieldController),
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(fieldController),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final tag = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(tag.name),
                        onTap: () => onSelected(tag),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
