// Plain immutable class (no freezed needed — no pattern matching, simple value object).
class SelectionData {
  final String text;
  final String xpathStart;
  final String xpathEnd;
  final int startOffset;
  final int endOffset;

  const SelectionData({
    required this.text,
    required this.xpathStart,
    required this.xpathEnd,
    required this.startOffset,
    required this.endOffset,
  });

  factory SelectionData.fromJson(Map<String, dynamic> json) {
    return SelectionData(
      text: json['text'] as String,
      xpathStart: json['xpathStart'] as String,
      xpathEnd: json['xpathEnd'] as String,
      startOffset: (json['startOffset'] as num).toInt(),
      endOffset: (json['endOffset'] as num).toInt(),
    );
  }
}
