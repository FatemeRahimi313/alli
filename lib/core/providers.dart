import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import '../data/models/cheleh_day.dart';
import '../data/models/aircraft_info.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/adsb_service.dart';
import 'services/notification_service.dart';
import 'utils/date_utils.dart';

// ─── Core Services ───────────────────────────────────────

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in main');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(storageServiceProvider));
});

final adsbServiceProvider = Provider<AdsbService>((ref) => AdsbService());

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ─── Settings ────────────────────────────────────────────

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(storageServiceProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(_storage.getSettings());

  Future<void> update(AppSettings Function(AppSettings) fn) async {
    final next = fn(state);
    await _storage.saveSettings(next);
    state = next;
  }

  Future<void> setThemeMode(String mode) =>
      update((s) => s.copyWith(themeMode: mode));

  Future<void> setLocale(String locale) =>
      update((s) => s.copyWith(locale: locale));

  Future<void> setNotificationsEnabled(bool v) =>
      update((s) => s.copyWith(notificationsEnabled: v));

  Future<void> setNotificationTime(int hour, int minute) =>
      update((s) => s.copyWith(notificationHour: hour, notificationMinute: minute));

  Future<void> setLockEnabled(bool v) =>
      update((s) => s.copyWith(lockEnabled: v));

  Future<void> setBiometricEnabled(bool v) =>
      update((s) => s.copyWith(biometricEnabled: v));

  Future<void> setAlertsEnabled(bool v) =>
  Future<void> setPrivacyMode(bool v) =>
      update((s) => s.copyWith(privacyMode: v));
      update((s) => s.copyWith(alertsEnabled: v));

  Future<void> setHomeLocation(double lat, double lon) =>
      update((s) => s.copyWith(homeLat: lat, homeLon: lon));

  Future<void> setAlertRadius(double km) =>
      update((s) => s.copyWith(alertRadiusKm: km));

  Future<void> setChelehStartDate(DateTime date) =>
      update((s) => s.copyWith(chelehStartDate: date));

  Future<void> setMissionMode(bool v) =>
      update((s) => s.copyWith(missionMode: v));
}

// ─── Current Day ─────────────────────────────────────────

final currentDayNumberProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  return ChelehDateUtils.calculateCurrentDay(settings.chelehStartDate);
});

final todayChelehProvider =
    StateNotifierProvider<TodayChelehNotifier, AsyncValue<ChelehDay>>((ref) {
  return TodayChelehNotifier(ref);
});

class TodayChelehNotifier extends StateNotifier<AsyncValue<ChelehDay>> {
  final Ref _ref;

  TodayChelehNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final storage = _ref.read(storageServiceProvider);
      final dayNum = _ref.read(currentDayNumberProvider);
      final settings = _ref.read(settingsProvider);
      var day = storage.getDay(dayNum);
      if (day == null) {
        final start = settings.chelehStartDate ?? DateTime.now();
        final date = ChelehDateUtils.dateForDay(start, dayNum);
        day = ChelehDay(
          dayNumber: dayNum,
          dateIso: date.toIso8601String().substring(0, 10),
        );
      }
      state = AsyncValue.data(day);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleNamaz(bool value) => _update((d) => d.copyWith(namazShab: value));
  Future<void> toggleZiyarat(bool value) => _update((d) => d.copyWith(ziyaratAshura: value));
  Future<void> toggleTavassol(bool value) => _update((d) => d.copyWith(doayeTavassol: value));

  Future<void> _update(ChelehDay Function(ChelehDay) fn) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = fn(current);
    final withComplete = updated.isComplete && updated.completedAt == null
        ? updated.copyWith(completedAt: DateTime.now())
        : updated;
    await _ref.read(storageServiceProvider).saveDay(withComplete);
    state = AsyncValue.data(withComplete);
    // invalidate progress
    _ref.invalidate(progressProvider);
  }

  Future<void> refresh() => _load();
}

// ─── Progress ────────────────────────────────────────────

final progressProvider = Provider<({int completed, int total, double percent})>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final completed = storage.countCompletedDays();
  return (
    completed: completed,
    total: 40,
    percent: ChelehDateUtils.progressPercent(completed),
  );
});

// ─── All days for calendar ───────────────────────────────

final allDaysProvider = FutureProvider<List<ChelehDay>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getAllDays();
});

// ─── ADS-B ───────────────────────────────────────────────

final aircraftListProvider =
    StateNotifierProvider<AircraftNotifier, AsyncValue<List<AircraftInfo>>>((ref) {
  return AircraftNotifier(ref);
});

class AircraftNotifier extends StateNotifier<AsyncValue<List<AircraftInfo>>> {
  final Ref _ref;
  AircraftNotifier(this._ref) : super(const AsyncValue.data([]));

  Future<void> refresh() async {
    final settings = _ref.read(settingsProvider);
    if (!settings.alertsEnabled ||
        settings.homeLat == null ||
        settings.homeLon == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(adsbServiceProvider).fetchNearby(
            centerLat: settings.homeLat!,
            centerLon: settings.homeLon!,
            radiusKm: settings.alertRadiusKm,
          );
      state = AsyncValue.data(list);

      // save first alert if any
      if (list.isNotEmpty) {
        await _ref.read(storageServiceProvider).saveAlert(list.first);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
