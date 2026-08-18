class AppSettings {
  final bool lockEnabled;
  final bool biometricEnabled;
  final bool stealthMode;
  final bool privacyMode;
  final String themeMode; // system | light | dark
  final String locale; // fa | en
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationMinute;
  final DateTime? chelehStartDate;
  final bool alertsEnabled;
  final double? homeLat;
  final double? homeLon;
  final double alertRadiusKm;
  final bool missionMode;
  final int autoLockSeconds;

  const AppSettings({
    this.lockEnabled = true,
    this.biometricEnabled = true,
    this.stealthMode = false,
    this.privacyMode = false,
    this.themeMode = 'dark',
    this.locale = 'fa',
    this.notificationsEnabled = true,
    this.notificationHour = 4,
    this.notificationMinute = 0,
    this.chelehStartDate,
    this.alertsEnabled = false,
    this.homeLat,
    this.homeLon,
    this.alertRadiusKm = 10.0,
    this.missionMode = false,
    this.autoLockSeconds = 60,
  });

  AppSettings copyWith({
    bool? lockEnabled,
    bool? biometricEnabled,
    bool? stealthMode,
    bool? privacyMode,
    String? themeMode,
    String? locale,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
    DateTime? chelehStartDate,
    bool? alertsEnabled,
    double? homeLat,
    double? homeLon,
    double? alertRadiusKm,
    bool? missionMode,
    int? autoLockSeconds,
  }) {
    return AppSettings(
      lockEnabled: lockEnabled ?? this.lockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      stealthMode: stealthMode ?? this.stealthMode,
      privacyMode: privacyMode ?? this.privacyMode,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      chelehStartDate: chelehStartDate ?? this.chelehStartDate,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      homeLat: homeLat ?? this.homeLat,
      homeLon: homeLon ?? this.homeLon,
      alertRadiusKm: alertRadiusKm ?? this.alertRadiusKm,
      missionMode: missionMode ?? this.missionMode,
      autoLockSeconds: autoLockSeconds ?? this.autoLockSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'lockEnabled': lockEnabled,
        'biometricEnabled': biometricEnabled,
        'stealthMode': stealthMode,
        'privacyMode': privacyMode,
        'themeMode': themeMode,
        'locale': locale,
        'notificationsEnabled': notificationsEnabled,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
        'chelehStartDate': chelehStartDate?.toIso8601String(),
        'alertsEnabled': alertsEnabled,
        'homeLat': homeLat,
        'homeLon': homeLon,
        'alertRadiusKm': alertRadiusKm,
        'missionMode': missionMode,
        'autoLockSeconds': autoLockSeconds,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      lockEnabled: json['lockEnabled'] as bool? ?? true,
      biometricEnabled: json['biometricEnabled'] as bool? ?? true,
      stealthMode: json['stealthMode'] as bool? ?? false,
      privacyMode: json['privacyMode'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'dark',
      locale: json['locale'] as String? ?? 'fa',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationHour: json['notificationHour'] as int? ?? 4,
      notificationMinute: json['notificationMinute'] as int? ?? 0,
      chelehStartDate: json['chelehStartDate'] != null
          ? DateTime.tryParse(json['chelehStartDate'] as String)
          : null,
      alertsEnabled: json['alertsEnabled'] as bool? ?? false,
      homeLat: (json['homeLat'] as num?)?.toDouble(),
      homeLon: (json['homeLon'] as num?)?.toDouble(),
      alertRadiusKm: (json['alertRadiusKm'] as num?)?.toDouble() ?? 10.0,
      missionMode: json['missionMode'] as bool? ?? false,
      autoLockSeconds: json['autoLockSeconds'] as int? ?? 60,
    );
  }
}
