/// Overall Airspace situational status.
enum AirspaceOverallStatus {
  normal,
  watch,
  caution,
  alert,
  dataOffline,
}

class AirspaceSnapshot {
  final AirspaceOverallStatus status;
  final int totalObjects;
  final int knownCount;
  final int unknownCount;
  final int staleCount;
  final int invalidCount;
  final DateTime? lastUpdate;
  final bool dataLinkOnline;
  final String? message;

  const AirspaceSnapshot({
    required this.status,
    this.totalObjects = 0,
    this.knownCount = 0,
    this.unknownCount = 0,
    this.staleCount = 0,
    this.invalidCount = 0,
    this.lastUpdate,
    this.dataLinkOnline = false,
    this.message,
  });

  String get statusLabel {
    switch (status) {
      case AirspaceOverallStatus.normal:
        return 'NORMAL';
      case AirspaceOverallStatus.watch:
        return 'WATCH';
      case AirspaceOverallStatus.caution:
        return 'CAUTION';
      case AirspaceOverallStatus.alert:
        return 'ALERT';
      case AirspaceOverallStatus.dataOffline:
        return 'DATA OFFLINE';
    }
  }

  factory AirspaceSnapshot.offline({String? message}) => AirspaceSnapshot(
        status: AirspaceOverallStatus.dataOffline,
        dataLinkOnline: false,
        message: message ?? 'AIRSPACE DATA LINK OFFLINE',
      );

  factory AirspaceSnapshot.empty() => const AirspaceSnapshot(
        status: AirspaceOverallStatus.normal,
        dataLinkOnline: true,
        message: 'NO OBJECTS IN RANGE',
      );
}
