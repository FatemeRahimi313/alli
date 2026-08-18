import 'package:flutter_test/flutter_test.dart';
import 'package:cheleban/core/utils/haversine.dart';

void main() {
  group('haversineDistanceKm', () {
    test('same point is zero', () {
      expect(haversineDistanceKm(35.0, 51.0, 35.0, 51.0), closeTo(0, 0.001));
    });

    test('known distance Tehran to approx 10km point', () {
      // roughly 0.09 deg lat ~ 10km
      final d = haversineDistanceKm(35.6892, 51.3890, 35.7792, 51.3890);
      expect(d, greaterThan(9));
      expect(d, lessThan(12));
    });
  });
}
