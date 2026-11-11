import 'dart:ui';

import 'electrical_terminal.dart';

class Part {
  const Part(
    this.name,
    this.family,
    this.symbol,
    this.details, {
    this.terminals = const [],
  });

  final String name;
  final String family;
  final String symbol;
  final String details;

  /// Only verified catalogue terminals or terminals configured by the user.
  final List<ElectricalTerminal> terminals;
}

class PlacedPart {
  PlacedPart(
    this.part,
    this.position, {
    String? id,
    this.protectiveDeviceManufacturer,
    this.protectiveDeviceReference,
    this.protectiveDeviceRatingType,
    this.protectiveDeviceBreakingCapacityA,
    this.protectiveDeviceBreakingStandard,
    this.protectiveDeviceBreakingVoltageV,
    this.protectiveDeviceRatedCurrentA,
  }) : id = id ?? 'placed-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  static int _nextId = 0;

  /// Stable identity retained when the project is saved and reopened.
  final String id;
  final Part part;
  final Offset position;
  final String? protectiveDeviceManufacturer;
  final String? protectiveDeviceReference;
  final String? protectiveDeviceRatingType;
  final double? protectiveDeviceBreakingCapacityA;
  final String? protectiveDeviceBreakingStandard;
  final double? protectiveDeviceBreakingVoltageV;
  final double? protectiveDeviceRatedCurrentA;

  PlacedPart copyWith({
    Part? part,
    String? protectiveDeviceManufacturer,
    String? protectiveDeviceReference,
    String? protectiveDeviceRatingType,
    double? protectiveDeviceBreakingCapacityA,
    String? protectiveDeviceBreakingStandard,
    double? protectiveDeviceBreakingVoltageV,
    double? protectiveDeviceRatedCurrentA,
    bool clearProtectiveDevice = false,
  }) => PlacedPart(
        part ?? this.part,
        position,
        id: id,
        protectiveDeviceManufacturer: clearProtectiveDevice
            ? null : protectiveDeviceManufacturer ?? this.protectiveDeviceManufacturer,
        protectiveDeviceReference: clearProtectiveDevice
            ? null : protectiveDeviceReference ?? this.protectiveDeviceReference,
        protectiveDeviceRatingType: clearProtectiveDevice
            ? null : protectiveDeviceRatingType ?? this.protectiveDeviceRatingType,
        protectiveDeviceBreakingCapacityA: clearProtectiveDevice
            ? null : protectiveDeviceBreakingCapacityA ?? this.protectiveDeviceBreakingCapacityA,
        protectiveDeviceBreakingStandard: clearProtectiveDevice
            ? null : protectiveDeviceBreakingStandard ?? this.protectiveDeviceBreakingStandard,
        protectiveDeviceBreakingVoltageV: clearProtectiveDevice
            ? null : protectiveDeviceBreakingVoltageV ?? this.protectiveDeviceBreakingVoltageV,
        protectiveDeviceRatedCurrentA: clearProtectiveDevice
            ? null : protectiveDeviceRatedCurrentA ?? this.protectiveDeviceRatedCurrentA,
      );
}
