extension StringExtensions on String? {
  /// Handles null for [isEmpty]. Null will return true
  bool get isNullEmpty => this == null || this!.isEmpty;
  /// Handles null for [isNotEmpty]. Null will return false
  bool get isNotNullEmpty => this != null && this!.isNotEmpty;
}
