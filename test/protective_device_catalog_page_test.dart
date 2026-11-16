import 'package:electro_design/features/catalog/protective_device_catalog_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows all bundled manufacturer records', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProtectiveDeviceCatalogPage()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Catalogue des protections'), findsOneWidget);
    expect(find.text('4 fiche(s)'), findsOneWidget);
    expect(find.text('2CDS272061R0024'), findsOneWidget);
    expect(find.text('FN881C16'), findsOneWidget);
    expect(find.text('MBN350A'), findsOneWidget);
    expect(find.text('801106CX20'), findsOneWidget);
  });

  testWidgets('filters records and opens a detailed product sheet',
      (tester) async {
    // Match the bundled-asset loading sequence already covered by the
    // first widget test. Avoid runAsync: rootBundle loading is driven by the
    // widget-test binding and must not be awaited outside its fake clock.
    await tester.pumpWidget(
      const MaterialApp(home: ProtectiveDeviceCatalogPage()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'SOMEF');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('1 fiche(s)'), findsOneWidget);
    expect(find.text('801106CX20'), findsOneWidget);
    expect(find.text('FN881C16'), findsNothing);

    await tester.tap(find.text('801106CX20'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pouvoirs de coupure déclarés'), findsOneWidget);
    expect(find.textContaining('Norme non précisée'), findsOneWidget);
    expect(find.textContaining('Tension non précisée'), findsOneWidget);
  });
}
