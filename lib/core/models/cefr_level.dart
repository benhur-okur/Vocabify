/// CEFR proficiency levels, ordered easiest → hardest.
enum CefrLevel {
  a1,
  a2,
  b1,
  b2,
  c1,
  c2;

  /// Parses a stored string like "a2" back to a level. Unknown input → [a2].
  /// Defined on the enum itself so callers don't need to import the extension.
  static CefrLevel fromName(String raw) {
    for (final l in CefrLevel.values) {
      if (l.name == raw) return l;
    }
    return CefrLevel.a2;
  }
}

/// Rich UI/domain API for CefrLevel. Callers that use `.label`, `.rank`,
/// `.next`, or `.previous` must import this file so the extension is
/// visible at the call site.
extension CefrLevelX on CefrLevel {
  String get label {
    switch (this) {
      case CefrLevel.a1:
        return 'A1';
      case CefrLevel.a2:
        return 'A2';
      case CefrLevel.b1:
        return 'B1';
      case CefrLevel.b2:
        return 'B2';
      case CefrLevel.c1:
        return 'C1';
      case CefrLevel.c2:
        return 'C2';
    }
  }

  /// 0 = A1 … 5 = C2. Used for distance comparisons.
  int get rank => CefrLevel.values.indexOf(this);

  CefrLevel get next =>
      rank >= CefrLevel.values.length - 1 ? this : CefrLevel.values[rank + 1];

  CefrLevel get previous =>
      rank <= 0 ? this : CefrLevel.values[rank - 1];

  /// Deprecated alias — kept only for backwards compatibility with earlier
  /// code that called [CefrLevelX.fromString]. New code should use
  /// [CefrLevel.fromName].
  static CefrLevel fromString(String s) => CefrLevel.fromName(s);
}