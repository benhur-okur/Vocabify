extension StringExt on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int max, {String ellipsis = '…'}) {
    if (length <= max) return this;
    return '${substring(0, max)}$ellipsis';
  }

  bool get isBlank => trim().isEmpty;
}

extension NullableStringExt on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}