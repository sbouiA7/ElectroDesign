/// Structured, traceable catalogue record for a protective electrical device.
///
/// This is a data model, not a source of default electrical ratings. Real
/// catalogue entries must be populated from the exact manufacturer's
/// documentation and reviewed for the applicable standard and configuration.
enum ProtectiveDeviceCategory {
  miniatureCircuitBreaker,
  moldedCaseCircuitBreaker,
  airCircuitBreaker,
  residualCurrentDevice,
  residualCurrentCircuitBreaker,
  fuse,
  motorProtectionCircuitBreaker,
  relay,
  surgeProtectionDevice,
  other,
}

enum ResidualCurrentDeviceType { ac, a, f, b }

/// Provenance for a manufacturer's document used to populate catalogue data.
class ManufacturerDocumentReference {
  const ManufacturerDocumentReference({
    required this.title,
    required this.sourceUrl,
    required this.documentRevision,
    required this.language,
    required this.retrievedOn,
    this.publicationDate,
    this.pageReferences = const [],
  });

  final String title;
  final String sourceUrl;
  final String documentRevision;
  final String language;
  final String retrievedOn;
  final String? publicationDate;
  final List<String> pageReferences;

  bool get hasTraceableSource =>
      title.trim().isNotEmpty &&
      _isHttpsUrl(sourceUrl) &&
      documentRevision.trim().isNotEmpty &&
      language.trim().isNotEmpty &&
      _isIsoDate(retrievedOn) &&
      (publicationDate == null || _isIsoDate(publicationDate!)) &&
      pageReferences.isNotEmpty &&
      pageReferences.every((page) => page.trim().isNotEmpty);

  static bool _isHttpsUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  static bool _isIsoDate(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed != null &&
        parsed.toIso8601String().substring(0, 10) == value;
  }
}

class ProtectiveDeviceCatalogEntry {
  const ProtectiveDeviceCatalogEntry({
    required this.manufacturer,
    required this.productReference,
    required this.productFamily,
    required this.category,
    required this.document,
    required this.standardReferences,
    this.description,
    this.ratedCurrentA,
    this.ratedOperationalVoltageV,
    this.ratedInsulationVoltageV,
    this.ratedImpulseWithstandVoltageKv,
    this.poleCount,
    this.breakingCapacityA,
    this.breakingCapacityStandard,
    this.breakingCapacityVoltageV,
    this.residualCurrentType,
    this.residualOperatingCurrentA,
    this.selectivityLimitA,
    this.curve,
    this.catalogueRevision,
    this.configurationNotes,
  });

  final String manufacturer;
  final String productReference;
  final String productFamily;
  final ProtectiveDeviceCategory category;
  final String? description;
  final double? ratedCurrentA;
  final double? ratedOperationalVoltageV;
  final double? ratedInsulationVoltageV;
  final double? ratedImpulseWithstandVoltageKv;
  final int? poleCount;
  final double? breakingCapacityA;
  final String? breakingCapacityStandard;

  /// Voltage condition belonging to Icn/Icu/Ics; distinct from device Ue.
  final double? breakingCapacityVoltageV;

  final ResidualCurrentDeviceType? residualCurrentType;
  final double? residualOperatingCurrentA;
  final double? selectivityLimitA;
  final ProtectiveDeviceCurve? curve;
  final String? catalogueRevision;
  final List<String> standardReferences;
  final List<String>? configurationNotes;
  final ManufacturerDocumentReference document;

  bool get hasValidIdentityAndSource =>
      manufacturer.trim().isNotEmpty &&
      productReference.trim().isNotEmpty &&
      productFamily.trim().isNotEmpty &&
      standardReferences.isNotEmpty &&
      standardReferences.every((item) => item.trim().isNotEmpty) &&
      document.hasTraceableSource &&
      _optionalPositive(ratedCurrentA) &&
      _optionalPositive(ratedOperationalVoltageV) &&
      _optionalPositive(ratedInsulationVoltageV) &&
      _optionalPositive(ratedImpulseWithstandVoltageKv) &&
      _optionalPositive(breakingCapacityA) &&
      _optionalPositive(breakingCapacityVoltageV) &&
      _optionalPositive(residualOperatingCurrentA) &&
      _optionalPositive(selectivityLimitA) &&
      (poleCount == null || poleCount! > 0);

  bool get hasBreakingCapacityData =>
      hasValidIdentityAndSource &&
      breakingCapacityA != null &&
      breakingCapacityStandard != null &&
      breakingCapacityStandard!.trim().isNotEmpty &&
      breakingCapacityVoltageV != null;

  bool get hasResidualCurrentData =>
      hasValidIdentityAndSource &&
      (category == ProtectiveDeviceCategory.residualCurrentDevice ||
          category == ProtectiveDeviceCategory.residualCurrentCircuitBreaker) &&
      residualCurrentType != null &&
      residualOperatingCurrentA != null;

  bool get hasCurveData =>
      hasValidIdentityAndSource &&
      curve != null &&
      curve!.deviceReference.trim().isNotEmpty &&
      curve!.points.length >= 2;

  static bool _optionalPositive(double? value) =>
      value == null || (value.isFinite && value > 0);
}

class ProtectiveDeviceCatalogueMetadata {
  const ProtectiveDeviceCatalogueMetadata({
    required this.catalogueVersion,
    required this.updatedOn,
    required this.entries,
  });

  final String catalogueVersion;
  final String updatedOn;
  final List<ProtectiveDeviceCatalogEntry> entries;

  bool get hasValidMetadata =>
      catalogueVersion.trim().isNotEmpty &&
      DateTime.tryParse(updatedOn)?.toIso8601String().substring(0, 10) ==
          updatedOn &&
      entries.every((entry) => entry.hasValidIdentityAndSource);

  List<ProtectiveDeviceCatalogEntry> entriesForManufacturer(
    String manufacturer,
  ) =>
      entries
          .where((entry) =>
              entry.manufacturer.toLowerCase() ==
              manufacturer.toLowerCase())
          .toList(growable: false);
}
