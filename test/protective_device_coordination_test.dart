import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/protective_device_coordination.dart';

void main() {
  group('ProtectiveDeviceCoordinationRequest', () {
    ProtectiveDeviceCoordinationRequest request({
      double designCurrentA = 16,
      double deviceRatedCurrentA = 20,
      double correctedCableAmpacityA = 25,
      double deviceConventionalOperatingCurrentA = 29,
      double prospectiveShortCircuitCurrentA = 3000,
      double deviceBreakingCapacityA = 6000,
      double deviceLetThroughEnergyA2s = 50000,
      double cableKFactor = 115,
      double cableCrossSectionMm2 = 2.5,
    }) {
      return ProtectiveDeviceCoordinationRequest(
        designCurrentA: designCurrentA,
        deviceRatedCurrentA: deviceRatedCurrentA,
        correctedCableAmpacityA: correctedCableAmpacityA,
        deviceConventionalOperatingCurrentA:
            deviceConventionalOperatingCurrentA,
        prospectiveShortCircuitCurrentA: prospectiveShortCircuitCurrentA,
        deviceBreakingCapacityA: deviceBreakingCapacityA,
        deviceLetThroughEnergyA2s: deviceLetThroughEnergyA2s,
        cableKFactor: cableKFactor,
        cableCrossSectionMm2: cableCrossSectionMm2,
      );
    }

    test('passes when overload and short-circuit checks all pass', () {
      final result = request().evaluate();

      expect(result.overloadCoordinationValid, isTrue);
      expect(result.shortCircuitCoordinationValid, isTrue);
      expect(result.isFullyCoordinated, isTrue);
      expect(result.cableWithstandEnergyA2s, closeTo(82656.25, 0.01));
    });

    test('fails when device rating exceeds corrected cable ampacity', () {
      final result = request(
        deviceRatedCurrentA: 32,
        correctedCableAmpacityA: 25,
      ).evaluate();

      expect(result.deviceBelowCable, isFalse);
      expect(result.overloadCoordinationValid, isFalse);
    });

    test('fails when conventional operating current is too high', () {
      final result = request(
        deviceConventionalOperatingCurrentA: 40,
      ).evaluate();

      expect(result.conventionalTripWithinLimit, isFalse);
      expect(result.overloadCoordinationValid, isFalse);
    });

    test('fails when breaking capacity is below prospective fault current', () {
      final result = request(
        prospectiveShortCircuitCurrentA: 10000,
        deviceBreakingCapacityA: 6000,
      ).evaluate();

      expect(result.breakingCapacitySufficient, isFalse);
      expect(result.shortCircuitCoordinationValid, isFalse);
    });

    test('fails when device let-through energy exceeds cable withstand', () {
      final result = request(
        deviceLetThroughEnergyA2s: 100000,
      ).evaluate();

      expect(result.cableWithstandsLetThrough, isFalse);
      expect(result.shortCircuitCoordinationValid, isFalse);
    });

    test('rejects invalid inputs', () {
      expect(
        request(designCurrentA: 0).evaluate,
        throwsArgumentError,
      );
    });
  });
}
