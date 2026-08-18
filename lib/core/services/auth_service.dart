import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import 'storage_service.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final StorageService _storage;

  AuthService(this._storage);

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> authenticate({String reason = 'برای ورود به چله‌بان احراز هویت کنید'}) async {
    try {
      final can = await canCheckBiometrics() || await isDeviceSupported();
      if (!can) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      throw const ValidationException('پین باید ۴ تا ۶ رقم باشد.');
    }
    final hash = _hashPin(pin);
    await _storage.writeSecure(AppConstants.keyPinHash, hash);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.readSecure(AppConstants.keyPinHash);
    if (stored == null) return false;
    return stored == _hashPin(pin);
  }

  Future<bool> hasPin() async {
    final stored = await _storage.readSecure(AppConstants.keyPinHash);
    return stored != null && stored.isNotEmpty;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin + 'cheleban_salt_v1');
    return sha256.convert(bytes).toString();
  }

  Future<bool> isLockEnabled() async {
    final settings = _storage.getSettings();
    return settings.lockEnabled;
  }
}
