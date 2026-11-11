import 'dart:convert';

import 'package:flutter/services.dart';

import 'protective_device_catalog.dart';

/// A manufacturer-declared breaking rating, kept separate because Icn, Ics
/// and Icu may apply to different standards and voltages for one product.
class ImportedBreakingCapacityRating {
  const ImportedBreakingCapacityRating({
    required this.rating,
    required this.currentA,
    required this.standard,
    required this.voltageV,
  });

  final String rating;
  final double currentA;
  final String? standard;
  final double? voltageV;

  bool get isQualified =>
      const {'icn', 'ics', 'icu'}.contains(rating.trim().toLowerCase()) &&
      currentA.isFinite &&
      currentA > 0 &&
      standard != null &&
      standard!.trim().isNotEmpty &&
      voltageV != null &&
      voltageV!.isFinite &&
      voltageV! > 0;
}

/// Parsed source record. It is deliberately not calculation-ready by default.
class ImportedProtectiveDeviceRecord {
  const ImportedProtectiveDeviceRecord({
    required this.manufacturer,
    required this.productReference,
    required this.productFamily,
    required this.category,
    required this.ratedCurrentA,
    required this.operationalVoltageV,
    required this.poleCount,
    required this.document,
    required this.standardReferences,
    required this.breakingRatings,
    required this.sourceStatus,
  });

  final String manufacturer;
  final String productReference;
  final String productFamily;
  final ProtectiveDeviceCategory category;
  final double? ratedCurrentA;
  final double? operationalVoltageV;
  final int? poleCount;
  final ManufacturerDocumentReference document;
  final List<String> standardReferences;
  final List<ImportedBreakingCapacityRating> breakingRatings;
  final String sourceStatus;

  bool get hasValidIdentity =>
      manufacturer.trim().isNotEmpty &&
      productReference.trim().isNotEmpty &&
      productFamily.trim().isNotEmpty &&
      ratedCurrentA != null &&
      ratedCurrentA!.isFinite &&
      ratedCurrentA! > 0 &&
      (poleCount == null || poleCount! > 0) &&
      document.hasTraceableSource &&
      document.pageReferences.isNotEmpty;

  /// Converts only a rating explicitly selected by its standard and voltage.
  /// No default is chosen, and unqualified claims (for example SOMEF's
  /// published 6 kA without standard/voltage) cannot enter calculations.
  ProtectiveDeviceCatalogEntry? toCatalogEntry({
    required String breakingStandard,
    required double breakingVoltageV,
  }) {
    if (!hasValidIdentity ||
        !breakingVoltageV.isFinite ||
        breakingVoltageV <= 0) {
      return null;
    }
    final matches = breakingRatings.where((rating) =>
        rating.isQualified &&
        rating.standard!.toLowerCase() == breakingStandard.toLowerCase() &&
        rating.voltageV == breakingVoltageV);
    if (matches.length != 1) return null;
    final rating = matches.single;
    return ProtectiveDeviceCatalogEntry(
      manufacturer: manufacturer,
      productReference: productReference,
      productFamily: productFamily,
      category: category,
      document: document,
      standardReferences: {
        ...standardReferences,
        if (rating.standard != null) rating.standard!,
      }.toList(growable: false),
      ratedCurrentA: ratedCurrentA,
      ratedOperationalVoltageV: operationalVoltageV,
      poleCount: poleCount,
      breakingCapacityA: rating.currentA,
      breakingCapacityRatingType: rating.rating.trim().toUpperCase(),
      breakingCapacityStandard: rating.standard,
      breakingCapacityVoltageV: rating.voltageV,
      catalogueRevision: document.documentRevision,
      configurationNotes: [
        'Imported from manufacturer source; review product configuration '
            'and applicable installation standard before use.',
      ],
    );
  }
}

/// Explicit adapter for the current ABB, Legrand, Hager and SOMEF source JSON
/// shapes. Unknown/malformed records fail closed instead of guessing units.
class ProtectiveDeviceCatalogImporter {
  const ProtectiveDeviceCatalogImporter();

  static const bundledAssetPaths = [
    'docs/catalogues/data/abb-s202muc-c2.json',
    'docs/catalogues/data/legrand-btdin60-fn881c16.json',
    'docs/catalogues/data/hager-mbn350a.json',
    'docs/catalogues/data/somef-801106cx20.json',
  ];

