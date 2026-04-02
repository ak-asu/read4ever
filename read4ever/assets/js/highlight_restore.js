// Exposes:
//   window.__read4ever_restoreHighlights(highlightsJson) — bulk restore on page load
//   window.__read4ever_applyHighlight(id, xpathStart, xpathEnd, startOffset, endOffset, hasNote)
//   window.__read4ever_scrollToHighlight(id) — scroll a restored mark into view
//   window.__read4ever_removeHighlight(id) — remove a mark from the DOM

(function () {
  function resolveXPath(xpath) {
    var result = document.evaluate(
      xpath,
      document,
      null,
      XPathResult.FIRST_ORDERED_NODE_TYPE,
      null
    );
    return result.singleNodeValue;
  }

  // Marks with a note get a dashed underline to distinguish them visually.
  function markStyle(hasNote) {
    var base =
      'background:rgba(13,148,136,0.35);border-radius:2px;cursor:pointer;';
    return hasNote
      ? base + 'border-bottom:2px dashed rgba(13,148,136,0.85);'
      : base;
  }

  function wrapRangeInMark(range, id, hasNote) {
    var mark = document.createElement('mark');
    mark.className = 'ls-highlight';
    mark.setAttribute('data-id', String(id));
    mark.style.cssText = markStyle(hasNote);

    // Notify Flutter when the mark is tapped.
    mark.addEventListener('click', function (e) {
      e.stopPropagation();
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onHighlightTapped', id);
      }
    });

    try {
      range.surroundContents(mark);
    } catch (e) {
      // surroundContents throws when the range spans element boundaries.
      // extractContents + appendChild handles cross-element selections.
      var fragment = range.extractContents();
      mark.appendChild(fragment);
      range.insertNode(mark);
    }
  }

  window.__read4ever_restoreHighlights = function (highlightsJson) {
    var highlights;
    try {
      highlights = JSON.parse(highlightsJson);
    } catch (e) {
      console.warn('[Read4ever] Failed to parse highlights JSON:', e);
      return;
    }

    // --- Phase 1: resolve ALL XPaths and create Ranges BEFORE any DOM changes.
    //
    // If we inserted marks sequentially, each <mark> insertion changes sibling
    // indices and splits text nodes — invalidating the XPaths of every
    // subsequent highlight in the same region.  Pre-resolving everything first
    // captures stable node references before any mutation.
    var resolved = [];
    highlights.forEach(function (h) {
      try {
        var startNode = resolveXPath(h.xpathStart);
        var endNode = resolveXPath(h.xpathEnd);
        if (!startNode || !endNode) {
          console.warn('[Read4ever] XPath not resolved for highlight', h.id);
          return;
        }
        var range = document.createRange();
        range.setStart(startNode, h.startOffset);
        range.setEnd(endNode, h.endOffset);
        resolved.push({ range: range, id: h.id, hasNote: !!h.hasNote });
      } catch (e) {
        console.warn(
          '[Read4ever] Failed to create range for highlight',
          h.id,
          ':',
          e
        );
      }
    });

    // --- Phase 2: sort in REVERSE document order (last occurrence first).
    //
    // Wrapping a later node doesn't change the structure of earlier nodes.
    // Working back-to-front keeps every pending Range's boundary points valid.
    resolved.sort(function (a, b) {
      try {
        return b.range.compareBoundaryPoints(Range.START_TO_START, a.range);
      } catch (_) {
        return 0;
      }
    });

    // --- Phase 3: apply marks.
    resolved.forEach(function (item) {
      try {
        wrapRangeInMark(item.range, item.id, item.hasNote);
      } catch (e) {
        console.warn('[Read4ever] Failed to restore highlight', item.id, ':', e);
      }
    });
  };

  window.__read4ever_applyHighlight = function (
    id,
    xpathStart,
    xpathEnd,
    startOffset,
    endOffset,
    hasNote
  ) {
    try {
      var startNode = resolveXPath(xpathStart);
      var endNode = resolveXPath(xpathEnd);
      if (!startNode || !endNode) {
        console.warn('[Read4ever] XPath not resolved for new highlight', id);
        return;
      }
      var range = document.createRange();
      range.setStart(startNode, startOffset);
      range.setEnd(endNode, endOffset);
      wrapRangeInMark(range, id, !!hasNote);
    } catch (e) {
      console.warn('[Read4ever] Failed to apply highlight', id, ':', e);
    }
  };

  window.__read4ever_scrollToHighlight = function (id) {
    var mark = document.querySelector('.ls-highlight[data-id="' + id + '"]');
    if (mark) {
      mark.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  };

  // Updates only the visual style of an existing mark — used after a note is
  // added or removed so the dashed underline reflects the current state without
  // requiring a full page reload.
  window.__read4ever_updateHighlightNote = function (id, hasNote) {
    var mark = document.querySelector('.ls-highlight[data-id="' + id + '"]');
    if (mark) mark.style.cssText = markStyle(!!hasNote);
  };

  // Removes a mark from the DOM and merges the surrounding text nodes back.
  // Called immediately after the highlight is deleted from the database so the
  // page reflects the deletion without a full reload.
  window.__read4ever_removeHighlight = function (id) {
    var mark = document.querySelector('.ls-highlight[data-id="' + id + '"]');
    if (!mark) return;
    var parent = mark.parentNode;
    while (mark.firstChild) {
      parent.insertBefore(mark.firstChild, mark);
    }
    parent.removeChild(mark);
    parent.normalize();
  };
})();
