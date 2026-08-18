import '../../data/models/airspace/air_object.dart';

/// Strict validation before any data enters the Airspace system.
class AirspaceValidator {
  static const double minLat = -90.0;
  static const double maxLat = 90.0;
  static const double minLon = -180.0;
  static const double maxLon = 180.0;
  static const double maxAltitudeMeters = 25000.0; // realistic upper bound
  static const double minAltitudeMeters = -500.0;
  static const double maxSpeedKmh = 3000.0;
  static const double minSpeedKmh = 0.0;

  /// Returns null if valid, otherwise reason string.
  static String? validateRaw({
    required double? lat,
    required double? lon,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
  }) {
    if (lat == null || lon == null) {
      return 'MISSING_COORDINATES';
    }
    if (lat < minLat || lat > maxLat || lon < minLon || lon > maxLon) {
      return 'INVALID_COORDINATES';
    }
    if (altitude != null &&
        (altitude < minAltitudeMeters || altitude > maxAltitudeMeters)) {
      return 'INVALID_ALTITUDE';
    }
    if (speed != null && (speed < minSpeedKmh || speed > maxSpeedKmh)) {
      return 'INVALID_SPEED';
    }
    if (heading != null && (heading < 0 || heading > 360)) {
      return 'INVALID_HEADING';
    }
    if (timestamp != null) {
      final age = DateTime.now().difference(timestamp);
      if (age.isNegative || age.inHours > 24) {
        return 'INVALID_TIMESTAMP';
      }
    }
    return null;
  }

  static bool isValidObject(AirObject obj) {
    if (!obj.isValid) return false;
    final reason = validateRaw(
      lat: obj.latitude,
      lon: obj.longitude,
      altitude: obj.altitudeMeters,
      speed: obj.speedKmh,
      heading: obj.headingDegrees,
      timestamp: obj.timestamp,
    );
    return reason == null;
  }
}
