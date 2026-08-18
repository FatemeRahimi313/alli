import '../../data/models/airspace/air_object.dart';
import '../../data/models/airspace/airspace_status.dart';

/// Central Airspace Status Engine — pure logic, independent of UI.
class AirspaceEngine {
  static AirspaceSnapshot evaluate(List<AirObject> objects, {bool dataLinkOnline = true}) {
    if (!dataLinkOnline) {
      return AirspaceSnapshot.offline();
    }

    if (objects.isEmpty) {
      return AirspaceSnapshot.empty();
    }

    final known = objects.where((o) => !o.isUnknown && o.isValid).length;
    final unknown = objects.where((o) => o.isUnknown).length;
    final stale = objects.where((o) => o.freshness == DataFreshness.stale).length;
    final invalid = objects.where((o) => !o.isValid).length;

    final lastUpdate = objects
        .map((o) => o.lastSeen)
        .fold<DateTime?>(null, (prev, t) => prev == null || t.isAfter(prev) ? t : prev);

    AirspaceOverallStatus status;
    String? message;

    if (invalid > 0 && unknown == 0) {
      status = AirspaceOverallStatus.watch;
      message = 'INVALID DATA DETECTED';
    } else if (unknown >= 2 || (unknown >= 1 && stale >= 1)) {
      status = AirspaceOverallStatus.caution;
      message = 'UNKNOWN / STALE OBJECTS PRESENT';
    } else if (unknown == 1) {
      status = AirspaceOverallStatus.watch;
      message = 'ONE UNKNOWN OBJECT';
    } else if (stale > objects.length ~/ 2) {
      status = AirspaceOverallStatus.watch;
      message = 'MAJORITY DATA STALE';
    } else {
      status = AirspaceOverallStatus.normal;
      message = null;
    }

    // Never escalate to ALERT on weak evidence alone
    // ALERT reserved for future explicit high-confidence safety rules

    return AirspaceSnapshot(
      status: status,
      totalObjects: objects.length,
      knownCount: known,
      unknownCount: unknown,
      staleCount: stale,
      invalidCount: invalid,
      lastUpdate: lastUpdate,
      dataLinkOnline: true,
      message: message,
    );
  }
}
