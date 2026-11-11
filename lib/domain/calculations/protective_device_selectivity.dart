import 'dart:math' as math;

/// One point from a manufacturer time/current curve envelope.
///
/// For the downstream device, maximumTimeS must represent total clearing time.
/// For the upstream device, minimumTimeS must represent the minimum
/// non-tripping / operating boundary relevant to the manufacturer's study.
class ProtectiveCurvePoint {
  const ProtectiveCurvePoint({
    required this.currentA,
    required this.minimumTimeS,
    required this.maximumTimeS,
  });

  final double currentA;
  final double minimumTimeS;
  final double maximumTimeS;
}

/// Manufacturer-derived envelope for one specific protective-device model,
/// setting, voltage and configuration. Points must be supplied in ascending
/// current order and must cover the evaluated fault current.
class ProtectiveDeviceCurve {
  const ProtectiveDeviceCurve({
    required this.deviceReference,
    required this.points,
  });

  final String deviceReference;
  final List<ProtectiveCurvePoint> points;
}

enum SelectivityStatus {
  selectiveAtEvaluatedCurrent,
  notSelectiveAtEvaluatedCurrent,
  insufficientCurveData,
}

/// Point check of time selectivity for a downstream/upstream device pair.
///
/// This does not prove total selectivity over the whole installation fault
/// range. The supplied curve envelopes and selectivity limit must match the
/// exact manufacturer references, settings, voltage and device combination.
class ProtectiveDeviceSelectivityCheck {
  const ProtectiveDeviceSelectivityCheck({
    required this.prospectiveFaultCurrentA,
    required this.downstreamTotalClearingCurve,
    required this.upstreamMinimumNonTrippingCurve,
    required this.manufacturerSelectivityLimitA,
    this.requiredTimeMarginS = 0,
  });

  final double prospectiveFaultCurrentA;

  /// Downstream device's maximum total clearing-time envelope.
  final ProtectiveDeviceCurve downstreamTotalClearingCurve;

  /// Upstream device's minimum non-tripping-time envelope.
  final ProtectiveDeviceCurve upstreamMinimumNonTrippingCurve;

  /// Manufacturer-declared selectivity limit for this exact device pair.
  final double manufacturerSelectivityLimitA;

  /// Additional design margin, if required by the project specification.
  final double requiredTimeMarginS;

  ProtectiveDeviceSelectivityResult evaluate() {
    _positive(prospectiveFaultCurrentA, 'prospectiveFaultCurrentA');
    _positive(manufacturerSelectivityLimitA, 'manufacturerSelectivityLimitA');
    if (!requiredTimeMarginS.isFinite || requiredTimeMarginS < 0) {
      throw ArgumentError.value(
        requiredTimeMarginS,
        'requiredTimeMarginS',
        'Time margin must be finite and non-negative.',
      );
    }
    _validateCurve(downstreamTotalClearingCurve, 'downstream');
    _validateCurve(upstreamMinimumNonTrippingCurve, 'upstream');

    if (prospectiveFaultCurrentA > manufacturerSelectivityLimitA) {
      return ProtectiveDeviceSelectivityResult(
        status: SelectivityStatus.notSelectiveAtEvaluatedCurrent,
        downstreamMaximumClearingTimeS: null,
        upstreamMinimumNonTrippingTimeS: null,
        availableTimeSeparationS: null,
        explanation:
            'Fault current exceeds the manufacturer-declared selectivity limit.',
      );
    }

    final downstreamTime = _interpolate(
      downstreamTotalClearingCurve.points,
      prospectiveFaultCurrentA,
      useMaximum: true,
    );
    final upstreamTime = _interpolate(
      upstreamMinimumNonTrippingCurve.points,
      prospectiveFaultCurrentA,
      useMaximum: false,
    );

    if (downstreamTime == null || upstreamTime == null) {
      return const ProtectiveDeviceSelectivityResult(
        status: SelectivityStatus.insufficientCurveData,
        downstreamMaximumClearingTimeS: null,
        upstreamMinimumNonTrippingTimeS: null,
        availableTimeSeparationS: null,
        explanation:
            'The fault current is outside one or both supplied curve ranges.',
      );
    }

    final separation = upstreamTime - downstreamTime;
    final selective = separation >= requiredTimeMarginS &&
        downstreamTime < upstreamTime;

    return ProtectiveDeviceSelectivityResult(
      status: selective
          ? SelectivityStatus.selectiveAtEvaluatedCurrent
          : SelectivityStatus.notSelectiveAtEvaluatedCurrent,
      downstreamMaximumClearingTimeS: downstreamTime,
      upstreamMinimumNonTrippingTimeS: upstreamTime,
      availableTimeSeparationS: separation,
      explanation: selective
          ? 'The supplied curve envelopes satisfy the time margin at this fault current.'
          : 'The supplied curve envelopes do not provide the required time separation.',
    );
  }

