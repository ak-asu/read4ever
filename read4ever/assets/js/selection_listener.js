// Exposes window.__read4ever_getSelection()
// Called by Flutter when a ContextMenu action fires.
// Returns { text, xpathStart, xpathEnd, startOffset, endOffset } or null.

window.__read4ever_getSelection = function () {
  var sel = window.getSelection();
  if (!sel || sel.rangeCount === 0 || sel.isCollapsed) return null;

  var range = sel.getRangeAt(0);
  var text = sel.toString().trim();
  if (!text) return null;

  // Walks the node's ancestor chain bottom-up, building an absolute XPath.
  // Text nodes: returns parent XPath + /text()[n]
  // Element nodes: returns parent XPath + /tagName[n]
  function xpathOfNode(node) {
    if (!node) return '';

    if (node.nodeType === Node.TEXT_NODE) {
      var idx = 1;
      var s = node.previousSibling;
      while (s) {
        if (s.nodeType === Node.TEXT_NODE) idx++;
        s = s.previousSibling;
      }
      return xpathOfNode(node.parentNode) + '/text()[' + idx + ']';
    }

    // Element node
    if (node === document.documentElement) {
      return '/' + node.tagName.toLowerCase();
    }

    var tag = node.tagName.toLowerCase();
    var idx = 1;
    var s = node.previousSibling;
    while (s) {
      if (s.nodeType === Node.ELEMENT_NODE &&
          s.tagName.toLowerCase() === tag) {
        idx++;
      }
      s = s.previousSibling;
    }
    return xpathOfNode(node.parentNode) + '/' + tag + '[' + idx + ']';
  }

  try {
    return {
      text: text,
      xpathStart: xpathOfNode(range.startContainer),
      xpathEnd: xpathOfNode(range.endContainer),
      startOffset: range.startOffset,
      endOffset: range.endOffset
    };
  } catch (e) {
    console.warn('[Read4ever] getSelection error:', e);
    return null;
  }
};
