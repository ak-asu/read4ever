import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/import_provider.dart';
import '../../../theme/app_colors.dart';

class AdvancedImportPanel extends ConsumerStatefulWidget {
  const AdvancedImportPanel({super.key});

  @override
  ConsumerState<AdvancedImportPanel> createState() =>
      _AdvancedImportPanelState();
}

class _AdvancedImportPanelState extends ConsumerState<AdvancedImportPanel> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    final s = ref.read(importNotifierProvider);
    _nameController = TextEditingController(text: s.resourceName);
    _descController = TextEditingController(text: s.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importNotifierProvider);
    final notifier = ref.read(importNotifierProvider.notifier);
    final deselected = state.deselectedUrls.toSet();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    // Sync controller text if state changes externally (e.g. after rescan)
    if (_nameController.text != state.resourceName) {
      _nameController.text = state.resourceName;
      _nameController.selection = TextSelection.collapsed(
        offset: _nameController.text.length,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resource name field
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Resource name',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: notifier.setResourceName,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 12),

        // Description field
        TextField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
          onChanged: notifier.setDescription,
          textInputAction: TextInputAction.done,
        ),

        const SizedBox(height: 12),

        // Depth stepper + Re-scan
        Row(
          children: [
            Text('Scan depth:', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 12),
            _DepthStepper(
              value: state.maxDepth,
              onDecrement: () => notifier.setMaxDepth(state.maxDepth - 1),
              onIncrement: () => notifier.setMaxDepth(state.maxDepth + 1),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: state.status == ImportStatus.loading
                  ? null
                  : () => notifier.rescan(context),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Re-scan'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Reorderable chapter list
        Text(
          'Chapters',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: secondaryColor),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ReorderableListView.builder(
            primary: false,
            itemCount: state.allPages.length,
            onReorder: notifier.reorderPage,
            itemBuilder: (context, index) {
              final page = state.allPages[index];
              final isSelected = !deselected.contains(page.url);
              return ListTile(
                key: ValueKey(page.url),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle, size: 20),
                ),
                title: Text(
                  page.title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isSelected ? null : secondaryColor,
                      ),
                ),
                trailing: Checkbox(
                  activeColor: AppColors.accent,
                  value: state.allPages.length == 1 ? true : isSelected,
                  onChanged: state.allPages.length == 1
                      ? null
                      : (_) => notifier.togglePage(page),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DepthStepper extends StatelessWidget {
  const _DepthStepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 16),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
          onPressed: value > 1 ? onDecrement : null,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 16),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
          onPressed: value < 4 ? onIncrement : null,
        ),
      ],
    );
  }
}
