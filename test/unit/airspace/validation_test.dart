import 'package:flutter_test/flutter_test.dart';
import 'package:cheleban/core/airspace/validation.dart';

void main() {
  group('AirspaceValidator', () {
    test('accepts valid coordinates', () {
      expect(
        AirspaceValidator.validateRaw(lat: 35.7, lon: 51.4),
        isNull,
      );
    });

    test('rejects missing coordinates', () {
      expect(
        AirspaceValidator.validateRaw(lat: null, lon: 51.4),
        equals('MISSING_COORDINATES'),
      );
    });

    test('rejects out-of-range latitude', () {
      expect(
        AirspaceValidator.validateRaw(lat: 95.0, lon: 51.4),
        equals('INVALID_COORDINATES'),
      );
    });

    test('rejects impossible altitude', () {
      expect(
        AirspaceValidator.validateRaw(lat: 35.7, lon: 51.4, altitude: 50000),
        equals('INVALID_ALTITUDE'),
      );
    });

    test('rejects negative speed', () {
      expect(
        AirspaceValidator.validateRaw(lat: 35.7, lon: 51.4, speed: -10),
        equals('INVALID_SPEED'),
      );
    });
  });
}
