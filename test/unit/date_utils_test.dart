import 'package:flutter_test/flutter_test.dart';
import 'package:cheleban/core/utils/date_utils.dart';

void main() {
  group('ChelehDateUtils', () {
    test('progress percent', () {
      expect(ChelehDateUtils.progressPercent(0), 0);
      expect(ChelehDateUtils.progressPercent(20), 50);
      expect(ChelehDateUtils.progressPercent(40), 100);
      expect(ChelehDateUtils.progressPercent(50), 100);
    });

    test('calculateCurrentDay without start', () {
      expect(ChelehDateUtils.calculateCurrentDay(null), 1);
    });

    test('calculateCurrentDay today', () {
      final today = DateTime.now();
      expect(ChelehDateUtils.calculateCurrentDay(today), 1);
    });

    test('calculateCurrentDay after 5 days', () {
      final start = DateTime.now().subtract(const Duration(days: 4));
      expect(ChelehDateUtils.calculateCurrentDay(start), 5);
    });
  });
}
