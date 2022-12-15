extension IterableExtensions<E> on Iterable<E> {
  /// Like regular map but if returned value is null it is removed
  Iterable<T> mapSkipNull<T>(T? Function(E e) toElement) sync* {
    for (final e in this) {
      final el = toElement(e);
      if (el != null) yield el;
    }
  }
}
