import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/protective_device_catalog.dart';
import 'package:electro_design/domain/calculations/protective_device_selectivity.dart';

void main() {
  ManufacturerDocumentReference document({
    String url = 'https://manufacturer.example/datasheet.pdf',
    String revision = 'Rev A',
    String retrievedOn = '2026-11-11',
  }) {
    return ManufacturerDocumentReference(
      title: 'Synthetic test datasheet',
      sourceUrl: url,
      documentRevision: revision,
      language: 'en',
      retrievedOn: retrievedOn,
      pageReferences: const ['p. 12, table 4'],
    );
  }

  ProtectiveDeviceCatalogEntry entry({
    String manufacturer = 'Example Electrical',
    String productReference = 'TEST-MCB-01',
    ManufacturerDocumentReference? source,
    double? breakingCapacityA = 10000,
    String? breakingCapacityStandard = 'IEC 60898-1',
    double? ratedVoltageV = 230,
    double? breakingVoltageV = 230,
    ResidualCurrentDeviceType? rcdType,
    double? residualCurrentA,
    ProtectiveDeviceCurve? curve,
  }) {
    return ProtectiveDeviceCatalogEntry(
      manufacturer: manufacturer,
      productReference: productReference,
      productFamily: 'Synthetic test family',
      category: rcdType == null
          ? ProtectiveDeviceCategory.miniatureCircuitBreaker
          : ProtectiveDeviceCategory.residualCurrentCircuitBreaker,
      document: source ?? document(),
      standardReferences: const ['IEC test reference'],
      ratedCurrentA: 16,
      ratedOperationalVoltageV: ratedVoltageV,
      poleCount: 2,
      breakingCapacityA: breakingCapacityA,
      breakingCapacityRatingType: 'Icn',
      breakingCapacityStandard: breakingCapacityStandard,
      breakingCapacityVoltageV: breakingVoltageV,
      residualCurrentType: rcdType,
      residualOperatingCurrentA: residualCurrentA,
      curve: curve,
    );
  }

  test('accepts a record with traceable source and valid identity', () {
    expect(entry().hasValidIdentityAndSource, isTrue);
    expect(entry().hasBreakingCapacityData, isTrue);
  });

  test('rejects missing source URL or document revision', () {
    expect(
      entry(source: document(url: 'not-a-url')).hasValidIdentityAndSource,
      isFalse,
    );
    expect(
      entry(source: document(revision: '  ')).hasValidIdentityAndSource,
      isFalse,
    );
  });

  test('rejects malformed document retrieval date', () {
    expect(
      entry(source: document(retrievedOn: '11/11/2026'))
          .hasValidIdentityAndSource,
      isFalse,
    );
  });

  test('breaking capacity requires rating standard and explicit test voltage', () {
    expect(
      entry(breakingCapacityStandard: null).hasBreakingCapacityData,
      isFalse,
    );
    expect(
      entry(breakingVoltageV: null).hasBreakingCapacityData,
      isFalse,
    );
  });

  test('residual current data requires device type and sensitivity', () {
    final valid = entry(
      rcdType: ResidualCurrentDeviceType.a,
      residualCurrentA: 0.03,
    );
    final missingSensitivity = entry(
      rcdType: ResidualCurrentDeviceType.a,
    );

    expect(valid.hasResidualCurrentData, isTrue);
    expect(missingSensitivity.hasResidualCurrentData, isFalse);
  });

  test('curve data requires a traceable record and at least two points', () {
    final curve = const ProtectiveDeviceCurve(
      deviceReference: 'Synthetic test curve',
      points: [
        ProtectiveCurvePoint(
          currentA: 100,
          minimumTimeS: 0.1,
          maximumTimeS: 0.2,
        ),
        ProtectiveCurvePoint(
          currentA: 1000,
          minimumTimeS: 0.01,
          maximumTimeS: 0.02,
        ),
      ],
    );

    expect(entry(curve: curve).hasCurveData, isTrue);
    expect(
      entry(
        curve: const ProtectiveDeviceCurve(
          deviceReference: 'Only one point',
          points: [
            ProtectiveCurvePoint(
              currentA: 100,
              minimumTimeS: 0.1,
              maximumTimeS: 0.2,
            ),
          ],
        ),
      ).hasCurveData,
      isFalse,
    );
  });

  test('catalogue metadata validates entries and filters manufacturer', () {
    final catalogue = ProtectiveDeviceCatalogueMetadata(
      catalogueVersion: '0.1.0',
      updatedOn: '2026-11-11',
      entries: [
        entry(),
        entry(
          manufacturer: 'Other Manufacturer',
          productReference: 'TEST-MCB-02',
        ),
      ],
    );

    expect(catalogue.hasValidMetadata, isTrue);
    expect(catalogue.entriesForManufacturer('example electrical'), hasLength(1));
  });

  test('catalogue metadata rejects invalid entries and date', () {
    final invalidEntryCatalogue = ProtectiveDeviceCatalogueMetadata(
      catalogueVersion: '0.1.0',
      updatedOn: '2026-11-11',
      entries: [entry(source: document(url: 'invalid'))],
    );
    final invalidDateCatalogue = ProtectiveDeviceCatalogueMetadata(
      catalogueVersion: '0.1.0',
      updatedOn: 'yesterday',
      entries: [entry()],
    );

    expect(invalidEntryCatalogue.hasValidMetadata, isFalse);
    expect(invalidDateCatalogue.hasValidMetadata, isFalse);
  });
}
