import 'dart:ui';

class Part {
  const Part(this.name, this.family, this.symbol, this.details);

  final String name;
  final String family;
  final String symbol;
  final String details;
}

class PlacedPart {
  PlacedPart(this.part, this.position, {String? id})
      : id = id ?? 'placed-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  static int _nextId = 0;

  /// Stable identity retained when the project is saved and reopened.
  final String id;
  final Part part;
  final Offset position;
}
