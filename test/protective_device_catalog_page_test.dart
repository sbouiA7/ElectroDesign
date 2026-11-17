import 'package:electro_design/domain/calculations/protective_device_catalog.dart';
import 'package:electro_design/domain/calculations/protective_device_catalog_importer.dart';
import 'package:electro_design/features/catalog/protective_device_catalog_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

ImportedProtectiveDeviceRecord _record({
  required String manufacturer,
  required String productReference,
  required String productFamily,
  required double ratedCurrentA,
  required int poleCount,
  required List<ImportedBreakingCapacityRating> breakingRatings,
}) {
  return ImportedProtectiveDeviceRecord(
    manufacturer: manufacturer,
    productReference: productReference,
    productFamily: productFamily,
    category: ProtectiveDeviceCategory.miniatureCircuitBreaker,
    ratedCurrentA: ratedCurrentA,
    operationalVoltageV: null,
    poleCount: poleCount,
    document: ManufacturerDocumentReference(
      title: '$manufacturer fiche technique',
      sourceUrl: 'https://example.com/$productReference.pdf',
      documentRevision: 'test-revision',
      language: 'fr',
      retrievedOn: '2026-11-17',
      pageReferences: const ['Page 1'],
    ),
    standardReferences: const [],
    breakingRatings: breakingRatings,
    sourceStatus: 'test fixture',
  );
}

List<ImportedProtectiveDeviceRecord> _testRecords() => [
  _record(
    manufacturer: 'SOMEF',
    productReference: '801106CX20',
    productFamily: 'Disjoncteur modulaire',
    ratedCurrentA: 20,
    poleCount: 1,
    breakingRatings: const [
      ImportedBreakingCapacityRating(
        rating: 'Icn',
        currentA: 6000,
        standard: null,
        voltageV: null,
      ),
    ],
  ),
  _record(
    manufacturer: 'Legrand',
    productReference: 'FN881C16',
    productFamily: 'BTDIN 60',
    ratedCurrentA: 16,
    poleCount: 2,
    breakingRatings: const [
      ImportedBreakingCapacityRating(
        rating: 'Icn',
        currentA: 6000,
        standard: 'EN/IEC 60898-1',
        voltageV: 230,
      ),
    ],
  ),
];

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
    await tester.pumpWidget(
      MaterialApp(
        home: ProtectiveDeviceCatalogPage(
          recordsFuture: Future.value(_testRecords()),
        ),
      ),
    );
    await tester.pump();

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'SOMEF');
    await tester.pump();

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
