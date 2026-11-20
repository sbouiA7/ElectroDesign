import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/electrical_load.dart';

void main() {
  group('ElectricalLoad current calculation', () {
    test('calculates DC current', () {
      const load = ElectricalLoad(
        supplyType: SupplyType.dc,
        activePowerW: 120,
        voltageV: 24,
      );
      expect(load.calculateCurrentA(), closeTo(5, 1e-10));
    });

    test('calculates single-phase AC current with power factor', () {
      const load = ElectricalLoad(
        supplyType: SupplyType.singlePhaseAc,
        activePowerW: 2300,
        voltageV: 230,
        powerFactor: 1,
      );
      expect(load.calculateCurrentA(), closeTo(10, 1e-10));
    });

    test('calculates three-phase AC current', () {
      const load = ElectricalLoad(
        supplyType: SupplyType.threePhaseAc,
        activePowerW: 6900,
        voltageV: 400,
        powerFactor: 1,
      );
      expect(load.calculateCurrentA(), closeTo(6900 / (1.7320508075688772 * 400), 1e-10));
    });

    test('rejects missing AC power factor', () {
      const load = ElectricalLoad(
        supplyType: SupplyType.singlePhaseAc,
        activePowerW: 1000,
        voltageV: 230,
      );
      expect(load.calculateCurrentA, throwsArgumentError);
    });

    test('rejects invalid power factor', () {
      const load = ElectricalLoad(
        supplyType: SupplyType.threePhaseAc,
        activePowerW: 1000,
        voltageV: 400,
        powerFactor: 1.2,
      );
      expect(load.calculateCurrentA, throwsArgumentError);
    });

    test('rejects non-positive power and voltage', () {
      const zeroPower = ElectricalLoad(
        supplyType: SupplyType.dc,
        activePowerW: 0,
        voltageV: 24,
      );
      const negativeVoltage = ElectricalLoad(
        supplyType: SupplyType.dc,
        activePowerW: 100,
        voltageV: -24,
      );
      expect(zeroPower.calculateCurrentA, throwsArgumentError);
      expect(negativeVoltage.calculateCurrentA, throwsArgumentError);
    });
  });
}
