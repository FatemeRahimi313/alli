import 'package:flutter_test/flutter_test.dart';
import 'package:cheleban/core/airspace/airspace_engine.dart';
import 'package:cheleban/data/models/airspace/air_object.dart';
import 'package:cheleban/data/models/airspace/airspace_status.dart';

void main() {
  AirObject make({
    required String id,
    bool unknown = false,
    DataFreshness freshness = DataFreshness.live,
    bool valid = true,
  }) {
    return AirObject(
      id: id,
      source: 'ADS-B',
      timestamp: DateTime.now(),
      latitude: 35.7,
      longitude: 51.4,
      category: unknown ? AirCategory.unknown : AirCategory.aircraft,
      identification: unknown ? IdentificationLevel.unknown : IdentificationLevel.identified,
      confidence: unknown ? 0.2 : 0.9,
      freshness: freshness,
      status: AirObjectStatus.normal,
      firstSeen: DateTime.now(),
      lastSeen: DateTime.now(),
      isValid: valid,
    );
  }

  group('AirspaceEngine', () {
    test('empty list → normal', () {
      final snap = AirspaceEngine.evaluate([]);
      expect(snap.status, AirspaceOverallStatus.normal);
    });

    test('offline → dataOffline', () {
      final snap = AirspaceEngine.evaluate([], dataLinkOnline: false);
      expect(snap.status, AirspaceOverallStatus.dataOffline);
    });

    test('one unknown → watch', () {
      final snap = AirspaceEngine.evaluate([make(id: 'a', unknown: true)]);
      expect(snap.status, AirspaceOverallStatus.watch);
      expect(snap.unknownCount, 1);
    });

    test('multiple known → normal', () {
      final snap = AirspaceEngine.evaluate([
        make(id: 'a'),
        make(id: 'b'),
      ]);
      expect(snap.status, AirspaceOverallStatus.normal);
      expect(snap.knownCount, 2);
    });
  });
}
