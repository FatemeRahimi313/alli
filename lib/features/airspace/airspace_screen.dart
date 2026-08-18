import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/airspace/airspace_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/airspace/air_object.dart';
import '../../data/models/airspace/airspace_status.dart';
import '../../core/providers.dart';
import 'object_detail_screen.dart';

class AirspaceScreen extends ConsumerStatefulWidget {
  const AirspaceScreen({super.key});

  @override
  ConsumerState<AirspaceScreen> createState() => _AirspaceScreenState();
}

class _AirspaceScreenState extends ConsumerState<AirspaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(airspaceObjectsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(airspaceSnapshotProvider);
    final objectsAsync = ref.watch(airspaceObjectsProvider);
    final settings = ref.watch(settingsProvider);
    final privacy = settings.privacyMode;

    return Scaffold(
      backgroundColor: AppColors.militaryBlack,
      appBar: AppBar(
        title: const Text('AIRSPACE', style: TextStyle(letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'بروزرسانی',
            onPressed: () => ref.read(airspaceObjectsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(airspaceObjectsProvider.notifier).refresh(),
        color: AppColors.militaryGreen,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _StatusCard(snapshot: snapshot),
            const SizedBox(height: AppSpacing.md),
            if (privacy)
              _PrivacyBanner()
            else if (settings.homeLat == null)
              _SetupBanner()
            else
              const SizedBox.shrink(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'OBJECTS',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.militaryGreen,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            objectsAsync.when(
              loading: () => const _LoadingState(),
              error: (e, _) => _ErrorState(
                message: e.toString().contains('RATE')
                    ? 'DATA SERVICE RATE LIMITED'
                    : 'DATA LINK ERROR',
                onRetry: () => ref.read(airspaceObjectsProvider.notifier).refresh(),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return _EmptyState(online: snapshot.dataLinkOnline);
                }
                return Column(
                  children: list
                      .map((obj) => _ObjectCard(
                            object: obj,
                            privacy: privacy,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ObjectDetailScreen(object: obj),
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final AirspaceSnapshot snapshot;
  const _StatusCard({required this.snapshot});

  Color _statusColor() {
    switch (snapshot.status) {
      case AirspaceOverallStatus.normal:
        return AppColors.militaryGreen;
      case AirspaceOverallStatus.watch:
        return Colors.amber;
      case AirspaceOverallStatus.caution:
        return Colors.orange;
      case AirspaceOverallStatus.alert:
        return AppColors.alertRed;
      case AirspaceOverallStatus.dataOffline:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'AIRSPACE STATUS',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.statusLabel,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (snapshot.message != null) ...[
            const SizedBox(height: 4),
            Text(
              snapshot.message!,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat('OBJECTS', '${snapshot.totalObjects}'),
              _Stat('KNOWN', '${snapshot.knownCount}'),
              _Stat('UNKNOWN', '${snapshot.unknownCount}'),
              _Stat('STALE', '${snapshot.staleCount}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                snapshot.dataLinkOnline ? Icons.link : Icons.link_off,
                size: 16,
                color: snapshot.dataLinkOnline ? AppColors.militaryGreen : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                snapshot.dataLinkOnline ? 'DATA LINK ONLINE' : 'DATA LINK OFFLINE',
                style: TextStyle(
                  color: snapshot.dataLinkOnline ? AppColors.militaryGreen : Colors.grey,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (snapshot.lastUpdate != null)
                Text(
                  _formatTime(snapshot.lastUpdate!),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.5)),
      ],
    );
  }
}

class _ObjectCard extends StatelessWidget {
  final AirObject object;
  final bool privacy;
  final VoidCallback onTap;
  const _ObjectCard({required this.object, required this.privacy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnknown = object.isUnknown;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isUnknown ? Icons.help_outline : Icons.flight,
                    color: isUnknown ? Colors.amber : AppColors.militaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUnknown
                          ? 'UNKNOWN OBJECT'
                          : (object.callsign ?? object.id.toUpperCase()),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isUnknown ? Colors.amber : AppColors.militaryGreen).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      object.identificationLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: isUnknown ? Colors.amber : AppColors.militaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _InfoChip('ALT', object.altitudeMeters != null
                      ? '${object.altitudeMeters!.toStringAsFixed(0)} m'
                      : '—'),
                  _InfoChip('SPD', object.speedKmh != null
                      ? '${object.speedKmh!.toStringAsFixed(0)} km/h'
                      : '—'),
                  _InfoChip('CONF', '${(object.confidence * 100).toStringAsFixed(0)}%'),
                  _InfoChip('SRC', object.source),
                ],
              ),
              if (!privacy && object.distanceKm != null) ...[
                const SizedBox(height: 6),
                Text(
                  'DIST ${object.distanceKm!.toStringAsFixed(1)} km  •  ${object.freshnessLabel}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            TextSpan(text: value, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.visibility_off, color: Colors.blue, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'PRIVACY MODE ACTIVE — USER LOCATION HIDDEN',
              style: TextStyle(color: Colors.blue, fontSize: 12, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Text(
        'موقعیت خانه در تنظیمات تعریف نشده. برای دریافت داده محدوده را تنظیم کنید.',
        style: TextStyle(color: Colors.amber, fontSize: 13),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator(color: AppColors.militaryGreen)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool online;
  const _EmptyState({required this.online});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(online ? Icons.flight_takeoff : Icons.cloud_off,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            online ? 'NO OBJECTS IN RANGE' : 'AIRSPACE DATA LINK OFFLINE',
            style: const TextStyle(color: AppColors.textSecondary, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.alertRed, size: 40),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.alertRed)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('تلاش مجدد')),
        ],
      ),
    );
  }
}
