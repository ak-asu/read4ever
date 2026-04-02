import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../db/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/tags_provider.dart';
import '../../../theme/app_colors.dart';

/// Tag chip row + autocomplete text field.
/// Displays tags as deletable InputChips and allows adding new or existing tags.
class TagInput extends ConsumerStatefulWidget {
  final int resourceId;

  const TagInput({super.key, required this.resourceId});

  @override
  ConsumerState<TagInput> createState() => _TagInputState();
}

class _TagInputState extends ConsumerState<TagInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _addTag(String name) async {
    final trimmed = name.trim().replaceAll(',', '').trim();
    if (trimmed.isEmpty) return;
    _controller.clear();
    await ref
        .read(appDatabaseProvider)
        .tagsDao
        .addTagToResource(widget.resourceId, trimmed);
  }

  Future<void> _removeTag(Tag tag) async {
    await ref
        .read(appDatabaseProvider)
        .tagsDao
        .removeTagFromResource(widget.resourceId, tag.id);
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsForResourceProvider(widget.resourceId));
    final allTagsAsync = ref.watch(allTagsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final currentTags = tagsAsync.valueOrNull ?? [];
    final currentTagNames = currentTags.map((t) => t.name).toSet();
    final allTags = allTagsAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chip row — shown only when tags exist
        if (currentTags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: currentTags
                .map(
                  (tag) => InputChip(
                    label: Text(tag.name),
                    onDeleted: () => _removeTag(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        if (currentTags.isNotEmpty) const SizedBox(height: 8),

        // Autocomplete field
        Autocomplete<Tag>(
          optionsBuilder: (textEditingValue) {
            final input = textEditingValue.text.trim().toLowerCase();
            if (input.isEmpty) return const Iterable.empty();
            return allTags.where((t) =>
                t.name.toLowerCase().startsWith(input) &&
                !currentTagNames.contains(t.name));
          },
          displayStringForOption: (tag) => tag.name,
          onSelected: (tag) {
            _addTag(tag.name);
            // Re-focus so the user can keep adding
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _focusNode.requestFocus();
            });
          },
          fieldViewBuilder: (context, fieldController, fieldFocusNode, _) {
            // Keep our local controller in sync with the Autocomplete controller
            fieldController.addListener(() {
              if (fieldController.text != _controller.text) {
                _controller.text = fieldController.text;
              }
            });
            return TextField(
              controller: fieldController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                hintText: 'Add tag…',
                hintStyle: TextStyle(color: secondaryColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              inputFormatters: [
                // Intercept comma → treat as submit
                _CommaSplitter(onCommit: _addTag),
              ],
              onSubmitted: _addTag,
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

/// TextInputFormatter that intercepts comma characters and fires [onCommit]
/// with the text typed so far, then clears the field.
class _CommaSplitter extends TextInputFormatter {
  final void Function(String) onCommit;
  _CommaSplitter({required this.onCommit});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.contains(',')) {
      final parts = newValue.text.split(',');
      for (final part in parts.sublist(0, parts.length - 1)) {
        if (part.trim().isNotEmpty) onCommit(part);
      }
      // Keep the text after the last comma in the field
      final remaining = parts.last;
      return TextEditingValue(
        text: remaining,
        selection: TextSelection.collapsed(offset: remaining.length),
      );
    }
    return newValue;
  }
}
