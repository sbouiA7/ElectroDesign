/// Physical or logical terminal metadata for a component.
/// Coordinates are normalized to the component's visual footprint (0..1).
/// Only verified or explicitly user-configured terminals should be stored.
class ElectricalTerminal {
  const ElectricalTerminal({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
  });

  final String id;
  final String label;
  final double x;
  final double y;

  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
        'x': x,
        'y': y,
      };

  factory ElectricalTerminal.fromJson(Map<String, dynamic> json) {
    return ElectricalTerminal(
      id: _requiredString(json, 'id'),
      label: _requiredString(json, 'label'),
      x: _requiredNumber(json, 'x'),
      y: _requiredNumber(json, 'y'),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or invalid terminal field: $key');
  }
  return value;
}

double _requiredNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.toDouble().isFinite) {
    throw FormatException('Missing or invalid terminal field: $key');
  }
  return value.toDouble();
}
