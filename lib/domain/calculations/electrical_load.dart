import 'dart:math' as math;

/// Supply type used for a first-pass load-current estimate.
enum SupplyType {
  dc,
  singlePhaseAc,
  threePhaseAc,
}

/// Input data for calculating current from active power.
///
/// This is a mathematical estimate only. It does not select cable sizes or
/// protective devices and does not establish installation compliance.
class ElectricalLoad {
  const ElectricalLoad({
    required this.supplyType,
    required this.activePowerW,
    required this.voltageV,
    this.powerFactor,
  });

  final SupplyType supplyType;
  final double activePowerW;
  final double voltageV;

  /// Required for AC; ignored for DC.
  final double? powerFactor;

  double calculateCurrentA() {
    if (!activePowerW.isFinite || activePowerW <= 0) {
      throw ArgumentError.value(activePowerW, 'activePowerW',
          'Active power must be a finite value greater than zero.');
    }
    if (!voltageV.isFinite || voltageV <= 0) {
      throw ArgumentError.value(voltageV, 'voltageV',
          'Voltage must be a finite value greater than zero.');
    }

    switch (supplyType) {
      case SupplyType.dc:
        return activePowerW / voltageV;
      case SupplyType.singlePhaseAc:
        final factor = _validatedPowerFactor();
        return activePowerW / (voltageV * factor);
      case SupplyType.threePhaseAc:
        final factor = _validatedPowerFactor();
        return activePowerW / (math.sqrt(3) * voltageV * factor);
    }
  }

  double _validatedPowerFactor() {
    final factor = powerFactor;
    if (factor == null || !factor.isFinite || factor <= 0 || factor > 1) {
      throw ArgumentError.value(
        factor,
        'powerFactor',
        'For AC, power factor must be greater than 0 and at most 1.',
      );
    }
    return factor;
  }
}
