import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/cable_sizing.dart';
import 'package:electro_design/domain/calculations/electrical_load.dart';
import 'package:electro_design/domain/calculations/voltage_drop_calculation.dart';

void main() {
  group('CableSizingRequest', () {
    test('selects the smallest candidate meeting ampacity and voltage drop', () {
      final request = const CableSizingRequest(
        designCurrentA: 16,
        lengthM: 25,
        voltageV: 230,
        supplyType: SupplyType.singlePhaseAc,
        conductorMaterial: ConductorMaterial.copper,
        maximumDropPercent: 3,
        candidates: [
          CableAmpacityEntry(crossSectionMm2: 1.5, referenceAmpacityA: 20),
          CableAmpacityEntry(crossSectionMm2: 2.5, referenceAmpacityA: 25),
          CableAmpacityEntry(crossSectionMm2: 4, referenceAmpacityA: 32),
        ],
        ambientTemperatureFactor: 0.9,
        groupingFactor: 0.9,
      );

      final result = request.select();
      expect(result, isNotNull);
      expect(result!.crossSectionMm2, 2.5);
      expect(result.correctedAmpacityA, closeTo(20.25, 0.001));
      expect(result.voltageDropPercent, lessThanOrEqualTo(3));
    });

    test('returns null when no candidate meets corrected ampacity', () {
      final request = const CableSizingRequest(
        designCurrentA: 32,
        lengthM: 20,
        voltageV: 230,
        supplyType: SupplyType.singlePhaseAc,
        conductorMaterial: ConductorMaterial.copper,
        maximumDropPercent: 5,
        candidates: [
          CableAmpacityEntry(crossSectionMm2: 2.5, referenceAmpacityA: 25),
        ],
        ambientTemperatureFactor: 0.8,
      );

      expect(request.select(), isNull);
    });

    test('returns null when voltage-drop limit cannot be met', () {
      final request = const CableSizingRequest(
        designCurrentA: 20,
        lengthM: 150,
        voltageV: 230,
        supplyType: SupplyType.singlePhaseAc,
        conductorMaterial: ConductorMaterial.copper,
        maximumDropPercent: 1,
        candidates: [
          CableAmpacityEntry(crossSectionMm2: 2.5, referenceAmpacityA: 30),
        ],
      );

      expect(request.select(), isNull);
    });

    test('rejects invalid correction factors', () {
      final request = const CableSizingRequest(
        designCurrentA: 10,
        lengthM: 10,
        voltageV: 230,
        supplyType: SupplyType.singlePhaseAc,
        conductorMaterial: ConductorMaterial.copper,
        maximumDropPercent: 3,
        ambientTemperatureFactor: 0,
        candidates: [
          CableAmpacityEntry(crossSectionMm2: 2.5, referenceAmpacityA: 25),
        ],
      );

      expect(request.select, throwsArgumentError);
    });
  });
}
