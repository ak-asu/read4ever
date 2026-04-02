import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../db/database.dart';
import '../../../services/highlight_service.dart';
import '../../../theme/app_colors.dart';

/// Bottom sheet shown when the user taps a highlight mark in the reader.
///
/// Displays the highlighted text, its note (if any), and prev/next arrows to
/// cycle through all highlights on the current chapter page.  Edits and
/// deletions are applied immediately: note saves update the mark's dashed
/// underline style via [HighlightService], and deletions remove the DOM mark.
class ReaderHighlightSheet extends ConsumerStatefulWidget {
  final List<Highlight> highlights;
  final int initialIndex;
  final HighlightService highlightService;

  const ReaderHighlightSheet({
    super.key,
    required this.highlights,
    required this.initialIndex,
    required this.highlightService,
  });

  @override
  ConsumerState<ReaderHighlightSheet> createState() =>
      _ReaderHighlightSheetState();
}

class _ReaderHighlightSheetState extends ConsumerState<ReaderHighlightSheet> {
  late List<Highlight> _highlights;
  late int _index;
  bool _editingNote = false;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _highlights = List.of(widget.highlights);
    _index = widget.initialIndex;
    _noteController = TextEditingController(text: _current.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Highlight get _current => _highlights[_index];

  void _goTo(int index) {
    setState(() {
      _index = index;
      _editingNote = false;
      _noteController.text = _highlights[index].note ?? '';
    });
  }

  Future<void> _saveNote() async {
    final text = _noteController.text.trim();
    final note = text.isEmpty ? null : text;
    await widget.highlightService.updateNote(_current.id, note);
    final updated = Highlight(
      id: _current.id,
      chapterId: _current.chapterId,
      selectedText: _current.selectedText,
      xpathStart: _current.xpathStart,
      xpathEnd: _current.xpathEnd,
      startOffset: _current.startOffset,
      endOffset: _current.endOffset,
      note: note,
      createdAt: _current.createdAt,
    );
    setState(() {
      _highlights[_index] = updated;
      _editingNote = false;
    });
  }

  Future<void> _delete() async {
    await widget.highlightService.removeHighlight(_current.id);
    final newList = List.of(_highlights)..removeAt(_index);
    if (newList.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() {
      _highlights = newList;
      _index = _index.clamp(0, newList.length - 1);
      _editingNote = false;
      _noteController.text = _highlights[_index].note ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = _current;
    final total = _highlights.length;
    final note = _noteController.text.trim();
    final hasNote = note.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Prev / counter / Next navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                tooltip: 'Previous highlight',
              ),
              Text(
                '${ _index + 1} of $total',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    _index < total - 1 ? () => _goTo(_index + 1) : null,
                tooltip: 'Next highlight',
              ),
            ],
          ),

          const Divider(height: 1),
          const SizedBox(height: 12),

          // Highlighted text
          Text(
            h.selectedText,
            style: theme.textTheme.bodyMedium,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Note section
          if (_editingNote) ...[
            TextField(
              controller: _noteController,
              autofocus: true,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _editingNote = false;
                      _noteController.text = h.note ?? '';
                    });
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _saveNote,
                  child: const Text('Save'),
                ),
              ],
            ),
          ] else ...[
            if (hasNote) ...[
              Text(
                note,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _editingNote = true),
                  icon: Icon(
                    hasNote ? Icons.edit_note : Icons.note_add_outlined,
                    size: 18,
                  ),
                  label: Text(hasNote ? 'Edit note' : 'Add note'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
