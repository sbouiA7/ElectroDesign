import 'dart:math' as math;

/// Conductor material used by the simplified voltage-drop estimator.
enum ConductorMaterial {
  copper,
  aluminium,
}

/// Voltage-drop calculation model.
///
/// Resistance-only approximation using conductor resistivity at 20 °C,
/// corrected with a linear temperature coefficient. Cable reactance,
/// harmonic effects, parallel conductors, installation derating, short-circuit
/// withstand and protective-device coordination are not included.
///
/// This model is an engineering estimate, not a cable-selection or compliance
/// result. A qualified designer must verify the applicable national rules,
/// installation method, ambient temperature, grouping, conductor insulation,
/// fault protection and manufacturer data.
class VoltageDropCalculation {
  const VoltageDropCalculation({
    required this.supplyType,
    required this.currentA,
    required this.lengthM,
    required this.voltageV,
    required this.conductorMaterial,
    required this.crossSectionMm2,
    this.powerFactor = 1,
    this.conductorTemperatureC = 20,
    this.maximumDropPercent,
  });

  final SupplyType supplyType;
  final double currentA;

  /// One-way route length from source to load, in metres.
  final double lengthM;
  final double voltageV;
  final ConductorMaterial conductorMaterial;

  /// Conductor cross-section in mm².
  final double crossSectionMm2;

  /// Used for AC voltage-drop projection; must be in (0, 1].
  /// For DC it is ignored.
  final double powerFactor;

  /// Estimated conductor operating temperature in °C.
  final double conductorTemperatureC;

  /// Optional user-defined limit in percent. This is not a default standard.
  final double? maximumDropPercent;

  double calculateDropV() {
    _validate();
    final resistance = _resistancePerKmOhm() / 1000;
    final pathFactor = supplyType == SupplyType.threePhaseAc
        ? math.sqrt(3)
        : 2.0;
    final acFactor = supplyType == SupplyType.dc ? 1.0 : powerFactor;
    return pathFactor * lengthM * currentA * resistance * acFactor;
  }

  double calculateDropPercent() => calculateDropV() / voltageV * 100;

  /// Returns the theoretical minimum cross-section for the requested drop
  /// limit. It does not round up to a commercial cable size.
  double requiredCrossSectionMm2(double allowedDropPercent) {
    _validate();
    if (!allowedDropPercent.isFinite ||
        allowedDropPercent <= 0 ||
        allowedDropPercent >= 100) {
      throw ArgumentError.value(
        allowedDropPercent,
        'allowedDropPercent',
        'Allowed voltage drop must be finite and between 0 and 100 percent.',
      );
    }

    final allowedDropV = voltageV * allowedDropPercent / 100;
    final rho = _resistivityAtTemperature();
    final pathFactor = supplyType == SupplyType.threePhaseAc
        ? math.sqrt(3)
        : 2.0;
    final acFactor = supplyType == SupplyType.dc ? 1.0 : powerFactor;
    return pathFactor * lengthM * currentA * rho * acFactor / allowedDropV;
  }

  bool? isWithinMaximumDrop() {
    final limit = maximumDropPercent;
    if (limit == null) return null;
    if (!limit.isFinite || limit <= 0 || limit >= 100) {
      throw ArgumentError.value(
        limit,
        'maximumDropPercent',
        'Maximum voltage drop must be finite and between 0 and 100 percent.',
      );
    }
    return calculateDropPercent() <= limit;
  }

  double _resistancePerKmOhm() =>
      _resistivityAtTemperature() * 1000 / crossSectionMm2;

  double _resistivityAtTemperature() {
    final (rho20, alpha) = switch (conductorMaterial) {
      ConductorMaterial.copper => (0.017241, 0.00393),
      ConductorMaterial.aluminium => (0.028264, 0.00403),
    };
    return rho20 * (1 + alpha * (conductorTemperatureC - 20));
  }

  void _validate() {
    _positiveFinite(currentA, 'currentA');
    _positiveFinite(lengthM, 'lengthM');
    _positiveFinite(voltageV, 'voltageV');
    _positiveFinite(crossSectionMm2, 'crossSectionMm2');
    if (!conductorTemperatureC.isFinite || conductorTemperatureC < -50 ||
        conductorTemperatureC > 250) {
      throw ArgumentError.value(
        conductorTemperatureC,
        'conductorTemperatureC',
        'Temperature must be finite and between -50 and 250 °C.',
      );
    }
    if (supplyType != SupplyType.dc &&
        (!powerFactor.isFinite || powerFactor <= 0 || powerFactor > 1)) {
      throw ArgumentError.value(
        powerFactor,
        'powerFactor',
        'For AC, power factor must be greater than 0 and at most 1.',
      );
    }
  }

  static void _positiveFinite(double value, String name) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(
        value,
        name,
        'Value must be finite and greater than zero.',
      );
    }
  }
}
