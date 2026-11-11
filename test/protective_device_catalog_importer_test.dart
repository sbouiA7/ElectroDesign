import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/protective_device_catalog_importer.dart';

const importer = ProtectiveDeviceCatalogImporter();

Map<String, dynamic> source({
  required String manufacturer,
  required String productReference,
  required Object breakingCapacity,
  required Object operationalVoltage,
  String? standard,
}) => {
  'manufacturer': manufacturer,
  'product_reference': productReference,
  'product_family': 'Test family',
  'category': 'miniatureCircuitBreaker',
  'rated_current_A': 16,
  'pole_count': 2,
  'rated_operational_voltage': operationalVoltage,
  'standard_references': ['IEC 60898-1'],
  'breaking_capacity': breakingCapacity,
  'source_document': {
    'title': 'Manufacturer datasheet',
    'document_identifier': 'Rev A',
    'source_url': 'https://example.com/datasheet.pdf',
    'language': 'en',
    'retrieved_on': '2026-11-11',
    'evidence': ['Page 1: product table'],
  },
};

void main() {
  test('imports a single qualified ABB-like rating', () {
    final record = importer.parse(jsonEncode(source(
      manufacturer: 'ABB',
      productReference: 'ABB-01',
      operationalVoltage: {'value': 400, 'unit': 'V AC'},
      breakingCapacity: {
        'rating': 'Icn',
        'value': 10000,
        'unit': 'A',
        'standard': 'IEC/EN 60898-2',
        'voltage_condition': '400 V AC',
      },
    )));
    final entry = record.toCatalogEntry(
      breakingStandard: 'IEC/EN 60898-2',
      breakingVoltageV: 400,
    );
    expect(entry, isNotNull);
    expect(entry!.breakingCapacityA, 10000);
    expect(entry.breakingCapacityVoltageV, 400);
    expect(entry.hasBreakingCapacityData, isTrue);
  });

  test('keeps multiple Legrand/Hager ratings distinct by standard and voltage', () {
    final record = importer.parse(jsonEncode(source(
      manufacturer: 'Hager',
      productReference: 'MBN350A',
      operationalVoltage: {'value': 400, 'unit': 'V AC'},
      breakingCapacity: [
        {'rating': 'Icn', 'value': 6000, 'unit': 'A',
          'standard': 'IEC 60898-1', 'voltage_condition': '230 V AC'},
        {'rating': 'Icu', 'value': 10000, 'unit': 'A',
          'standard': 'IEC 60947-2', 'voltage_condition': '400 V AC'},
      ],
    )));
    final icu = record.toCatalogEntry(
      breakingStandard: 'IEC 60947-2',
      breakingVoltageV: 400,
    );
    final icn = record.toCatalogEntry(
      breakingStandard: 'IEC 60898-1',
      breakingVoltageV: 230,
    );
    expect(icu!.breakingCapacityA, 10000);
    expect(icn!.breakingCapacityA, 6000);
    expect(icu.ratedOperationalVoltageV, 400);
    expect(icu.breakingCapacityVoltageV, 400);
  });

  test('does not qualify SOMEF unqualified 6 kA claim', () {
    final record = importer.parse(jsonEncode(source(
      manufacturer: 'SOMEF',
      productReference: '801106CX20',
      operationalVoltage: '230 V AC',
      breakingCapacity: {
        'rating': 'Icn',
        'value': 6000,
        'unit': 'A',
        'standard': null,
        'voltage_condition': null,
      },
    )));
    expect(record.breakingRatings.single.isQualified, isFalse);
    expect(record.toCatalogEntry(
      breakingStandard: 'IEC 60898-1',
      breakingVoltageV: 230,
    ), isNull);
  });

  test('rejects malformed source evidence and unsupported category', () {
    final bad = source(
      manufacturer: 'ABB',
      productReference: 'X',
      operationalVoltage: {'value': 230},
      breakingCapacity: {'rating': 'Icn', 'value': 6000,
        'standard': 'IEC 60898-1', 'voltage_condition': '230 V'},
    );
    (bad['source_document'] as Map<String, dynamic>)['evidence'] = [];
    expect(() => importer.parse(jsonEncode(bad)), throwsFormatException);
    bad['category'] = 'unknownCategory';
    expect(() => importer.parse(jsonEncode(bad)), throwsFormatException);
  });
}
