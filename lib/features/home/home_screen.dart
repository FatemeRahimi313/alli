import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../core/utils/date_utils.dart';
import '../../core/errors/app_exception.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayAsync = ref.watch(todayChelehProvider);
    final progress = ref.watch(progressProvider);
    final dayNum = ref.watch(currentDayNumberProvider);
    final settings = ref.watch(settingsProvider);
    final aircraftAsync = ref.watch(aircraftListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.militaryGreen,
          onRefresh: () async {
            await ref.read(todayChelehProvider.notifier).refresh();
            if (settings.alertsEnabled) {
              await ref.read(aircraftListProvider.notifier).refresh();
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Time & Date
              _TimeHeader(),
              const SizedBox(height: AppSpacing.md),

              // Day counter + progress
              _ProgressCard(
                dayNumber: dayNum,
                completed: progress.completed,
                percent: progress.percent,
              ),
              const SizedBox(height: AppSpacing.md),

              // Alert status
              if (settings.alertsEnabled)
                _AlertStatusBanner(aircraftAsync: aircraftAsync),

              const SizedBox(height: AppSpacing.lg),

              // Three big toggles
              dayAsync.when(
                data: (day) => Column(
                  children: [
                    _BigToggle(
                      title: 'نماز شب',
                      icon: Icons.nightlight_round,
                      value: day.namazShab,
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        ref.read(todayChelehProvider.notifier).toggleNamaz(v);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _BigToggle(
                      title: 'زیارت عاشورا',
                      icon: Icons.menu_book_rounded,
                      value: day.ziyaratAshura,
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        ref.read(todayChelehProvider.notifier).toggleZiyarat(v);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _BigToggle(
                      title: 'دعای توسل',
                      icon: Icons.favorite_border,
                      value: day.doayeTavassol,
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        ref.read(todayChelehProvider.notifier).toggleTavassol(v);
                      },
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.militaryGreen),
                  ),
                ),
                error: (e, _) => _ErrorCard(
                  message: userFriendlyMessage(e),
                  onRetry: () => ref.read(todayChelehProvider.notifier).refresh(),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Start cheleh CTA if not started
              if (settings.chelehStartDate == null)
                _StartChelehCard(
                  onStart: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .setChelehStartDate(DateTime.now());
                    ref.invalidate(currentDayNumberProvider);
                    ref.read(todayChelehProvider.notifier).refresh();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 30)),
      builder: (context, _) {
        return Column(
          children: [
            Text(
              ChelehDateUtils.currentTime(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Text(
              ChelehDateUtils.todayPersian(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int dayNumber;
  final int completed;
  final double percent;

  const _ProgressCard({
    required this.dayNumber,
    required this.completed,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              'شب $dayNumber از ۴۰',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.militaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 10,
                backgroundColor: AppColors.militaryGray,
                color: AppColors.militaryGreen,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$completed / ۴۰ کامل شده  (${percent.toStringAsFixed(0)}٪)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertStatusBanner extends StatelessWidget {
  final AsyncValue aircraftAsync;

  const _AlertStatusBanner({required this.aircraftAsync});

  @override
  Widget build(BuildContext context) {
    return aircraftAsync.when(
      data: (list) {
        final hasAircraft = (list as List).isNotEmpty;
        final color = hasAircraft ? AppColors.alertYellow : AppColors.alertGreen;
        final text = hasAircraft
            ? 'هواپیما در محدوده: ${list.length} مورد'
            : 'محدوده امن';
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.radar, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(color: AppColors.militaryGreen),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.alertRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          userFriendlyMessage(e),
          style: const TextStyle(color: AppColors.alertRed),
        ),
      ),
    );
  }
}

class _BigToggle extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BigToggle({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: value ? AppColors.militaryDarkGreen : AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: value ? AppColors.militaryGreen : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                value ? Icons.check_circle : icon,
                color: value ? AppColors.militaryGreen : AppColors.textMuted,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: value ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.militaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('تلاش مجدد')),
          ],
        ),
      ),
    );
  }
}

class _StartChelehCard extends StatelessWidget {
  final VoidCallback onStart;

  const _StartChelehCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.militaryDarkGreen.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Icon(Icons.flag, color: AppColors.militaryGold, size: 40),
            const SizedBox(height: 12),
            const Text(
              'چله‌ات هنوز شروع نشده',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'با شروع چله، شمارش ۴۰ شب آغاز می‌شود.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onStart,
              child: const Text('شروع چله از امشب'),
            ),
          ],
        ),
      ),
    );
  }
}
