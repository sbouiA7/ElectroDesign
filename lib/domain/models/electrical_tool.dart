class ElectricalTool {
  const ElectricalTool({
    required this.name,
    required this.category,
    required this.description,
    this.calibres = const [],
    this.measurements = const [],
    this.safetyCategory,
    this.selectionNote = 'Vérifier la fiche technique du modèle avant utilisation.',
  });

  final String name;
  final String category;
  final String description;
  final List<String> calibres;
  final List<String> measurements;
  final String? safetyCategory;
  final String selectionNote;
}
