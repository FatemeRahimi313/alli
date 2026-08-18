import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/cheleh_day.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/aircraft_info.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

class StorageService {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  late Box _chelehBox;
  late Box _settingsBox;
  late Box _alertsBox;
  late SharedPreferences _prefs;

  Future<void> init() async {
    await Hive.initFlutter();
    _chelehBox = await Hive.openBox(AppConstants.hiveBoxCheleh);
    _settingsBox = await Hive.openBox(AppConstants.hiveBoxSettings);
    _alertsBox = await Hive.openBox(AppConstants.hiveBoxAlerts);
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Cheleh Days ───────────────────────────────────────

  Future<void> saveDay(ChelehDay day) async {
    try {
      await _chelehBox.put(day.dayNumber, day.toJson());
    } catch (e) {
      throw const StorageException('ذخیره روز چله ناموفق بود.');
    }
  }

  ChelehDay? getDay(int dayNumber) {
    final data = _chelehBox.get(dayNumber);
    if (data == null) return null;
    try {
      return ChelehDay.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  List<ChelehDay> getAllDays() {
    final list = <ChelehDay>[];
    for (final key in _chelehBox.keys) {
      final data = _chelehBox.get(key);
      if (data != null) {
        try {
          list.add(ChelehDay.fromJson(Map<String, dynamic>.from(data as Map)));
        } catch (_) {}
      }
    }
    list.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return list;
  }

  int countCompletedDays() {
    return getAllDays().where((d) => d.isComplete).length;
  }

  Future<void> clearAllDays() async {
    await _chelehBox.clear();
  }

  // ─── Settings ──────────────────────────────────────────

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('app_settings', settings.toJson());
  }

  AppSettings getSettings() {
    final data = _settingsBox.get('app_settings');
    if (data == null) return const AppSettings();
    try {
      return AppSettings.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return const AppSettings();
    }
  }

  // ─── Secure ────────────────────────────────────────────

  Future<void> writeSecure(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return _secure.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _secure.delete(key: key);
  }

  // ─── Alerts history ────────────────────────────────────

  Future<void> saveAlert(AircraftInfo info) async {
    final list = getAlertHistory();
    list.insert(0, info);
    // keep last 50
    final trimmed = list.take(50).toList();
    await _alertsBox.put(
      'history',
      trimmed.map((e) => e.toJson()).toList(),
    );
  }

  List<AircraftInfo> getAlertHistory() {
    final data = _alertsBox.get('history');
    if (data == null) return [];
    try {
      final list = (data as List)
          .map((e) => AircraftInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> clearAlerts() async {
    await _alertsBox.clear();
  }

  // ─── Reset ─────────────────────────────────────────────

  Future<void> resetAllData() async {
    await _chelehBox.clear();
    await _alertsBox.clear();
    await _settingsBox.clear();
    await _secure.deleteAll();
  }
}
