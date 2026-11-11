import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/data/catalog/tool_library.dart';

void main() {
  test('tool catalogue contains electrical, measurement and workshop tools', () {
    expect(toolLibrary, isNotEmpty);
    expect(toolLibrary.any((tool) => tool.name == 'Multimètre numérique'), isTrue);
    expect(toolLibrary.any((tool) => tool.name == 'Mégohmmètre'), isTrue);
    expect(toolLibrary.any((tool) => tool.name == 'Station de soudage électronique'), isTrue);
    expect(toolLibrary.any((tool) => tool.name == 'Poste de soudage par points'), isTrue);
  });

  test('each tool has a category, description and model-specific caution', () {
    for (final tool in toolLibrary) {
      expect(tool.name.trim(), isNotEmpty);
      expect(tool.category.trim(), isNotEmpty);
      expect(tool.description.trim(), isNotEmpty);
      expect(tool.selectionNote.trim(), isNotEmpty);
    }
  });
}
