import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/data/catalog/component_library.dart';

void main() {
  final partsByName = {for (final part in library) part.name: part};

  test('basic components expose their generic starter terminals', () {
    expect(
      partsByName['Interrupteur']!.terminals.map((terminal) => terminal.id).toList(),
      ['L', '1'],
    );
    expect(
      partsByName['Prise 2P+T']!.terminals.map((terminal) => terminal.id).toList(),
      ['L', 'N', 'PE'],
    );
    expect(
      partsByName['Lampe']!.terminals.map((terminal) => terminal.id).toList(),
      ['L', 'N'],
    );
    expect(
      partsByName['Disjoncteur']!.terminals.map((terminal) => terminal.id).toList(),
      ['1', '2'],
    );
    expect(
      partsByName['Interrupteur différentiel']!.terminals
          .map((terminal) => terminal.id)
          .toList(),
      ['1', 'N', '2', 'N2'],
    );
    expect(
      partsByName['Contacteur']!.terminals.map((terminal) => terminal.id).toList(),
      ['A1', 'A2', '1L1', '2T1', '3L2', '4T2'],
    );
  });

  test('all starter terminal identifiers and coordinates are valid', () {
    for (final part in library) {
      final identifiers =
          part.terminals.map((terminal) => terminal.id).toList();

      expect(
        identifiers.toSet().length,
        identifiers.length,
        reason: 'Duplicate terminal identifier in ${part.name}',
      );

      for (final terminal in part.terminals) {
        expect(terminal.id.trim(), isNotEmpty, reason: part.name);
        expect(terminal.label.trim(), isNotEmpty, reason: part.name);
        expect(terminal.x.isFinite, isTrue, reason: part.name);
        expect(terminal.y.isFinite, isTrue, reason: part.name);
        expect(terminal.x, inInclusiveRange(0.0, 1.0), reason: part.name);
        expect(terminal.y, inInclusiveRange(0.0, 1.0), reason: part.name);
      }
    }
  });
}
