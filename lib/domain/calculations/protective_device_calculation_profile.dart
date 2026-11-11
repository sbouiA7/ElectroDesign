import 'protective_device_catalog.dart';
import 'protective_device_coordination.dart';

/// Bridges one explicitly qualified manufacturer record to the coordination
/// engine. All installation, cable and protection-curve inputs remain explicit.
class ProtectiveDeviceCalculationProfile {
  const ProtectiveDeviceCalculationProfile(this.device);

  final ProtectiveDeviceCatalogEntry device;

  ProtectiveDeviceCoordinationRequest buildCoordinationRequest({
    required double networkVoltageV,
    required double deviceRatedCurrentA,
    required double designCurrentA,
    required double correctedCableAmpacityA,
    required double deviceConventionalOperatingCurrentA,
    required double prospectiveShortCircuitCurrentA,
    required double deviceLetThroughEnergyA2s,
    required double cableKFactor,
    required double cableCrossSectionMm2,
    double overloadConventionalFactor = 1.45,
  }) {
    if (!device.hasBreakingCapacityData) {
      throw StateError(
        'La fiche fabricant ne possède pas de pouvoir de coupure qualifié.',
      );
    }
    if (device.category != ProtectiveDeviceCategory.miniatureCircuitBreaker &&
        device.category != ProtectiveDeviceCategory.moldedCaseCircuitBreaker &&
        device.category != ProtectiveDeviceCategory.airCircuitBreaker) {
      throw StateError(
        'Cette catégorie de protection ne peut pas utiliser ce profil de calcul.',
      );
    }
    if (!networkVoltageV.isFinite ||
        networkVoltageV <= 0 ||
        (networkVoltageV - device.breakingCapacityVoltageV!).abs() > 0.01) {
      throw StateError(
        'La tension du réseau ne correspond pas à la tension déclarée '
        'pour le pouvoir de coupure (' +
            device.breakingCapacityVoltageV.toString() +
            ' V).',
      );
    }
    if (device.ratedCurrentA == null ||
        !deviceRatedCurrentA.isFinite ||
        (deviceRatedCurrentA - device.ratedCurrentA!).abs() > 0.01) {
      throw StateError(
        'Le calibre utilisé doit correspondre au calibre documenté '
        'de la fiche fabricant.',
      );
    }

    return ProtectiveDeviceCoordinationRequest(
      designCurrentA: designCurrentA,
      deviceRatedCurrentA: deviceRatedCurrentA,
      correctedCableAmpacityA: correctedCableAmpacityA,
      deviceConventionalOperatingCurrentA:
          deviceConventionalOperatingCurrentA,
      prospectiveShortCircuitCurrentA: prospectiveShortCircuitCurrentA,
      deviceBreakingCapacityA: device.breakingCapacityA!,
      deviceLetThroughEnergyA2s: deviceLetThroughEnergyA2s,
      cableKFactor: cableKFactor,
      cableCrossSectionMm2: cableCrossSectionMm2,
      overloadConventionalFactor: overloadConventionalFactor,
    );
  }
}
