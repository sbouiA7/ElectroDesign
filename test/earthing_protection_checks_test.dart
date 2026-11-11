import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/earthing_protection_checks.dart';

void main() {
  group('TT earthing protection', () {
    test('satisfies RA × IΔn ≤ UL', () {
      final result = const TtEarthingProtectionCheck(
        electrodeAndProtectiveConductorResistanceOhm: 80,
        residualOperatingCurrentA: 0.03,
        conventionalTouchVoltageLimitV: 50,
      ).evaluate();

      expect(result.raTimesResidualCurrentV, closeTo(2.4, 0.001));
      expect(result.touchVoltageConditionSatisfied, isTrue);
    });

    test('fails when the touch-voltage product exceeds UL', () {
      final result = const TtEarthingProtectionCheck(
        electrodeAndProtectiveConductorResistanceOhm: 2000,
        residualOperatingCurrentA: 0.03,
        conventionalTouchVoltageLimitV: 50,
      ).evaluate();

      expect(result.touchVoltageConditionSatisfied, isFalse);
    });

    test('rejects invalid values', () {
      expect(
        () => const TtEarthingProtectionCheck(
          electrodeAndProtectiveConductorResistanceOhm: 0,
          residualOperatingCurrentA: 0.03,
          conventionalTouchVoltageLimitV: 50,
        ).evaluate(),
        throwsArgumentError,
      );
    });
  });

  group('TN earthing protection', () {
    test('satisfies Zs × Ia ≤ U0', () {
      final result = const TnEarthingProtectionCheck(
        faultLoopImpedanceOhm: 0.8,
        disconnectionCurrentA: 100,
        nominalPhaseToEarthVoltageV: 230,
      ).evaluate();

      expect(result.zsTimesDisconnectionCurrentV, 80);
      expect(result.impedanceConditionSatisfied, isTrue);
    });

    test('fails when loop impedance condition is exceeded', () {
      final result = const TnEarthingProtectionCheck(
        faultLoopImpedanceOhm: 3,
        disconnectionCurrentA: 100,
        nominalPhaseToEarthVoltageV: 230,
      ).evaluate();

      expect(result.impedanceConditionSatisfied, isFalse);
    });
  });

  group('IT earthing assessment', () {
    test('never claims compliance without first and second fault study', () {
      const assessment = ItEarthingProtectionAssessment();

      expect(assessment.system, EarthingSystem.it);
      expect(assessment.requiresDetailedFirstAndSecondFaultStudy, isTrue);
      expect(assessment.isComplianceVerified, isFalse);
    });
  });

  group('RCD selection', () {
    test('accepts declared type and sensitivity constraints', () {
      final result = const ResidualCurrentDeviceSelection(
        requiredType: ResidualCurrentDeviceType.a,
        selectedType: ResidualCurrentDeviceType.a,
        selectedSensitivityA: 0.03,
        maximumPermittedSensitivityA: 0.03,
      ).evaluate();

      expect(result.declaredSelectionValid, isTrue);
    });

    test('rejects wrong type or excessive sensitivity', () {
      final result = const ResidualCurrentDeviceSelection(
        requiredType: ResidualCurrentDeviceType.b,
        selectedType: ResidualCurrentDeviceType.a,
        selectedSensitivityA: 0.3,
        maximumPermittedSensitivityA: 0.03,
      ).evaluate();

      expect(result.typeMatchesRequirement, isFalse);
      expect(result.sensitivityWithinLimit, isFalse);
      expect(result.declaredSelectionValid, isFalse);
    });
  });
}
