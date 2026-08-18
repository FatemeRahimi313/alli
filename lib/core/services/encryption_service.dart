import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Encryption key material lives only in Secure Storage.
/// Never hardcode keys or secrets.
class EncryptionService {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  enc.Key? _key;
  enc.IV? _iv;

  Future<void> init() async {
    String? keyB64 = await _secure.read(key: AppConstants.keyEncryptionKey);
    if (keyB64 == null || keyB64.isEmpty) {
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      keyB64 = base64Encode(keyBytes);
      await _secure.write(key: AppConstants.keyEncryptionKey, value: keyB64);
    }
    _key = enc.Key.fromBase64(keyB64);
    final ivBytes = sha256.convert(utf8.encode(keyB64)).bytes.sublist(0, 16);
    _iv = enc.IV(Uint8List.fromList(ivBytes));
  }

  String encrypt(String plain) {
    if (_key == null || _iv == null) {
      throw StateError('EncryptionService not initialized');
    }
    final encrypter = enc.Encrypter(enc.AES(_key!));
    return encrypter.encrypt(plain, iv: _iv!).base64;
  }

  String decrypt(String cipher) {
    if (_key == null || _iv == null) {
      throw StateError('EncryptionService not initialized');
    }
    final encrypter = enc.Encrypter(enc.AES(_key!));
    return encrypter.decrypt64(cipher, iv: _iv!);
  }

  static String hashPin(String pin, {String? salt}) {
    final effectiveSalt = salt ?? _generateSalt();
    final bytes = utf8.encode('$effectiveSalt:$pin');
    final digest = sha256.convert(bytes);
    return '$effectiveSalt:${digest.toString()}';
  }

  static bool verifyPin(String pin, String stored) {
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final expected = hashPin(pin, salt: salt);
    return expected == stored;
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }
}
