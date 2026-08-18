import '../../data/models/airspace/air_object.dart';

class FreshnessEngine {
  /// Configurable thresholds (seconds)
  static const int liveThresholdSec = 15;
  static const int recentThresholdSec = 60;

  static DataFreshness fromTimestamp(DateTime timestamp, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final age = n.difference(timestamp);
    if (age.isNegative) return DataFreshness.stale;
    if (age.inSeconds <= liveThresholdSec) return DataFreshness.live;
    if (age.inSeconds <= recentThresholdSec) return DataFreshness.recent;
    return DataFreshness.stale;
  }
}
