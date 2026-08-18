import 'package:flutter_test/flutter_test.dart';
import 'package:cheleban/core/airspace/confidence.dart';
import 'package:cheleban/data/models/airspace/air_object.dart';

void main() {
  group('ConfidenceEngine', () {
    test('high confidence with full ADS-B data', () {
      final c = ConfidenceEngine.calculate(
        source: 'ADS-B',
        hasCallsign: true,
        hasAltitude: true,
        hasSpeed: true,
        hasHeading: true,
        freshness: DataFreshness.live,
        hasValidId: true,
      );
      expect(c, greaterThan(0.75));
    });

    test('low confidence without identity and stale', () {
      final c = ConfidenceEngine.calculate(
        source: 'UNKNOWN',
        hasCallsign: false,
        hasAltitude: false,
        hasSpeed: false,
        hasHeading: false,
        freshness: DataFreshness.stale,
        hasValidId: false,
      );
      expect(c, lessThan(0.30));
    });

    test('level becomes dataStale when freshness is stale', () {
      final level = ConfidenceEngine.levelFromConfidence(
        0.9,
        hasIdentity: true,
        freshness: DataFreshness.stale,
      );
      expect(level, IdentificationLevel.dataStale);
    });

    test('level becomes unknown with low confidence', () {
      final level = ConfidenceEngine.levelFromConfidence(
        0.2,
        hasIdentity: false,
        freshness: DataFreshness.live,
      );
      expect(level, IdentificationLevel.unknown);
    });
  });
}
