import 'package:flutter_test/flutter_test.dart';
import 'package:cheleban/core/services/encryption_service.dart';

void main() {
  group('EncryptionService PIN hashing', () {
    test('hashPin produces different hashes for different pins', () {
      final h1 = EncryptionService.hashPin('1234');
      final h2 = EncryptionService.hashPin('5678');
      expect(h1, isNot(equals(h2)));
    });

    test('verifyPin succeeds for correct pin', () {
      final stored = EncryptionService.hashPin('123456');
      expect(EncryptionService.verifyPin('123456', stored), isTrue);
    });

    test('verifyPin fails for wrong pin', () {
      final stored = EncryptionService.hashPin('123456');
      expect(EncryptionService.verifyPin('000000', stored), isFalse);
    });

    test('same pin with same salt produces same hash', () {
      final stored = EncryptionService.hashPin('9999', salt: 'testsalt');
      final again = EncryptionService.hashPin('9999', salt: 'testsalt');
      expect(stored, equals(again));
    });
  });
}
