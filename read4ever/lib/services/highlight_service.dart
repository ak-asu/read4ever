import 'package:drift/drift.dart' show Value;

import '../db/daos/highlights_dao.dart';
import '../db/database.dart';
import '../models/selection_data.dart';
import 'js_bridge.dart';

/// Domain logic for highlighting — owns DB writes and restore sequencing.
/// JsBridge handles only the WebView interop; this class decides when and
/// what to write/read.
class HighlightService {
  final HighlightsDao highlightsDao;
  final JsBridge jsBridge;

  HighlightService({required this.highlightsDao, required this.jsBridge});

  /// Saves the highlight to the database and immediately applies the visual
  /// mark to the current page via the JS bridge.
  Future<void> createHighlight(
    int chapterId,
    SelectionData sel, {
    String? note,
  }) async {
    final id = await highlightsDao.insertHighlight(HighlightsCompanion(
      chapterId: Value(chapterId),
      selectedText: Value(sel.text),
      xpathStart: Value(sel.xpathStart),
      xpathEnd: Value(sel.xpathEnd),
      startOffset: Value(sel.startOffset),
      endOffset: Value(sel.endOffset),
      note: Value(note),
      createdAt: Value(DateTime.now()),
    ));
    await jsBridge.applyHighlight(
      id,
      sel.xpathStart,
      sel.xpathEnd,
      sel.startOffset,
      sel.endOffset,
    );
  }

  /// Fetches all highlights for the chapter from the database and re-renders
  /// them in the WebView. Called after onLoadStop + script injection.
  Future<void> restoreForChapter(int chapterId) async {
    final highlights = await highlightsDao.getByChapter(chapterId);
    if (highlights.isEmpty) return;
    await jsBridge.restoreHighlights(highlights);
  }
}
