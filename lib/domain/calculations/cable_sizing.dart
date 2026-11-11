import 'voltage_drop_calculation.dart';
import 'electrical_load.dart';

/// Ampacity value taken from a verified standard/manufacturer table for the
/// selected cable type and installation reference method.
///
/// ElectroDesign deliberately does not embed guessed ampacity values here.
class CableAmpacityEntry {
  const CableAmpacityEntry({
    required this.crossSectionMm2,
    required this.referenceAmpacityA,
  });

  final double crossSectionMm2;
  final double referenceAmpacityA;
}

/// Applies correction factors to tabulated ampacity and checks voltage drop.
///
/// The caller must supply candidates from a verified table matching conductor
/// construction, insulation, number of loaded conductors and installation
/// reference method. Correction factors must match the applicable standard.
class CableSizingRequest {
  const CableSizingRequest({
    required this.designCurrentA,
    required this.lengthM,
    required this.voltageV,
    required this.supplyType,
    required this.conductorMaterial,
    required this.candidates,
    required this.maximumDropPercent,
    this.powerFactor = 1,
    this.conductorTemperatureC = 70,
    this.ambientTemperatureFactor = 1,
    this.groupingFactor = 1,
    this.soilOrInstallationFactor = 1,
  });

  final double designCurrentA;
  final double lengthM;
  final double voltageV;
  final SupplyType supplyType;
  final ConductorMaterial conductorMaterial;
  final List<CableAmpacityEntry> candidates;
  final double maximumDropPercent;
  final double powerFactor;
  final double conductorTemperatureC;

  /// Factors supplied from the applicable standard/manufacturer data.
  final double ambientTemperatureFactor;
  final double groupingFactor;
  final double soilOrInstallationFactor;

  double get totalCorrectionFactor {
    _validate();
    return ambientTemperatureFactor * groupingFactor * soilOrInstallationFactor;
  }

  /// Returns the smallest candidate satisfying corrected ampacity and
  /// user-defined voltage-drop limit, or null when none qualifies.
  CableSizingResult? select() {
    _validate();
    final ordered = [...candidates]
      ..sort((a, b) => a.crossSectionMm2.compareTo(b.crossSectionMm2));

    for (final candidate in ordered) {
      final correctedAmpacity =
          candidate.referenceAmpacityA * totalCorrectionFactor;
      if (correctedAmpacity < designCurrentA) continue;

      final drop = VoltageDropCalculation(
        supplyType: supplyType,
        currentA: designCurrentA,
        lengthM: lengthM,
        voltageV: voltageV,
        conductorMaterial: conductorMaterial,
        crossSectionMm2: candidate.crossSectionMm2,
        powerFactor: powerFactor,
        conductorTemperatureC: conductorTemperatureC,
        maximumDropPercent: maximumDropPercent,
      );
      final dropV = drop.calculateDropV();
      final dropPercent = dropV / voltageV * 100;
      if (dropPercent <= maximumDropPercent) {
        return CableSizingResult(
          crossSectionMm2: candidate.crossSectionMm2,
          referenceAmpacityA: candidate.referenceAmpacityA,
          correctedAmpacityA: correctedAmpacity,
          voltageDropV: dropV,
          voltageDropPercent: dropPercent,
          correctionFactor: totalCorrectionFactor,
        );
      }
    }
    return null;
  }

  void _validate() {
    _positiveFinite(designCurrentA, 'designCurrentA');
    _positiveFinite(lengthM, 'lengthM');
    _positiveFinite(voltageV, 'voltageV');
    _positiveFinite(maximumDropPercent, 'maximumDropPercent');
    if (maximumDropPercent >= 100) {
      throw ArgumentError.value(maximumDropPercent, 'maximumDropPercent');
    }
    if (supplyType != SupplyType.dc &&
        (!powerFactor.isFinite || powerFactor <= 0 || powerFactor > 1)) {
      throw ArgumentError.value(powerFactor, 'powerFactor');
    }
    if (!conductorTemperatureC.isFinite ||
        conductorTemperatureC < -50 ||
        conductorTemperatureC > 250) {
      throw ArgumentError.value(conductorTemperatureC, 'conductorTemperatureC');
    }
    for (final factor in [
      ambientTemperatureFactor,
      groupingFactor,
      soilOrInstallationFactor,
    ]) {
      if (!factor.isFinite || factor <= 0 || factor > 2) {
        throw ArgumentError.value(factor, 'correctionFactor',
            'Correction factors must be finite and greater than 0 and at most 2.');
      }
    }
    if (candidates.isEmpty) {
      throw ArgumentError.value(candidates, 'candidates',
          'At least one verified ampacity candidate is required.');
    }
    for (final candidate in candidates) {
      _positiveFinite(candidate.crossSectionMm2, 'crossSectionMm2');
      _positiveFinite(candidate.referenceAmpacityA, 'referenceAmpacityA');
    }
  }

  static void _positiveFinite(double value, String name) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(value, name,
          'Value must be finite and greater than zero.');
    }
  }
}

class CableSizingResult {
  const CableSizingResult({
    required this.crossSectionMm2,
    required this.referenceAmpacityA,
    required this.correctedAmpacityA,
    required this.voltageDropV,
    required this.voltageDropPercent,
    required this.correctionFactor,
  });

  final double crossSectionMm2;
  final double referenceAmpacityA;
  final double correctedAmpacityA;
  final double voltageDropV;
  final double voltageDropPercent;
  final double correctionFactor;
}
