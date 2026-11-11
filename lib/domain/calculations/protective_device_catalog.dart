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

  /// Date the source was checked, in ISO-8601 YYYY-MM-DD format.
  final String retrievedOn;

  /// Optional publication date, in ISO-8601 YYYY-MM-DD format.
  final String? publicationDate;

  /// Pages, tables or figures supporting the populated values.
  final List<String> pageReferences;

  bool get hasTraceableSource =>
      title.trim().isNotEmpty &&
      _isHttpUrl(sourceUrl) &&
      documentRevision.trim().isNotEmpty &&
      language.trim().isNotEmpty &&
      _isIsoDate(retrievedOn) &&
      (publicationDate == null || _isIsoDate(publicationDate!));

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  static bool _isIsoDate(String value) =>
      RegExp(r'^\\d{4}-\\d{2}-\\d{2}$').hasMatch(value);
}

/// A specific device model in a manufacturer's product range.
///
/// Ratings are nullable because not every category uses every field. A
/// catalogue importer must still validate the fields required by the intended
/// calculation before using this record.
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

  /// Manufacturer-rated current or configured setting, where applicable.
  final double? ratedCurrentA;

  final double? ratedOperationalVoltageV;
  final double? ratedInsulationVoltageV;
  final double? ratedImpulseWithstandVoltageKv;
  final int? poleCount;

  /// Icn, Icu or another declared breaking rating. Interpret only together
  /// with [breakingCapacityStandard] and the exact voltage/configuration.
  final double? breakingCapacityA;
  final String? breakingCapacityStandard;

  final ResidualCurrentDeviceType? residualCurrentType;
  final double? residualOperatingCurrentA;

  /// Declared selectivity limit for a specified upstream/downstream pair.
  /// It must not be treated as a universal property of this device alone.
  final double? selectivityLimitA;

  /// Optional time/current envelope, if transcribed from the cited document.
  final ProtectiveDeviceCurve? curve;

  final String? catalogueRevision;
  final List<String> standardReferences;
  final List<String>? configurationNotes;
  final ManufacturerDocumentReference document;

  /// Basic record integrity only; not an electrical suitability or compliance
  /// check. Calculation-specific validation remains mandatory.
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
      _optionalPositive(residualOperatingCurrentA) &&
      _optionalPositive(selectivityLimitA) &&
      (poleCount == null || poleCount! > 0);

  bool get hasBreakingCapacityData =>
      hasValidIdentityAndSource &&
      breakingCapacityA != null &&
      breakingCapacityStandard != null &&
      breakingCapacityStandard!.trim().isNotEmpty &&
      ratedOperationalVoltageV != null;

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

/// Catalogue metadata makes updates reviewable and avoids silently mixing
/// product data from different document revisions.
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
      RegExp(r'^\\d{4}-\\d{2}-\\d{2}$').hasMatch(updatedOn) &&
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
