import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cheleh_day.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDaysAsync = ref.watch(allDaysProvider);
    final currentDay = ref.watch(currentDayNumberProvider);
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقویم چله'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(
                      label: 'کامل',
                      value: '${progress.completed}',
                      color: AppColors.alertGreen,
                    ),
                    _Stat(
                      label: 'باقی‌مانده',
                      value: '${40 - progress.completed}',
                      color: AppColors.militaryGold,
                    ),
                    _Stat(
                      label: 'پیشرفت',
                      value: '${progress.percent.toStringAsFixed(0)}٪',
                      color: AppColors.militaryGreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: allDaysAsync.when(
              data: (days) {
                final map = <int, ChelehDay>{
                  for (final day in days) day.dayNumber: day,
                };

                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 40,
                  itemBuilder: (context, index) {
                    final dayNum = index + 1;
                    final day = map[dayNum];

                    final isCurrent = dayNum == currentDay;

                    final isFuture =
                        settings.chelehStartDate != null &&
                        dayNum > currentDay;

                    Color background;
                    Color border;

                    if (day?.isComplete == true) {
                      background =
                          AppColors.alertGreen.withValues(alpha: 0.25);
                      border = AppColors.alertGreen;
                    } else if (day?.isPartial == true) {
                      background =
                          AppColors.alertYellow.withValues(alpha: 0.25);
                      border = AppColors.alertYellow;
                    } else if (isFuture) {
                      background =
                          AppColors.militaryGray.withValues(alpha: 0.3);
                      border = AppColors.divider;
                    } else {
                      background = AppColors.card;
                      border = AppColors.divider;
                    }

                    return GestureDetector(
                      onTap: () {
                        _showDayDetail(
                          context,
                          dayNum,
                          day,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(
                            AppRadius.sm,
                          ),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.militaryGold
                                : border,
                            width: isCurrent ? 2.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isCurrent
                                  ? AppColors.militaryGold
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.militaryGreen,
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'خطا در بارگذاری تقویم\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _Legend(
                  color: AppColors.alertGreen,
                  label: 'کامل',
                ),
                _Legend(
                  color: AppColors.alertYellow,
                  label: 'ناقص',
                ),
                _Legend(
                  color: AppColors.divider,
                  label: 'آینده',
                ),
                _Legend(
                  color: AppColors.militaryGold,
                  label: 'امروز',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetail(
    BuildContext context,
    int dayNum,
    ChelehDay? day,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شب $dayNum',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                if (day != null) ...[
                  const SizedBox(height: 12),
                  _DayRow(
                    label: 'نماز شب',
                    done: day.namazShab,
                  ),
                  _DayRow(
                    label: 'زیارت عاشورا',
                    done: day.ziyaratAshura,
                  ),
                  _DayRow(
                    label: 'دعای توسل',
                    done: day.doayeTavassol,
                  ),
                  if (day.note != null &&
                      day.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'یادداشت: ${day.note}',
                    ),
                  ],
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Text(
                      'هنوز ثبتی برای این شب وجود ندارد.',
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayRow extends StatelessWidget {
  final String label;
  final bool done;

  const _DayRow({
    required this.label,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle
                : Icons.circle_outlined,
            color: done
                ? AppColors.alertGreen
                : AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
