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
      hasNote: note != null && note.isNotEmpty,
    );
  }

  /// Fetches all highlights for the chapter from the database and re-renders
  /// them in the WebView. Called after onLoadStop + script injection.
  Future<void> restoreForChapter(int chapterId) async {
    final highlights = await highlightsDao.getByChapter(chapterId);
    if (highlights.isEmpty) return;
    await jsBridge.restoreHighlights(highlights);
  }

  /// Saves a new or updated note for [id] and immediately refreshes the mark's
  /// dashed-underline style to reflect the new note presence.
  Future<void> updateNote(int id, String? note) async {
    await highlightsDao.updateNote(id, note);
    await jsBridge.updateHighlightNote(id, hasNote: note != null && note.isNotEmpty);
  }

  /// Deletes the highlight from the database and removes its mark from the DOM.
  Future<void> removeHighlight(int id) async {
    await highlightsDao.deleteHighlight(id);
    await jsBridge.removeHighlight(id);
  }
}
