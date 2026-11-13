/// Earthing-system checks based on installation and manufacturer data.
///
/// These are deliberately limited checks, not a declaration of compliance.
/// The designer must confirm the applicable national rules, disconnection
/// times, device curves, installation conditions and manufacturer instructions.
enum EarthingSystem { tt, tn, it }

/// Simplified TT automatic-disconnection condition: RA × IΔn ≤ UL.
class TtEarthingProtectionCheck {
  const TtEarthingProtectionCheck({
    required this.electrodeAndProtectiveConductorResistanceOhm,
    required this.residualOperatingCurrentA,
    required this.conventionalTouchVoltageLimitV,
  });

  /// RA: total resistance of the earth electrode and relevant protective path.
  final double electrodeAndProtectiveConductorResistanceOhm;

  /// IΔn: rated residual operating current of the selected RCD.
  final double residualOperatingCurrentA;

  /// UL: touch-voltage limit selected for the actual conditions and rules.
  /// No universal default is imposed.
  final double conventionalTouchVoltageLimitV;

  TtEarthingProtectionResult evaluate() {
    _positive(electrodeAndProtectiveConductorResistanceOhm, 'RA');
    _positive(residualOperatingCurrentA, 'IΔn');
    _positive(conventionalTouchVoltageLimitV, 'UL');
    final product =
        electrodeAndProtectiveConductorResistanceOhm *
        residualOperatingCurrentA;
    return TtEarthingProtectionResult(
      raTimesResidualCurrentV: product,
      touchVoltageConditionSatisfied:
          product <= conventionalTouchVoltageLimitV,
    );
  }

  static void _positive(double value, String name) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(value, name, 'Must be finite and positive.');
    }
  }
}

class TtEarthingProtectionResult {
  const TtEarthingProtectionResult({
    required this.raTimesResidualCurrentV,
    required this.touchVoltageConditionSatisfied,
  });

  final double raTimesResidualCurrentV;
  final bool touchVoltageConditionSatisfied;
}

/// TN automatic-disconnection condition: Zs × Ia ≤ U0.
///
/// Ia must be taken from the selected protective device's time/current curve
/// at the required disconnection time; it is not inferred from its In rating.
class TnEarthingProtectionCheck {
  const TnEarthingProtectionCheck({
    required this.faultLoopImpedanceOhm,
    required this.disconnectionCurrentA,
    required this.nominalPhaseToEarthVoltageV,
  });

  /// Zs: measured or calculated earth-fault loop impedance.
  final double faultLoopImpedanceOhm;

  /// Ia: current that guarantees operation within the required time.
  final double disconnectionCurrentA;

  /// U0: nominal AC voltage to earth for the circuit.
  final double nominalPhaseToEarthVoltageV;

  TnEarthingProtectionResult evaluate() {
    _positive(faultLoopImpedanceOhm, 'Zs');
    _positive(disconnectionCurrentA, 'Ia');
    _positive(nominalPhaseToEarthVoltageV, 'U0');
    final product = faultLoopImpedanceOhm * disconnectionCurrentA;
    return TnEarthingProtectionResult(
      zsTimesDisconnectionCurrentV: product,
      impedanceConditionSatisfied:
          product <= nominalPhaseToEarthVoltageV,
    );
  }

  static void _positive(double value, String name) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(value, name, 'Must be finite and positive.');
    }
  }
}

class TnEarthingProtectionResult {
  const TnEarthingProtectionResult({
    required this.zsTimesDisconnectionCurrentV,
    required this.impedanceConditionSatisfied,
  });

  final double zsTimesDisconnectionCurrentV;
  final bool impedanceConditionSatisfied;
}

/// IT systems need separate first-fault and second-fault studies, including
/// insulation monitoring and the actual earthing/bonding arrangement.
/// This marker intentionally never reports an automatic-disconnection pass.
class ItEarthingProtectionAssessment {
  const ItEarthingProtectionAssessment();

  EarthingSystem get system => EarthingSystem.it;
  bool get requiresDetailedFirstAndSecondFaultStudy => true;
  bool get isComplianceVerified => false;
}

/// RCD types. The required type must be determined from the connected loads,
/// possible residual-current waveforms and applicable installation rules.
enum ResidualCurrentDeviceType { ac, a, f, b }

class ResidualCurrentDeviceSelection {
  const ResidualCurrentDeviceSelection({
    required this.requiredType,
    required this.selectedType,
    required this.selectedSensitivityA,
    required this.maximumPermittedSensitivityA,
  });

  final ResidualCurrentDeviceType requiredType;
  final ResidualCurrentDeviceType selectedType;

  /// Selected IΔn, in amperes.
  final double selectedSensitivityA;

  /// Maximum IΔn allowed by the design requirement, in amperes.
  final double maximumPermittedSensitivityA;

  ResidualCurrentDeviceSelectionResult evaluate() {
    _positive(selectedSensitivityA, 'selectedSensitivityA');
    _positive(maximumPermittedSensitivityA, 'maximumPermittedSensitivityA');
    return ResidualCurrentDeviceSelectionResult(
      typeMatchesRequirement: selectedType == requiredType,
      sensitivityWithinLimit:
          selectedSensitivityA <= maximumPermittedSensitivityA,
    );
  }

  static void _positive(double value, String name) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(value, name, 'Must be finite and positive.');
    }
  }
}

class ResidualCurrentDeviceSelectionResult {
  const ResidualCurrentDeviceSelectionResult({
    required this.typeMatchesRequirement,
    required this.sensitivityWithinLimit,
  });

  final bool typeMatchesRequirement;
  final bool sensitivityWithinLimit;

  /// This checks only the declared type and sensitivity constraints.
  /// It does not verify RCD overload protection, short-circuit coordination,
  /// selectivity, time delay, pole count or manufacturer compatibility.
  bool get declaredSelectionValid =>
      typeMatchesRequirement && sensitivityWithinLimit;
}
