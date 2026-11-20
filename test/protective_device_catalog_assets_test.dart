import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/protective_device_catalog_importer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const importer = ProtectiveDeviceCatalogImporter();

  test('loads and parses the four real manufacturer asset records', () async {
    final records = await importer.loadBundledRecords();

    expect(records, hasLength(4));
    expect(
      records.map((record) => record.manufacturer).toSet(),
      containsAll(['ABB', 'Legrand', 'Hager', 'SOMEF']),
    );

    final abb = records.singleWhere((record) => record.manufacturer == 'ABB');
    expect(abb.productReference, '2CDS272061R0024');
    expect(abb.breakingRatings.single.isQualified, isTrue);
    expect(
      abb.toCatalogEntry(
        breakingStandard: 'IEC/EN 60898-2',
        breakingVoltageV: 400,
      )?.breakingCapacityA,
      10000,
    );

    final legrand =
        records.singleWhere((record) => record.manufacturer == 'Legrand');
    expect(legrand.productReference, 'FN881C16');
    expect(legrand.breakingRatings, hasLength(2));
    expect(
      legrand.toCatalogEntry(
        breakingStandard: 'EN/IEC 60898-1',
        breakingVoltageV: 230,
      )?.breakingCapacityA,
      6000,
    );
    expect(
      legrand.toCatalogEntry(
        breakingStandard: 'EN/IEC 60947-2',
        breakingVoltageV: 230,
      )?.breakingCapacityA,
      10000,
    );

    final hager =
        records.singleWhere((record) => record.manufacturer == 'Hager');
    expect(hager.productReference, 'MBN350A');
    expect(hager.breakingRatings, hasLength(3));
    expect(
      hager.toCatalogEntry(
        breakingStandard: 'IEC 60947-2',
        breakingVoltageV: 400,
      )?.breakingCapacityA,
      10000,
    );
    expect(
      hager.toCatalogEntry(
        breakingStandard: 'IEC 60898-1',
        breakingVoltageV: 230,
      )?.breakingCapacityA,
      6000,
    );

    final somef =
        records.singleWhere((record) => record.manufacturer == 'SOMEF');
    expect(somef.productReference, '801106CX20');
    expect(somef.breakingRatings, hasLength(1));
    expect(somef.breakingRatings.single.isQualified, isFalse);
    expect(
      somef.toCatalogEntry(
        breakingStandard: 'IEC 60898-1',
        breakingVoltageV: 230,
      ),
      isNull,
    );
  });

  test('does not qualify an unknown breaking-rating label', () {
    final record = importer.parse('''
{
  "manufacturer": "Test",
  "product_reference": "TEST-1",
  "product_family": "Test family",
  "category": "miniatureCircuitBreaker",
  "rated_current_A": 16,
  "rated_operational_voltage": {"value": 230, "unit": "V AC"},
  "breaking_capacity": {
    "rating": "Peak withstand",
    "value": 6000,
    "unit": "A",
    "standard": "IEC 60898-1",
    "voltage_condition": "230 V AC"
  },
  "standard_references": ["IEC 60898-1"],
  "source_document": {
    "title": "Test document",
    "document_identifier": "Rev 1",
    "source_url": "https://example.com/test.pdf",
    "language": "en",
    "retrieved_on": "2026-11-11",
    "evidence": ["Page 1"]
  }
}
''');

    expect(record.breakingRatings.single.isQualified, isFalse);
    expect(
      record.toCatalogEntry(
        breakingStandard: 'IEC 60898-1',
        breakingVoltageV: 230,
      ),
      isNull,
    );
  });
}
