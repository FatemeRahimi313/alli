import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../core/errors/app_exception.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      if (settings.alertsEnabled) {
        ref.read(aircraftListProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final aircraftAsync = ref.watch(aircraftListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('هشدار هوایی'),
        actions: [
          if (settings.alertsEnabled)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(aircraftListProvider.notifier).refresh(),
            ),
        ],
      ),
      body: !settings.alertsEnabled
          ? _DisabledState(
              onEnable: () => ref.read(settingsProvider.notifier).setAlertsEnabled(true),
            )
          : settings.homeLat == null || settings.homeLon == null
              ? _NoLocationState(
                  onSet: () async {
                    // برای سادگی: مختصات نمونه تهران (کاربر باید در نسخه واقعی موقعیت واقعی بدهد)
                    // در production باید از geolocator استفاده شود.
                    await ref.read(settingsProvider.notifier).setHomeLocation(35.6892, 51.3890);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'موقعیت نمونه تنظیم شد. در نسخه نهایی از موقعیت واقعی دستگاه استفاده کنید.',
                          ),
                        ),
                      );
                    }
                  },
                )
              : aircraftAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 64, color: AppColors.alertGreen),
                            const SizedBox(height: 16),
                            Text(
                              'هیچ هواپیمایی در شعاع ${settings.alertRadiusKm.toStringAsFixed(0)} کیلومتری نیست',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton.icon(
                              onPressed: () => ref.read(aircraftListProvider.notifier).refresh(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('بروزرسانی'),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final a = list[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: a.isUnknown
                                  ? AppColors.alertYellow.withOpacity(0.3)
                                  : AppColors.militaryGreen.withOpacity(0.3),
                              child: Icon(
                                Icons.flight,
                                color: a.isUnknown ? AppColors.alertYellow : AppColors.militaryGreen,
                              ),
                            ),
                            title: Text(
                              a.callsign?.isNotEmpty == true ? a.callsign! : 'ناشناس (${a.icao24})',
                            ),
                            subtitle: Text(
                              '${a.distanceKm.toStringAsFixed(1)} کیلومتر'
                              '${a.altitude != null ? ' • ارتفاع ${a.altitude!.toStringAsFixed(0)} متر' : ''}'
                              '${a.originCountry != null ? ' • ${a.originCountry}' : ''}',
                            ),
                            trailing: Text(
                              '${a.detectedAt.hour.toString().padLeft(2, '0')}:${a.detectedAt.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.militaryGreen),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off, size: 48, color: AppColors.alertRed),
                          const SizedBox(height: 12),
                          Text(
                            userFriendlyMessage(e),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(aircraftListProvider.notifier).refresh(),
                            child: const Text('تلاش مجدد'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _DisabledState extends StatelessWidget {
  final VoidCallback onEnable;
  const _DisabledState({required this.onEnable});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'هشدار هوایی غیرفعال است',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'با فعال‌سازی، ورود هواپیما به محدوده تعریف‌شده به شما اعلام می‌شود.\n'
              'فقط از داده‌های عمومی استفاده می‌شود.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onEnable, child: const Text('فعال‌سازی')),
          ],
        ),
      ),
    );
  }
}

class _NoLocationState extends StatelessWidget {
  final VoidCallback onSet;
  const _NoLocationState({required this.onSet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'موقعیت خانه تنظیم نشده',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'برای محاسبه محدوده، موقعیت تقریبی خانه لازم است.\n'
              'این مختصات فقط روی دستگاه ذخیره می‌شود.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onSet, child: const Text('تنظیم موقعیت نمونه')),
          ],
        ),
      ),
    );
  }
}
