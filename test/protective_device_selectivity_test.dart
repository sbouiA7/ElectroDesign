import 'package:flutter_test/flutter_test.dart';
import 'package:electro_design/domain/calculations/protective_device_selectivity.dart';

void main() {
  ProtectiveDeviceCurve curve(
    String reference, {
    required double minAt100,
    required double maxAt100,
    required double minAt1000,
    required double maxAt1000,
  }) {
    return ProtectiveDeviceCurve(
      deviceReference: reference,
      points: const [
        ProtectiveCurvePoint(
          currentA: 100,
          minimumTimeS: minAt100,
          maximumTimeS: maxAt100,
        ),
        ProtectiveCurvePoint(
          currentA: 1000,
          minimumTimeS: minAt1000,
          maximumTimeS: maxAt1000,
        ),
      ],
    );
  }

  ProtectiveDeviceSelectivityCheck check({
    double faultCurrentA = 500,
    double selectivityLimitA = 1000,
    double marginS = 0,
    ProtectiveDeviceCurve? downstream,
    ProtectiveDeviceCurve? upstream,
  }) {
    return ProtectiveDeviceSelectivityCheck(
      prospectiveFaultCurrentA: faultCurrentA,
      downstreamTotalClearingCurve: downstream ??
          curve(
            'Downstream manufacturer ref',
            minAt100: 0.08,
            maxAt100: 0.12,
            minAt1000: 0.02,
            maxAt1000: 0.04,
          ),
      upstreamMinimumNonTrippingCurve: upstream ??
          curve(
            'Upstream manufacturer ref',
            minAt100: 0.5,
            maxAt100: 0.7,
            minAt1000: 0.2,
            maxAt1000: 0.3,
          ),
      manufacturerSelectivityLimitA: selectivityLimitA,
      requiredTimeMarginS: marginS,
    );
  }

  test('reports selectivity when upstream minimum time exceeds downstream clearing time', () {
    final result = check().evaluate();

    expect(result.status, SelectivityStatus.selectiveAtEvaluatedCurrent);
    expect(result.isSelectiveAtEvaluatedCurrent, isTrue);
    expect(result.downstreamMaximumClearingTimeS, isNotNull);
    expect(result.upstreamMinimumNonTrippingTimeS, isNotNull);
  });

  test('applies the required time margin', () {
    final result = check(marginS: 10).evaluate();

    expect(result.status, SelectivityStatus.notSelectiveAtEvaluatedCurrent);
  });

  test('rejects fault current above manufacturer selectivity limit', () {
    final result = check(
      faultCurrentA: 1500,
      selectivityLimitA: 1000,
    ).evaluate();

    expect(result.status, SelectivityStatus.notSelectiveAtEvaluatedCurrent);
    expect(result.downstreamMaximumClearingTimeS, isNull);
  });

  test('returns insufficient data outside curve range', () {
    final result = check(faultCurrentA: 50).evaluate();

    expect(result.status, SelectivityStatus.insufficientCurveData);
  });

  test('reports non-selectivity when time envelopes overlap', () {
    final result = check(
      upstream: curve(
        'Upstream manufacturer ref',
        minAt100: 0.05,
        maxAt100: 0.1,
        minAt1000: 0.01,
        maxAt1000: 0.02,
      ),
    ).evaluate();

    expect(result.status, SelectivityStatus.notSelectiveAtEvaluatedCurrent);
  });

  test('rejects unsorted curve points', () {
    final invalid = ProtectiveDeviceCurve(
      deviceReference: 'Invalid reference',
      points: [
        const ProtectiveCurvePoint(
          currentA: 1000,
          minimumTimeS: 0.1,
          maximumTimeS: 0.2,
        ),
        const ProtectiveCurvePoint(
          currentA: 100,
          minimumTimeS: 0.5,
          maximumTimeS: 0.7,
        ),
      ],
    );

    expect(
      () => check(downstream: invalid).evaluate(),
      throwsArgumentError,
    );
  });
}
