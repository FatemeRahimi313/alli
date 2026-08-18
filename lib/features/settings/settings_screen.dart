import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../core/services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = '${info.version}+${info.buildNumber}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        children: [
          _section('ظاهر'),
          SwitchListTile(
            title: const Text('حالت تاریک'),
            value: settings.themeMode == 'dark',
            activeColor: AppColors.militaryGreen,
            onChanged: (v) => notifier.setThemeMode(v ? 'dark' : 'light'),
          ),
          ListTile(
            title: const Text('زبان'),
            subtitle: Text(settings.locale == 'fa' ? 'فارسی' : 'English'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              notifier.setLocale(settings.locale == 'fa' ? 'en' : 'fa');
            },
          ),

          _section('امنیت'),
          SwitchListTile(
            title: const Text('قفل اپلیکیشن'),
            subtitle: const Text('نیاز به احراز هویت هنگام باز کردن'),
            value: settings.lockEnabled,
            activeColor: AppColors.militaryGreen,
            onChanged: (v) => notifier.setLockEnabled(v),
          ),
          SwitchListTile(
            title: const Text('بیومتریک'),
            subtitle: const Text('اثر انگشت / Face ID'),
            value: settings.biometricEnabled,
            activeColor: AppColors.militaryGreen,
            onChanged: settings.lockEnabled
                ? (v) => notifier.setBiometricEnabled(v)
                : null,
          ),

          _section('یادآورها'),
          SwitchListTile(
            title: const Text('نوتیفیکیشن روزانه'),
            value: settings.notificationsEnabled,
            activeColor: AppColors.militaryGreen,
            onChanged: (v) async {
              await notifier.setNotificationsEnabled(v);
              final notif = NotificationService();
              if (v) {
                final granted = await notif.requestPermission();
                if (granted) {
                  await notif.scheduleDailyReminder(
                    hour: settings.notificationHour,
                    minute: settings.notificationMinute,
                    title: 'چله‌بان',
                    body: 'وقت عبادت شبانه است. خدا قوت.',
                  );
                }
              } else {
                await notif.cancelAll();
              }
            },
          ),
          ListTile(
            title: const Text('ساعت یادآوری'),
            subtitle: Text(
              '${settings.notificationHour.toString().padLeft(2, '0')}:'
              '${settings.notificationMinute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.chevron_left),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: settings.notificationHour,
                  minute: settings.notificationMinute,
                ),
              );
              if (time != null) {
                await notifier.setNotificationTime(time.hour, time.minute);
                if (settings.notificationsEnabled) {
                  final notif = NotificationService();
                  await notif.scheduleDailyReminder(
                    hour: time.hour,
                    minute: time.minute,
                    title: 'چله‌بان',
                    body: 'وقت عبادت شبانه است. خدا قوت.',
                  );
                }
              }
            },
          ),

          _section('هشدار هوایی'),
          SwitchListTile(
            title: const Text('فعال‌سازی هشدار محدوده'),
            subtitle: const Text('بر اساس داده‌های عمومی ADS-B'),
            value: settings.alertsEnabled,
            activeColor: AppColors.militaryGreen,
            onChanged: (v) => notifier.setAlertsEnabled(v),
          ),
          if (settings.alertsEnabled)
            ListTile(
              title: const Text('شعاع محدوده (کیلومتر)'),
              subtitle: Text('${settings.alertRadiusKm.toStringAsFixed(0)} کیلومتر'),
              trailing: SizedBox(
                width: 120,
                child: Slider(
                  value: settings.alertRadiusKm,
                  min: 3,
                  max: 30,
                  divisions: 27,
                  label: settings.alertRadiusKm.toStringAsFixed(0),
                  activeColor: AppColors.militaryGreen,
                  onChanged: (v) => notifier.setAlertRadius(v),
                ),
              ),
            ),

          _section('داده'),
          ListTile(
            title: const Text('شروع مجدد چله'),
            subtitle: const Text('شمارش از امشب دوباره آغاز می‌شود'),
            leading: const Icon(Icons.restart_alt, color: AppColors.militaryGold),
            onTap: () async {
              final ok = await _confirm(context, 'آیا مطمئن هستید؟ تاریخ شروع به امروز تغییر می‌کند.');
              if (ok == true) {
                await notifier.setChelehStartDate(DateTime.now());
                ref.invalidate(currentDayNumberProvider);
                ref.invalidate(todayChelehProvider);
                ref.invalidate(progressProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('چله از امشب شروع شد.')),
                  );
                }
              }
            },
          ),
          ListTile(
            title: const Text('پاک کردن همه داده‌ها', style: TextStyle(color: AppColors.alertRed)),
            leading: const Icon(Icons.delete_forever, color: AppColors.alertRed),
            onTap: () async {
              final ok = await _confirm(
                context,
                'همه تیک‌ها، یادداشت‌ها و تنظیمات پاک می‌شوند. این عمل غیرقابل بازگشت است.',
              );
              if (ok == true) {
                await ref.read(storageServiceProvider).resetAllData();
                ref.invalidate(settingsProvider);
                ref.invalidate(todayChelehProvider);
                ref.invalidate(progressProvider);
                ref.invalidate(allDaysProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('همه داده‌ها پاک شدند.')),
                  );
                }
              }
            },
          ),

          _section('درباره'),
          ListTile(
            title: const Text('چله‌بان'),
            subtitle: Text('نسخه $_version\nاپلیکیشن شخصی پیگیری چله و آگاهی موقعیتی'),
            isThreeLine: true,
          ),
          const ListTile(
            title: Text('حریم خصوصی'),
            subtitle: Text(
              'همه داده‌ها فقط روی دستگاه شما ذخیره می‌شوند. '
              'موقعیت دقیق خانه به هیچ سروری ارسال نمی‌گردد. '
              'داده‌های هوایی از منابع عمومی (OpenSky) دریافت می‌شود.',
            ),
            isThreeLine: true,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.militaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Future<bool?> _confirm(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأیید'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('بله', style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
  }
}
