import 'dart:ui';

import 'electrical_terminal.dart';

class Part {
  const Part(
    this.name,
    this.family,
    this.symbol,
    this.details, {
    this.terminals = const [],
  });

  final String name;
  final String family;
  final String symbol;
  final String details;

  /// Only verified catalogue terminals or terminals configured by the user.
  final List<ElectricalTerminal> terminals;
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
