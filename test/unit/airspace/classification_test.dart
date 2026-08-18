import 'package:flutter_test/flutter_test.dart';
import 'package:cheleban/core/airspace/classification.dart';
import 'package:cheleban/data/models/airspace/air_object.dart';

void main() {
  group('ClassificationEngine', () {
    test('with callsign returns aircraft (never fighter)', () {
      final cat = ClassificationEngine.classifyFromAdsb(
        callsign: 'IRA123',
        originCountry: 'Iran',
        altitudeMeters: 10000,
        speedKmh: 800,
      );
      expect(cat, AirCategory.aircraft);
    });

    test('without callsign returns unknown (never uav guess)', () {
      final cat = ClassificationEngine.classifyFromAdsb(
        callsign: null,
        originCountry: null,
        altitudeMeters: 500,
        speedKmh: 120,
      );
      expect(cat, AirCategory.unknown);
    });

    test('explicit UAV hint still returns unknown until trusted source exists', () {
      final cat = ClassificationEngine.fromExplicitType('UAV');
      expect(cat, AirCategory.unknown);
    });
  });
}
