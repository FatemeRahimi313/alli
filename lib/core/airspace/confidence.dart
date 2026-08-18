import '../../data/models/airspace/air_object.dart';

/// Confidence is derived from real data quality, never random.
class ConfidenceEngine {
  /// Calculate 0.0–1.0 confidence from available fields and source.
  static double calculate({
    required String source,
    required bool hasCallsign,
    required bool hasAltitude,
    required bool hasSpeed,
    required bool hasHeading,
    required DataFreshness freshness,
    required bool hasValidId,
  }) {
    double score = 0.0;

    // Source reliability
    if (source == 'ADS-B') {
      score += 0.35;
    } else {
      score += 0.10;
    }

    if (hasValidId) score += 0.20;
    if (hasCallsign) score += 0.15;
    if (hasAltitude) score += 0.10;
    if (hasSpeed) score += 0.08;
    if (hasHeading) score += 0.07;

    // Freshness penalty
    switch (freshness) {
      case DataFreshness.live:
        score += 0.05;
        break;
      case DataFreshness.recent:
        break;
      case DataFreshness.stale:
        score -= 0.25;
        break;
      case DataFreshness.offline:
        score -= 0.40;
        break;
    }

    return score.clamp(0.0, 1.0);
  }

  static IdentificationLevel levelFromConfidence(
    double confidence, {
    required bool hasIdentity,
    required DataFreshness freshness,
  }) {
    if (freshness == DataFreshness.stale || freshness == DataFreshness.offline) {
      return IdentificationLevel.dataStale;
    }
    if (confidence >= 0.75 && hasIdentity) {
      return IdentificationLevel.identified;
    }
    if (confidence >= 0.40) {
      return IdentificationLevel.partiallyIdentified;
    }
    return IdentificationLevel.unknown;
  }
}