  /// Loads the checked-in source records from Flutter's asset bundle.
  /// Each record remains documentary until a qualified rating is selected.
  Future<List<ImportedProtectiveDeviceRecord>> loadBundledRecords({
    AssetBundle? bundle,
  }) async {
    final assetBundle = bundle ?? rootBundle;
    final records = <ImportedProtectiveDeviceRecord>[];
    for (final path in bundledAssetPaths) {
      records.add(parse(await assetBundle.loadString(path)));
    }
    return List.unmodifiable(records);
  }

  ImportedProtectiveDeviceRecord parse(String sourceJson) {
    final decoded = jsonDecode(sourceJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Catalogue source must be a JSON object.');
    }
    final source = _map(decoded['source_document'], 'source_document');
    final manufacturer = _string(decoded, 'manufacturer');
    final productReference = _string(decoded, 'product_reference');
    final family = _string(decoded, 'product_family');
    final category = _category(_string(decoded, 'category'));
    final ratedCurrent = _number(decoded['rated_current_A']);
    final poles = _integer(decoded['pole_count']);
    final operationalVoltage = _operationalVoltage(decoded);
    final evidence = source['evidence'];
    if (evidence is! List || evidence.isEmpty ||
        evidence.any((item) => item is! String || item.trim().isEmpty)) {
      throw const FormatException('Source evidence/pages are required.');
    }
    final sourceUrl = _string(source, 'source_url');
    final revision = (source['document_identifier'] ??
            source['document_revision'] ??
            'Unspecified revision')
        .toString();
    final document = ManufacturerDocumentReference(
      title: _string(source, 'title'),
      sourceUrl: sourceUrl,
      documentRevision: revision,
      language: _string(source, 'language'),
      retrievedOn: _string(source, 'retrieved_on'),
      publicationDate: (source['publication_or_update_date'] as String?),
      pageReferences: evidence.cast<String>(),
    );

    return ImportedProtectiveDeviceRecord(
      manufacturer: manufacturer,
      productReference: productReference,
      productFamily: family,
      category: category,
      ratedCurrentA: ratedCurrent,
      operationalVoltageV: operationalVoltage,
      poleCount: poles,
      document: document,
      standardReferences: _strings(decoded['standard_references']),
      breakingRatings: _breakingRatings(decoded['breaking_capacity']),
      sourceStatus: (decoded['calculation_use_status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> _map(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Missing or invalid $field object.');
  }

  String _string(Map<String, dynamic> map, String field) {
    final value = map[field];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    throw FormatException('Missing or invalid $field.');
  }

  double? _number(Object? value) {
    if (value is num && value.isFinite && value > 0) return value.toDouble();
    return null;
  }

  int? _integer(Object? value) {
    if (value is int && value > 0) return value;
    return null;
  }

  double? _operationalVoltage(Map<String, dynamic> map) {
    final value = map['rated_operational_voltage'];
    if (value is Map<String, dynamic>) return _number(value['value']);
    if (value is String) {
      final match = RegExp(r'^(\d+(?:\.\d+)?)\s*V\b').firstMatch(value);
      if (match != null) return double.tryParse(match.group(1)!);
    }
    return null;
  }

  List<String> _strings(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().map((s) => s.trim())
        .where((s) => s.isNotEmpty).toList(growable: false);
  }

  List<ImportedBreakingCapacityRating> _breakingRatings(Object? value) {
    final values = value is List ? value : [value];
    final ratings = <ImportedBreakingCapacityRating>[];
    for (final item in values) {
      if (item is! Map<String, dynamic>) continue;
      final current = _number(item['value']);
      if (current == null) continue;
      final voltageText = item['voltage_condition']?.toString() ?? '';
      final voltageMatch =
          RegExp(r'(\d+(?:\.\d+)?)\s*V\b').firstMatch(voltageText);
      final voltage = voltageMatch == null
          ? null
          : double.tryParse(voltageMatch.group(1)!);
      ratings.add(ImportedBreakingCapacityRating(
        rating: (item['rating'] ?? '').toString(),
        currentA: current,
        standard: item['standard'] is String
            ? item['standard'] as String
            : null,
        voltageV: voltage,
      ));
    }
    return ratings;
  }

  ProtectiveDeviceCategory _category(String value) {
    return ProtectiveDeviceCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => throw FormatException('Unsupported category: $value'),
    );
  }
}
