import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/protective_device_calculation_profile.dart';
import 'package:electro_design/domain/calculations/protective_device_catalog.dart';

void main() {
  ManufacturerDocumentReference source() => const ManufacturerDocumentReference(
        title: 'Manufacturer datasheet',
        sourceUrl: 'https://example.com/device.pdf',
        documentRevision: 'Rev A',
        language: 'en',
        retrievedOn: '2026-11-11',
        pageReferences: ['Page 1'],
      );

  ProtectiveDeviceCatalogEntry device({
    String ratingType = 'Icn',
    double? breakingVoltageV = 230,
    double? ratedCurrentA = 16,
  }) =>
      ProtectiveDeviceCatalogEntry(
        manufacturer: 'Example',
        productReference: 'MCB-16',
        productFamily: 'MCB',
        category: ProtectiveDeviceCategory.miniatureCircuitBreaker,
        document: source(),
        standardReferences: const ['IEC 60898-1'],
        ratedCurrentA: ratedCurrentA,
        ratedOperationalVoltageV: 230,
        breakingCapacityA: 6000,
        breakingCapacityRatingType: ratingType,
        breakingCapacityStandard: 'IEC 60898-1',
        breakingCapacityVoltageV: breakingVoltageV,
      );

  test('transfers only the qualified breaking capacity to coordination', () {
    final profile = ProtectiveDeviceCalculationProfile(device());
    final request = profile.buildCoordinationRequest(
      networkVoltageV: 230,
      deviceRatedCurrentA: 16,
      designCurrentA: 12,
      correctedCableAmpacityA: 20,
      deviceConventionalOperatingCurrentA: 23.2,
      prospectiveShortCircuitCurrentA: 4500,
      deviceLetThroughEnergyA2s: 20000,
      cableKFactor: 115,
      cableCrossSectionMm2: 2.5,
    );

    final result = request.evaluate();
    expect(result.breakingCapacitySufficient, isTrue);
    expect(request.deviceBreakingCapacityA, 6000);
  });

  test('refuses unqualified ratings and mismatched network voltage', () {
    final unqualified = ProtectiveDeviceCalculationProfile(
      device(breakingVoltageV: null),
    );
    expect(
      () => unqualified.buildCoordinationRequest(
        networkVoltageV: 230,
        deviceRatedCurrentA: 16,
        designCurrentA: 12,
        correctedCableAmpacityA: 20,
        deviceConventionalOperatingCurrentA: 23.2,
        prospectiveShortCircuitCurrentA: 4500,
        deviceLetThroughEnergyA2s: 20000,
        cableKFactor: 115,
        cableCrossSectionMm2: 2.5,
      ),
      throwsStateError,
    );

    final profile = ProtectiveDeviceCalculationProfile(device());
    expect(
      () => profile.buildCoordinationRequest(
        networkVoltageV: 400,
        deviceRatedCurrentA: 16,
        designCurrentA: 12,
        correctedCableAmpacityA: 20,
        deviceConventionalOperatingCurrentA: 23.2,
        prospectiveShortCircuitCurrentA: 4500,
        deviceLetThroughEnergyA2s: 20000,
        cableKFactor: 115,
        cableCrossSectionMm2: 2.5,
      ),
      throwsStateError,
    );
  });

  test('refuses a device current that differs from the catalogued rating', () {
    final profile = ProtectiveDeviceCalculationProfile(device());
    expect(
      () => profile.buildCoordinationRequest(
        networkVoltageV: 230,
        deviceRatedCurrentA: 20,
        designCurrentA: 12,
        correctedCableAmpacityA: 20,
        deviceConventionalOperatingCurrentA: 23.2,
        prospectiveShortCircuitCurrentA: 4500,
        deviceLetThroughEnergyA2s: 20000,
        cableKFactor: 115,
        cableCrossSectionMm2: 2.5,
      ),
      throwsStateError,
    );
  });
}
