// Exposes:
//   window.__learnstack_restoreHighlights(highlightsJson) — bulk restore on page load
//   window.__learnstack_applyHighlight(id, xpathStart, xpathEnd, startOffset, endOffset) — single new highlight
//   window.__learnstack_scrollToHighlight(id) — scroll a restored mark into view

(function () {
  // Resolves an XPath expression to the first matching DOM node.
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

  // Wraps the given Range in a <mark> element.
  // Falls back to extractContents + appendChild for cross-element selections
  // (surroundContents throws InvalidStateError if the range spans element boundaries).
  function wrapRangeInMark(range, id) {
    var mark = document.createElement('mark');
    mark.className = 'ls-highlight';
    mark.setAttribute('data-id', String(id));
    mark.style.cssText = 'background:#CCFBF1;border-radius:2px;';
    try {
      range.surroundContents(mark);
    } catch (e) {
      var fragment = range.extractContents();
      mark.appendChild(fragment);
      range.insertNode(mark);
    }
  }

  window.__learnstack_restoreHighlights = function (highlightsJson) {
    var highlights;
    try {
      highlights = JSON.parse(highlightsJson);
    } catch (e) {
      console.warn('[LearnStack] Failed to parse highlights JSON:', e);
      return;
    }
    highlights.forEach(function (h) {
      try {
        var startNode = resolveXPath(h.xpathStart);
        var endNode = resolveXPath(h.xpathEnd);
        if (!startNode || !endNode) {
          console.warn('[LearnStack] XPath not resolved for highlight', h.id);
          return;
        }
        var range = document.createRange();
        range.setStart(startNode, h.startOffset);
        range.setEnd(endNode, h.endOffset);
        wrapRangeInMark(range, h.id);
      } catch (e) {
        console.warn('[LearnStack] Failed to restore highlight', h.id, ':', e);
      }
    });
  };

  window.__learnstack_applyHighlight = function (
    id,
    xpathStart,
    xpathEnd,
    startOffset,
    endOffset
  ) {
    try {
      var startNode = resolveXPath(xpathStart);
      var endNode = resolveXPath(xpathEnd);
      if (!startNode || !endNode) {
        console.warn('[LearnStack] XPath not resolved for new highlight', id);
        return;
      }
      var range = document.createRange();
      range.setStart(startNode, startOffset);
      range.setEnd(endNode, endOffset);
      wrapRangeInMark(range, id);
    } catch (e) {
      console.warn('[LearnStack] Failed to apply highlight', id, ':', e);
    }
  };

  window.__learnstack_scrollToHighlight = function (id) {
    var mark = document.querySelector('.ls-highlight[data-id="' + id + '"]');
    if (mark) {
      mark.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  };
})();
