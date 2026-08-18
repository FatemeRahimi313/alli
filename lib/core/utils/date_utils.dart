import 'package:shamsi_date/shamsi_date.dart';
import 'package:intl/intl.dart';

class ChelehDateUtils {
  /// تبدیل DateTime به رشته تاریخ شمسی (مثلاً ۱۴۰۵/۰۵/۲۷)
  static String toPersianDate(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  /// تاریخ امروز به صورت شمسی
  static String todayPersian() => toPersianDate(DateTime.now());

  /// ساعت فعلی به صورت HH:mm
  static String currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// محاسبه شماره روز چله بر اساس تاریخ شروع
  /// اگر startDate null باشد یا هنوز شروع نشده، ۱ برمی‌گرداند
  static int calculateCurrentDay(DateTime? startDate) {
    if (startDate == null) return 1;
    final now = DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(start).inDays + 1;
    if (diff < 1) return 1;
    if (diff > 40) return 40;
    return diff;
  }

  /// تاریخ مربوط به روز n چله
  static DateTime dateForDay(DateTime startDate, int dayNumber) {
    return DateTime(startDate.year, startDate.month, startDate.day)
        .add(Duration(days: dayNumber - 1));
  }

  /// درصد پیشرفت
  static double progressPercent(int completedDays) {
    if (completedDays <= 0) return 0;
    if (completedDays >= 40) return 100;
    return (completedDays / 40) * 100;
  }

  static String formatPersianDateLong(DateTime date) {
    final j = Jalali.fromDateTime(date);
    const months = [
      '', 'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    return '${j.day} ${months[j.month]} ${j.year}';
  }
}