  static double? _interpolate(
    List<ProtectiveCurvePoint> points,
    double currentA, {
    required bool useMaximum,
  }) {
    if (currentA < points.first.currentA ||
        currentA > points.last.currentA) {
      return null;
    }

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      if (currentA == point.currentA) {
        return useMaximum ? point.maximumTimeS : point.minimumTimeS;
      }
      if (i == points.length - 1) break;

      final next = points[i + 1];
      if (currentA > point.currentA && currentA < next.currentA) {
        final y1 = useMaximum ? point.maximumTimeS : point.minimumTimeS;
        final y2 = useMaximum ? next.maximumTimeS : next.minimumTimeS;
        // Manufacturer time/current curves are commonly represented on
        // logarithmic axes; interpolate linearly in log-log space.
        final fraction = (math.log(currentA) - math.log(point.currentA)) /
            (math.log(next.currentA) - math.log(point.currentA));
        return math.exp(
          math.log(y1) + fraction * (math.log(y2) - math.log(y1)),
        );
      }
    }
    return null;
  }

  static void _validateCurve(ProtectiveDeviceCurve curve, String label) {
    if (curve.deviceReference.trim().isEmpty) {
      throw ArgumentError.value(
        curve.deviceReference,
        '$label.deviceReference',
        'A manufacturer/device reference is required.',
      );
    }
    if (curve.points.length < 2) {
      throw ArgumentError.value(
        curve.points,
        '$label.points',
        'At least two curve points are required.',
      );
    }
    var previousCurrent = 0.0;
    for (final point in curve.points) {
      _positive(point.currentA, '$label.currentA');
      _positive(point.minimumTimeS, '$label.minimumTimeS');
      _positive(point.maximumTimeS, '$label.maximumTimeS');
      if (point.currentA <= previousCurrent) {
        throw ArgumentError(
          '$label curve points must have strictly increasing current.',
        );
      }
      if (point.minimumTimeS > point.maximumTimeS) {
        throw ArgumentError(
          '$label minimum time cannot exceed maximum time.',
        );
      }
      previousCurrent = point.currentA;
    }
  }

  static void _positive(double value, String name) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(value, name, 'Must be finite and positive.');
    }
  }
}

class ProtectiveDeviceSelectivityResult {
  const ProtectiveDeviceSelectivityResult({
    required this.status,
    required this.downstreamMaximumClearingTimeS,
    required this.upstreamMinimumNonTrippingTimeS,
    required this.availableTimeSeparationS,
    required this.explanation,
  });

  final SelectivityStatus status;
  final double? downstreamMaximumClearingTimeS;
  final double? upstreamMinimumNonTrippingTimeS;
  final double? availableTimeSeparationS;
  final String explanation;

  bool get isSelectiveAtEvaluatedCurrent =>
      status == SelectivityStatus.selectiveAtEvaluatedCurrent;
}
