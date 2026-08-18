class AppConstants {
  static const String appName = 'چله‌بان';
  static const String appNameEn = 'Cheleban';
  static const int totalChelehDays = 40;
  static const String hiveBoxCheleh = 'cheleh_days';
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxAlerts = 'aircraft_alerts';
  static const String hiveBoxJournal = 'journal_entries';

  // Secure storage keys
  static const String keyPinHash = 'app_pin_hash';
  static const String keyLockEnabled = 'lock_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyStealthMode = 'stealth_mode';
  static const String keyEncryptionKey = 'encryption_key';

  // Settings keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyNotificationHour = 'notification_hour';
  static const String keyNotificationMinute = 'notification_minute';
  static const String keyChelehStartDate = 'cheleh_start_date';
  static const String keyAlertsEnabled = 'alerts_enabled';
  static const String keyHomeLat = 'home_lat';
  static const String keyHomeLon = 'home_lon';
  static const String keyAlertRadiusKm = 'alert_radius_km';

  // Defaults
  static const int defaultNotificationHour = 4; // before fajr-ish
  static const int defaultNotificationMinute = 0;
  static const double defaultAlertRadiusKm = 10.0;
  static const int autoLockSeconds = 60;
}
