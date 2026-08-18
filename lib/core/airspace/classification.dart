import '../../data/models/airspace/air_object.dart';

/// Responsible classification.
/// NEVER claim FIGHTER / DRONE / UAV without strong evidence.
/// Prefer UNKNOWN or AIRCRAFT — TYPE UNKNOWN.
class ClassificationEngine {
  /// Classify from available ADS-B fields only.
  /// OpenSky does not provide reliable military type.
  static AirCategory classifyFromAdsb({
    required String? callsign,
    required String? originCountry,
    required double? altitudeMeters,
    required double? speedKmh,
  }) {
    // OpenSky public data cannot reliably distinguish fighter / UAV.
    // We only mark as aircraft if we have basic identity.
    if (callsign != null && callsign.trim().isNotEmpty) {
      // Heuristic only for civilian helicopter-like speeds/altitudes is weak.
      // Prefer conservative AIRCRAFT.
      return AirCategory.aircraft;
    }

    // No callsign → UNKNOWN (safer than guessing UAV)
    return AirCategory.unknown;
  }

  /// If a future trusted sensor provides explicit UAV flag, use it.
  /// Currently no such source exists in the project → never force UAV.
  static AirCategory fromExplicitType(String? typeHint) {
    if (typeHint == null) return AirCategory.unknown;
    final t = typeHint.toUpperCase();
    if (t == 'UAV' || t == 'DRONE') {
      // Only accept if source is trusted (not implemented yet)
      return AirCategory.unknown; // conservative until real source exists
    }
    if (t == 'HELICOPTER' || t == 'HELI') return AirCategory.helicopter;
    if (t == 'AIRCRAFT' || t == 'PLANE') return AirCategory.aircraft;
    return AirCategory.unknown;
  }
}
