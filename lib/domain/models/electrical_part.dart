import 'dart:ui';

class Part {
  const Part(this.name, this.family, this.symbol, this.details);

  final String name;
  final String family;
  final String symbol;
  final String details;
}

class PlacedPart {
  PlacedPart(this.part, this.position);

  final Part part;
  final Offset position;
}
