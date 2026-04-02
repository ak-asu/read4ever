import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../db/database.dart';
import '../models/selection_data.dart';

/// Low-level WebView interop — script injection and JS channel calls only.
/// No domain logic lives here; that belongs in HighlightService.
class JsBridge {
  final InAppWebViewController controller;

  JsBridge(this.controller);

  /// Injects selection_listener.js + highlight_restore.js into the current page.
  /// Called in onLoadStop so the scripts are present before any user interaction.
  Future<void> injectScripts() async {
    final selectionScript =
        await rootBundle.loadString('assets/js/selection_listener.js');
    final restoreScript =
        await rootBundle.loadString('assets/js/highlight_restore.js');
    await controller.evaluateJavascript(source: selectionScript);
    await controller.evaluateJavascript(source: restoreScript);
  }

  /// Calls window.__learnstack_getSelection() and parses the returned JSON.
  /// Returns null if there is no active selection or if the JS returns null.
  Future<SelectionData?> getSelection() async {
    final result = await controller.evaluateJavascript(
      source: 'JSON.stringify(window.__learnstack_getSelection())',
    );
    if (result == null || result == 'null') return null;
    try {
      final decoded = jsonDecode(result as String);
      if (decoded == null) return null;
      return SelectionData.fromJson(decoded as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Calls window.__learnstack_applyHighlight() to render a single new highlight
  /// immediately after it has been saved to the database.
  Future<void> applyHighlight(
    int id,
    String xpathStart,
    String xpathEnd,
    int startOffset,
    int endOffset,
  ) async {
    // jsonEncode produces properly escaped JS string literals (with surrounding quotes).
    final xsJs = jsonEncode(xpathStart);
    final xeJs = jsonEncode(xpathEnd);
    await controller.evaluateJavascript(
      source:
          'window.__learnstack_applyHighlight($id, $xsJs, $xeJs, $startOffset, $endOffset)',
    );
  }

  /// Calls window.__learnstack_restoreHighlights() to re-render all saved
  /// highlights after a page load.
  Future<void> restoreHighlights(List<Highlight> highlights) async {
    final list = highlights
        .map((h) => {
              'id': h.id,
              'xpathStart': h.xpathStart,
              'xpathEnd': h.xpathEnd,
              'startOffset': h.startOffset,
              'endOffset': h.endOffset,
            })
        .toList();
    // Double-encode: first to JSON array string, then to a JS string literal.
    final jsArg = jsonEncode(jsonEncode(list));
    await controller.evaluateJavascript(
      source: 'window.__learnstack_restoreHighlights($jsArg)',
    );
  }

  /// Calls window.__learnstack_scrollToHighlight() to scroll the mark into view.
  Future<void> scrollToHighlight(int id) async {
    await controller.evaluateJavascript(
      source: 'window.__learnstack_scrollToHighlight($id)',
    );
  }
}
