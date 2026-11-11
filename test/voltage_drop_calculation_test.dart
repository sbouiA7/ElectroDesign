import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/electrical_load.dart';
import 'package:electro_design/domain/calculations/voltage_drop_calculation.dart';

void main() {
  group('VoltageDropCalculation', () {
    test('calculates single-phase copper voltage drop', () {
      const calculation = VoltageDropCalculation(
        supplyType: SupplyType.singlePhaseAc,
        currentA: 10,
        lengthM: 20,
        voltageV: 230,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 2.5,
        powerFactor: 1,
      );

      expect(calculation.calculateDropV(), closeTo(2.75856, 0.001));
      expect(calculation.calculateDropPercent(), closeTo(1.1994, 0.001));
    });

    test('calculates three-phase voltage drop', () {
      const calculation = VoltageDropCalculation(
        supplyType: SupplyType.threePhaseAc,
        currentA: 10,
        lengthM: 20,
        voltageV: 400,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 2.5,
        powerFactor: 0.8,
      );

      expect(calculation.calculateDropV(), closeTo(1.906, 0.002));
    });

    test('calculates DC voltage drop with round-trip length', () {
      const calculation = VoltageDropCalculation(
        supplyType: SupplyType.dc,
        currentA: 5,
        lengthM: 10,
        voltageV: 24,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 1.5,
      );

      expect(calculation.calculateDropV(), closeTo(1.1494, 0.001));
    });

    test('corrects conductor resistance for temperature', () {
      const base = VoltageDropCalculation(
        supplyType: SupplyType.singlePhaseAc,
        currentA: 10,
        lengthM: 20,
        voltageV: 230,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 2.5,
      );
      const hot = VoltageDropCalculation(
        supplyType: SupplyType.singlePhaseAc,
        currentA: 10,
        lengthM: 20,
        voltageV: 230,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 2.5,
        conductorTemperatureC: 70,
      );

      expect(hot.calculateDropV(), greaterThan(base.calculateDropV()));
    });

    test('calculates theoretical minimum cross-section', () {
      const calculation = VoltageDropCalculation(
        supplyType: SupplyType.singlePhaseAc,
        currentA: 10,
        lengthM: 20,
        voltageV: 230,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 2.5,
      );

      expect(
        calculation.requiredCrossSectionMm2(3),
        closeTo(0.999, 0.002),
      );
    });

    test('reports whether user-defined maximum is respected', () {
      const calculation = VoltageDropCalculation(
        supplyType: SupplyType.singlePhaseAc,
        currentA: 10,
        lengthM: 20,
        voltageV: 230,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 2.5,
        maximumDropPercent: 3,
      );

      expect(calculation.isWithinMaximumDrop(), isTrue);
    });

    test('returns null when no maximum was configured', () {
      const calculation = VoltageDropCalculation(
        supplyType: SupplyType.dc,
        currentA: 1,
        lengthM: 1,
        voltageV: 12,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 1,
      );

      expect(calculation.isWithinMaximumDrop(), isNull);
    });

    test('rejects invalid inputs', () {
      const invalid = VoltageDropCalculation(
        supplyType: SupplyType.singlePhaseAc,
        currentA: -1,
        lengthM: 10,
        voltageV: 230,
        conductorMaterial: ConductorMaterial.copper,
        crossSectionMm2: 2.5,
      );

      expect(invalid.calculateDropV, throwsArgumentError);
    });
  });
}
