import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../db/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/multi_select_provider.dart';
import '../../providers/resources_provider.dart';
import '../../providers/tags_provider.dart';
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

  // Editing controllers
  late TextEditingController _titleController;
  late TextEditingController _descController;

  // Last-persisted values for dirty detection
  bool _initialized = false;
  String _savedTitle = '';
  String _savedDesc = '';

  // ── Pending changes (not written to DB until Save) ──────────────────────
  // Tags
  final List<String> _pendingAddedTagNames = [];
  final Set<int> _pendingRemovedTagIds = {};

  // Chapters
  List<int>? _pendingChapterOrder; // null = no reorder pending
  final Set<int> _pendingDeletedChapterIds = {};

  bool get _isDirty =>
      _titleController.text.trim() != _savedTitle ||
      _descController.text.trim() != _savedDesc ||
      _pendingAddedTagNames.isNotEmpty ||
      _pendingRemovedTagIds.isNotEmpty ||
      _pendingChapterOrder != null ||
      _pendingDeletedChapterIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _resourceId = int.parse(widget.id);
    _titleController = TextEditingController();
    _descController = TextEditingController();
    // Rebuild on text change so Save button enables/disables live.
    _titleController.addListener(_onTextChanged);
    _descController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _descController.removeListener(_onTextChanged);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  // ── Tag callbacks ─────────────────────────────────────────────────────────

  void _onTagAdd(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final dbTags =
        ref.read(tagsForResourceProvider(_resourceId)).valueOrNull ?? [];
    final lowerName = trimmed.toLowerCase();

    // If a DB tag with this name was marked for removal, just un-remove it.
    for (final tag in dbTags) {
      if (tag.name.toLowerCase() == lowerName &&
          _pendingRemovedTagIds.contains(tag.id)) {
        setState(() => _pendingRemovedTagIds.remove(tag.id));
        return;
      }
    }

    // Ignore if already present in the effective tag list.
    final existingNames = {
      ...dbTags
          .where((t) => !_pendingRemovedTagIds.contains(t.id))
          .map((t) => t.name.toLowerCase()),
      ..._pendingAddedTagNames.map((n) => n.toLowerCase()),
    };
    if (existingNames.contains(lowerName)) return;

    setState(() => _pendingAddedTagNames.add(trimmed));
  }

  void _onTagRemove(Tag tag) {
    if (tag.id < 0) {
      // Negative id = a pending-add (not yet in DB); remove by list index.
      final index = -tag.id - 1;
      if (index >= 0 && index < _pendingAddedTagNames.length) {
        setState(() => _pendingAddedTagNames.removeAt(index));
      }
    } else {
      setState(() => _pendingRemovedTagIds.add(tag.id));
    }
  }

  // ── Chapter helpers ───────────────────────────────────────────────────────

  List<Chapter> _computeDisplayChapters(List<Chapter> dbChapters) {
    // Hide chapters that are pending deletion.
    final filtered = dbChapters
        .where((c) => !_pendingDeletedChapterIds.contains(c.id))
        .toList();

    // Apply pending reorder if any.
    if (_pendingChapterOrder != null) {
      final orderMap = {
        for (int i = 0; i < _pendingChapterOrder!.length; i++)
          _pendingChapterOrder![i]: i,
      };
      filtered.sort((a, b) {
        final ai = orderMap[a.id] ?? 999999;
        final bi = orderMap[b.id] ?? 999999;
        return ai.compareTo(bi);
      });
    }

    return filtered;
  }

  // ── Save / Discard ────────────────────────────────────────────────────────

  Future<void> _saveAll() async {
    final db = ref.read(appDatabaseProvider);

    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != _savedTitle) {
      await db.resourcesDao.updateResource(
        ResourcesCompanion(id: Value(_resourceId), title: Value(newTitle)),
      );
      _savedTitle = newTitle;
    }

    final newDesc = _descController.text.trim();
    if (newDesc != _savedDesc) {
      await db.resourcesDao.updateResource(
        ResourcesCompanion(
          id: Value(_resourceId),
          description: Value(newDesc.isEmpty ? null : newDesc),
        ),
      );
      _savedDesc = newDesc;
    }

    for (final name in List<String>.from(_pendingAddedTagNames)) {
      await db.tagsDao.addTagToResource(_resourceId, name);
    }
    for (final tagId in Set<int>.from(_pendingRemovedTagIds)) {
      await db.tagsDao.removeTagFromResource(_resourceId, tagId);
    }

    // Reorder only IDs that aren't also being deleted.
    final orderToPersist = _pendingChapterOrder
        ?.where((id) => !_pendingDeletedChapterIds.contains(id))
        .toList();
    if (orderToPersist != null && orderToPersist.isNotEmpty) {
      await db.chaptersDao.reorder(orderToPersist);
    }

    if (_pendingDeletedChapterIds.isNotEmpty) {
      await db.chaptersDao.bulkDelete(_pendingDeletedChapterIds.toList());
    }

    if (!mounted) return;
    setState(() {
      _pendingAddedTagNames.clear();
      _pendingRemovedTagIds.clear();
      _pendingChapterOrder = null;
      _pendingDeletedChapterIds.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }

  Future<void> _showDiscardDialog() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('Discard all unsaved changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (shouldDiscard == true && mounted) context.pop();
  }

  // ── Chapter delete helpers ────────────────────────────────────────────────

  Future<void> _deleteChapter(BuildContext context, Chapter chapter) async {
    final db = ref.read(appDatabaseProvider);
    final highlightCount = await db.highlightsDao.countByChapter(chapter.id);
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _pendingDeletedChapterIds.add(chapter.id);
        _pendingChapterOrder?.remove(chapter.id);
      });
    }
  }

  Future<void> _bulkDeleteChapters(
    BuildContext context,
    List<int> ids,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete chapters?'),
        content: Text(
          'Delete ${ids.length} chapter${ids.length == 1 ? '' : 's'}? '
          'Associated highlights will also be deleted.',
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
    if (confirmed == true) {
      setState(() {
        _pendingDeletedChapterIds.addAll(ids);
        for (final id in ids) {
          _pendingChapterOrder?.remove(id);
        }
      });
      ref.read(resourceDetailMultiSelectProvider.notifier).clear();
    }
  }

  Future<void> _deleteResource(BuildContext context, Resource resource) async {
    final db = ref.read(appDatabaseProvider);
    final highlightCount = await db.highlightsDao.countByResource(_resourceId);
    final bookmarkCount =
        await db.chaptersDao.countBookmarkedByResource(_resourceId);
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${resource.title}"?'),
        content: Text(
          'This will permanently delete $highlightCount '
          'highlight${highlightCount == 1 ? '' : 's'} and '
          '$bookmarkCount bookmark${bookmarkCount == 1 ? '' : 's'}.',
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
    final tagsAsync = ref.watch(tagsForResourceProvider(_resourceId));
    final allTagsAsync = ref.watch(allTagsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final selected = ref.watch(resourceDetailMultiSelectProvider);
    final selectNotifier = ref.read(resourceDetailMultiSelectProvider.notifier);
    final isMultiSelect = selected.isNotEmpty;

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

        // One-time init from DB on first data load.
        if (!_initialized) {
          _initialized = true;
          _savedTitle = resource.title;
          _titleController.text = resource.title;
          _savedDesc = resource.description ?? '';
          _descController.text = resource.description ?? '';
        }

        final dbChapters = chaptersAsync.valueOrNull ?? [];
        final displayChapters = _computeDisplayChapters(dbChapters);
        final chapterIds = displayChapters.map((c) => c.id).toList();

        // Effective tags = DB tags minus pending removes, plus pending adds.
        final dbTags = tagsAsync.valueOrNull ?? [];
        final allTags = allTagsAsync.valueOrNull ?? [];
        final effectiveTags = [
          ...dbTags.where((t) => !_pendingRemovedTagIds.contains(t.id)),
          ...(_pendingAddedTagNames.asMap().entries.map(
                (e) => Tag(id: -(e.key + 1), name: e.value),
              )),
        ];

        // ── AppBar ────────────────────────────────────────────────────────
        final AppBar appBar = isMultiSelect
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear selection',
                  onPressed: selectNotifier.clear,
                ),
                title: Text('${selected.length} selected'),
                actions: [
                  TextButton(
                    onPressed: () => selectNotifier.selectAll(chapterIds),
                    child: const Text('Select all'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete selected',
                    onPressed: () =>
                        _bulkDeleteChapters(context, selected.toList()),
                  ),
                ],
              )
            : AppBar(
                title: const Text('Resource'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save_outlined),
                    tooltip: 'Save',
                    onPressed: _isDirty ? _saveAll : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete resource',
                    onPressed: () => _deleteResource(context, resource),
                  ),
                ],
              );

        return PopScope(
          canPop: !isMultiSelect && !_isDirty,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (isMultiSelect) {
              selectNotifier.clear();
              return;
            }
            _showDiscardDialog();
          },
          child: Scaffold(
            appBar: appBar,
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Editable title (bottom border only) ───────────────────
                TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.titleLarge,
                  decoration: const InputDecoration(
                    hintText: 'Resource title',
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.only(bottom: 4),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),

                // ── Editable description (bottom border, max 5 lines) ──────
                TextField(
                  controller: _descController,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: secondaryColor),
                  decoration: InputDecoration(
                    hintText: 'Add a description…',
                    hintStyle: TextStyle(color: secondaryColor),
                    border: const UnderlineInputBorder(),
                    contentPadding: const EdgeInsets.only(bottom: 4),
                  ),
                  maxLines: 5,
                  minLines: 1,
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
                TagInput(
                  currentTags: effectiveTags,
                  allTags: allTags,
                  onAdd: _onTagAdd,
                  onRemove: _onTagRemove,
                ),

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

                if (displayChapters.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No chapters yet.',
                      style: TextStyle(color: secondaryColor),
                    ),
                  ),

                if (displayChapters.isNotEmpty)
                  isMultiSelect
                      ? _buildMultiSelectChapterList(
                          context, displayChapters, selected, selectNotifier)
                      : _buildReorderableChapterList(
                          context, displayChapters, secondaryColor),

                const SizedBox(height: 8),

                // ── Import more chapters ──────────────────────────────────
                if (!isMultiSelect)
                  OutlinedButton.icon(
                    onPressed: () {
                      final existingUrls =
                          dbChapters.map((c) => c.url).toList();
                      showImportBottomSheet(
                        context,
                        initialUrl: resource.url,
                        excludeUrls: existingUrls,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Import more chapters'),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Chapter list: multi-select mode ──────────────────────────────────────

  Widget _buildMultiSelectChapterList(
    BuildContext context,
    List<Chapter> chapters,
    Set<int> selected,
    MultiSelectNotifier notifier,
  ) {
    return Column(
      children: chapters.map((chapter) {
        final isSelected = selected.contains(chapter.id);
        return Material(
          color: isSelected
              ? AppColors.accentSubtle.withValues(alpha: 0.4)
              : Colors.transparent,
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (_) => notifier.toggle(chapter.id),
              activeColor: AppColors.accent,
            ),
            title: Text(chapter.title),
            onTap: () => notifier.toggle(chapter.id),
          ),
        );
      }).toList(),
    );
  }

  // ── Chapter list: normal mode (reorderable, deferred) ────────────────────

  Widget _buildReorderableChapterList(
    BuildContext context,
    List<Chapter> chapters,
    Color secondaryColor,
  ) {
    final selectNotifier = ref.read(resourceDetailMultiSelectProvider.notifier);

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapters.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        final reordered = List<Chapter>.from(chapters);
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);
        setState(() {
          _pendingChapterOrder = reordered.map((c) => c.id).toList();
        });
      },
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return ListTile(
          key: ValueKey(chapter.id),
          leading: chapter.isDone
              ? const Icon(Icons.check_circle, color: AppColors.accent)
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
                onPressed: () => _deleteChapter(context, chapter),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
            ],
          ),
          onTap: () => context.push('/reader/${chapter.id}'),
          onLongPress: () => selectNotifier.toggle(chapter.id),
        );
      },
    );
  }
}
