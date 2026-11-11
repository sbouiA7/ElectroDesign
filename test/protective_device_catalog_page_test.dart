import 'package:electro_design/features/catalog/protective_device_catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows all bundled manufacturer records', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProtectiveDeviceCatalogPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catalogue des protections'), findsOneWidget);
    expect(find.text('4 fiche(s)'), findsOneWidget);
    expect(find.text('2CDS272061R0024'), findsOneWidget);
    expect(find.text('FN881C16'), findsOneWidget);
    expect(find.text('MBN350A'), findsOneWidget);
    expect(find.text('801106CX20'), findsOneWidget);
  });

  testWidgets('filters records and opens a detailed product sheet',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProtectiveDeviceCatalogPage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('SOMEF').first);
    await tester.pumpAndSettle();

    expect(find.text('1 fiche(s)'), findsOneWidget);
    expect(find.text('801106CX20'), findsOneWidget);
    expect(find.text('FN881C16'), findsNothing);

    await tester.tap(find.text('801106CX20'));
    await tester.pumpAndSettle();

    expect(find.text('Pouvoirs de coupure déclarés'), findsOneWidget);
    expect(find.textContaining('Norme non précisée'), findsOneWidget);
    expect(find.textContaining('Tension non précisée'), findsOneWidget);
  });
}
