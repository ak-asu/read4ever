import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../db/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/resources_provider.dart';
import '../../theme/app_colors.dart';
import '../import/import_screen.dart';
import 'widgets/tag_input.dart';

class ResourceDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ResourceDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ResourceDetailScreen> createState() =>
      _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends ConsumerState<ResourceDetailScreen> {
  late int _resourceId;

  // Controllers for inline editing
  late TextEditingController _titleController;
  late TextEditingController _descController;

  // Focus nodes — auto-save on blur
  final _titleFocus = FocusNode();
  final _descFocus = FocusNode();

  // Track last-saved values to avoid spurious DB writes
  String _savedTitle = '';
  String _savedDesc = '';

  @override
  void initState() {
    super.initState();
    _resourceId = int.parse(widget.id);
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _titleFocus.addListener(_onTitleFocusChange);
    _descFocus.addListener(_onDescFocusChange);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocus.removeListener(_onTitleFocusChange);
    _descFocus.removeListener(_onDescFocusChange);
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  void _onTitleFocusChange() {
    if (!_titleFocus.hasFocus) _saveTitle();
  }

  void _onDescFocusChange() {
    if (!_descFocus.hasFocus) _saveDesc();
  }

  Future<void> _saveTitle() async {
    final value = _titleController.text.trim();
    if (value.isEmpty || value == _savedTitle) return;
    _savedTitle = value;
    await ref.read(appDatabaseProvider).resourcesDao.updateResource(
          ResourcesCompanion(
            id: Value(_resourceId),
            title: Value(value),
          ),
        );
  }

  Future<void> _saveDesc() async {
    final value = _descController.text.trim();
    if (value == _savedDesc) return;
    _savedDesc = value;
    await ref.read(appDatabaseProvider).resourcesDao.updateResource(
          ResourcesCompanion(
            id: Value(_resourceId),
            description: Value(value.isEmpty ? null : value),
          ),
        );
  }

  Future<void> _deleteChapter(BuildContext context, Chapter chapter) async {
    final db = ref.read(appDatabaseProvider);
    final highlightCount =
        await db.highlightsDao.countByChapter(chapter.id);
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete chapter?'),
        content: highlightCount > 0
            ? Text(
                'This will also delete $highlightCount highlight${highlightCount == 1 ? '' : 's'} in this chapter.',
              )
            : const Text('This chapter will be removed from the resource.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await db.chaptersDao.deleteById(chapter.id);
    }
  }

  Future<void> _deleteResource(
      BuildContext context, Resource resource) async {
    final db = ref.read(appDatabaseProvider);
    final highlightCount =
        await db.highlightsDao.countByResource(_resourceId);
    final bookmarkCount =
        await db.chaptersDao.countBookmarkedByResource(_resourceId);
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${resource.title}"?'),
        content: Text(
          'This will permanently delete $highlightCount highlight${highlightCount == 1 ? '' : 's'} and $bookmarkCount bookmark${bookmarkCount == 1 ? '' : 's'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await db.resourcesDao.deleteById(_resourceId);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final resourceAsync = ref.watch(resourceStreamProvider(_resourceId));
    final chaptersAsync = ref.watch(resourceChaptersProvider(_resourceId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return resourceAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (resource) {
        if (resource == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Resource not found.')),
          );
        }

        // Sync controller text on first load (don't overwrite while editing)
        if (_savedTitle.isEmpty && resource.title.isNotEmpty) {
          _savedTitle = resource.title;
          _titleController.text = resource.title;
        }
        if (_savedDesc.isEmpty && resource.description != null) {
          _savedDesc = resource.description!;
          _descController.text = resource.description!;
        }

        final chapters = chaptersAsync.valueOrNull ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Resource'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete resource',
                onPressed: () => _deleteResource(context, resource),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Header: editable title + description ──────────────────
              TextField(
                controller: _titleController,
                focusNode: _titleFocus,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(
                  hintText: 'Resource title',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _saveTitle(),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _descController,
                focusNode: _descFocus,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: secondaryColor),
                decoration: InputDecoration(
                  hintText: 'Add a description…',
                  hintStyle: TextStyle(color: secondaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                onSubmitted: (_) => _saveDesc(),
              ),

              const Divider(height: 32),

              // ── Tags ──────────────────────────────────────────────────
              Text(
                'Tags',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: secondaryColor),
              ),
              const SizedBox(height: 8),
              TagInput(resourceId: _resourceId),

              const Divider(height: 32),

              // ── Chapters ──────────────────────────────────────────────
              Text(
                'Chapters',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: secondaryColor),
              ),
              const SizedBox(height: 8),

              if (chapters.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No chapters yet.',
                    style: TextStyle(color: secondaryColor),
                  ),
                ),

              // ReorderableListView needs a fixed height or to be in a Column/shrinkWrap.
              // shrinkWrap + NeverScrollableScrollPhysics lets it live inside ListView.
              if (chapters.isNotEmpty)
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: chapters.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final reordered = List<Chapter>.from(chapters);
                    final item = reordered.removeAt(oldIndex);
                    reordered.insert(newIndex, item);
                    ref
                        .read(appDatabaseProvider)
                        .chaptersDao
                        .reorder(reordered.map((c) => c.id).toList());
                  },
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return ListTile(
                      key: ValueKey(chapter.id),
                      leading: chapter.isDone
                          ? const Icon(Icons.check_circle,
                              color: AppColors.accent)
                          : const Icon(Icons.radio_button_unchecked,
                              color: AppColors.accent),
                      title: Text(
                        chapter.title,
                        style: chapter.isDone
                            ? TextStyle(
                                color: secondaryColor,
                                decoration: TextDecoration.lineThrough,
                              )
                            : null,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Delete chapter',
                            onPressed: () =>
                                _deleteChapter(context, chapter),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ],
                      ),
                      onTap: () => context.push('/reader/${chapter.id}'),
                    );
                  },
                ),

              const SizedBox(height: 8),

              // ── Import more chapters ──────────────────────────────────
              OutlinedButton.icon(
                onPressed: () {
                  final existingUrls =
                      chapters.map((c) => c.url).toList();
                  showImportBottomSheet(
                    context,
                    initialUrl: resource.url,
                    excludeUrls: existingUrls,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Import more chapters'),
              ),

              const Divider(height: 32),

              // ── Delete resource ───────────────────────────────────────
              OutlinedButton(
                onPressed: () => _deleteResource(context, resource),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Delete Resource'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
