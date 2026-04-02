import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/highlight_with_chapter_and_resource.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/reader_provider.dart';
import '../../../theme/app_colors.dart';

/// Detail bottom sheet for a single highlight.
///
/// Shows: chapter + resource header, note text (if any) with inline edit,
/// "Open in reader" (navigates + scrolls to the mark), and a Delete button.
class HighlightBottomSheet extends ConsumerStatefulWidget {
  final HighlightWithChapterAndResource item;

  const HighlightBottomSheet({super.key, required this.item});

  @override
  ConsumerState<HighlightBottomSheet> createState() =>
      _HighlightBottomSheetState();
}

class _HighlightBottomSheetState extends ConsumerState<HighlightBottomSheet> {
  bool _editingNote = false;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController =
        TextEditingController(text: widget.item.highlight.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final note = _noteController.text.trim();
    await ref.read(appDatabaseProvider).highlightsDao.updateNote(
          widget.item.highlight.id,
          note.isEmpty ? null : note,
        );
    if (mounted) setState(() => _editingNote = false);
  }

  Future<void> _delete() async {
    final nav = Navigator.of(context);
    await ref
        .read(appDatabaseProvider)
        .highlightsDao
        .deleteHighlight(widget.item.highlight.id);
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = widget.item.highlight;
    final c = widget.item.chapter;
    final r = widget.item.resource;

    // Note text as it currently stands (reflects edits saved this session)
    final currentNote = _noteController.text.trim();
    final hasNote = currentNote.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Chapter Title in Resource Title"
          Text(
            '${c.title} in ${r.title}',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Note area
          if (_editingNote)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      onPressed: () => setState(() => _editingNote = false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _saveNote,
                      child: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            )
          else ...[
            if (hasNote) ...[
              Text(
                currentNote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
            ],
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
          ],

          const SizedBox(height: 8),

          // Open in reader
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Pop the bottom sheet first, then navigate.
                // Both calls are synchronous in the same frame — GoRouter is
                // still accessible via context before the route is disposed.
                Navigator.of(context).pop();
                context.push(
                  '/reader/${c.id}',
                  extra: ReaderContext(
                    source: ReaderSource.highlights,
                    scrollToHighlightId: h.id,
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Open in reader'),
            ),
          ),

          const SizedBox(height: 8),

          // Delete
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete highlight'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
