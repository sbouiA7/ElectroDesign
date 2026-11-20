/// Checks overload coordination and short-circuit withstand for a cable and
/// its protective device using values supplied from verified device/cable data.
///
/// This model evaluates the common IEC 60364 overload conditions
/// Ib <= In <= Iz and I2 <= 1.45 Iz, plus breaking-capacity and adiabatic
/// cable withstand checks. Applicability and constants must be confirmed for
/// the selected device standard, cable insulation and national rules.
class ProtectiveDeviceCoordinationRequest {
  const ProtectiveDeviceCoordinationRequest({
    required this.designCurrentA,
    required this.deviceRatedCurrentA,
    required this.correctedCableAmpacityA,
    required this.deviceConventionalOperatingCurrentA,
    required this.prospectiveShortCircuitCurrentA,
    required this.deviceBreakingCapacityA,
    required this.deviceLetThroughEnergyA2s,
    required this.cableKFactor,
    required this.cableCrossSectionMm2,
    this.overloadConventionalFactor = 1.45,
  });

  /// Ib: design/load current.
  final double designCurrentA;

  /// In: rated or selected setting current of the protective device.
  final double deviceRatedCurrentA;

  /// Iz: cable ampacity after all applicable correction factors.
  final double correctedCableAmpacityA;

  /// I2: conventional operating current of the protective device, from its
  /// standard/manufacturer data. Do not assume it equals In.
  final double deviceConventionalOperatingCurrentA;

  /// Prospective short-circuit current at the device installation point.
  final double prospectiveShortCircuitCurrentA;

  /// Device rated short-circuit breaking capacity (Icn/Icu as applicable).
  final double deviceBreakingCapacityA;

  /// Manufacturer's maximum let-through energy I²t at the stated fault level.
  final double deviceLetThroughEnergyA2s;

  /// Cable thermal constant k for the actual conductor/insulation conditions.
  final double cableKFactor;

  /// Cable conductor cross-section in mm².
  final double cableCrossSectionMm2;

  /// Common IEC criterion; confirm applicability for the chosen device.
  final double overloadConventionalFactor;

  ProtectiveDeviceCoordinationResult evaluate() {
    _validate();

    final loadBelowDevice = designCurrentA <= deviceRatedCurrentA;
    final deviceBelowCable = deviceRatedCurrentA <= correctedCableAmpacityA;
    final conventionalTripWithinLimit =
        deviceConventionalOperatingCurrentA <=
        overloadConventionalFactor * correctedCableAmpacityA;
    final breakingCapacitySufficient =
        deviceBreakingCapacityA >= prospectiveShortCircuitCurrentA;

    // Adiabatic withstand: I²t <= k²S².
    final cableWithstandEnergyA2s =
        cableKFactor * cableCrossSectionMm2;
    final cableWithstandsLetThrough =
        deviceLetThroughEnergyA2s <=
        cableWithstandEnergyA2s * cableWithstandEnergyA2s;

    return ProtectiveDeviceCoordinationResult(
      loadBelowDevice: loadBelowDevice,
      deviceBelowCable: deviceBelowCable,
      conventionalTripWithinLimit: conventionalTripWithinLimit,
      breakingCapacitySufficient: breakingCapacitySufficient,
      cableWithstandsLetThrough: cableWithstandsLetThrough,
      cableWithstandEnergyA2s:
          cableWithstandEnergyA2s * cableWithstandEnergyA2s,
      deviceLetThroughEnergyA2s: deviceLetThroughEnergyA2s,
    );
  }

  void _validate() {
    _positive(designCurrentA, 'designCurrentA');
    _positive(deviceRatedCurrentA, 'deviceRatedCurrentA');
    _positive(correctedCableAmpacityA, 'correctedCableAmpacityA');
    _positive(deviceConventionalOperatingCurrentA,
        'deviceConventionalOperatingCurrentA');
    _positive(prospectiveShortCircuitCurrentA,
        'prospectiveShortCircuitCurrentA');
    _positive(deviceBreakingCapacityA, 'deviceBreakingCapacityA');
    _positive(deviceLetThroughEnergyA2s, 'deviceLetThroughEnergyA2s');
    _positive(cableKFactor, 'cableKFactor');
    _positive(cableCrossSectionMm2, 'cableCrossSectionMm2');
    _positive(overloadConventionalFactor, 'overloadConventionalFactor');
  }

  static void _positive(double value, String name) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(
        value,
        name,
        'Value must be finite and greater than zero.',
      );
    }
  }
}

class ProtectiveDeviceCoordinationResult {
  const ProtectiveDeviceCoordinationResult({
    required this.loadBelowDevice,
    required this.deviceBelowCable,
    required this.conventionalTripWithinLimit,
    required this.breakingCapacitySufficient,
    required this.cableWithstandsLetThrough,
    required this.cableWithstandEnergyA2s,
    required this.deviceLetThroughEnergyA2s,
  });

  final bool loadBelowDevice;
  final bool deviceBelowCable;
  final bool conventionalTripWithinLimit;
  final bool breakingCapacitySufficient;
  final bool cableWithstandsLetThrough;
  final double cableWithstandEnergyA2s;
  final double deviceLetThroughEnergyA2s;

  bool get overloadCoordinationValid =>
      loadBelowDevice && deviceBelowCable && conventionalTripWithinLimit;

  bool get shortCircuitCoordinationValid =>
      breakingCapacitySufficient && cableWithstandsLetThrough;

  bool get isFullyCoordinated =>
      overloadCoordinationValid && shortCircuitCoordinationValid;
}
