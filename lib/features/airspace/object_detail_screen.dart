import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/airspace/air_object.dart';

class ObjectDetailScreen extends StatelessWidget {
  final AirObject object;
  const ObjectDetailScreen({super.key, required this.object});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.militaryBlack,
      appBar: AppBar(
        title: Text(object.isUnknown ? 'UNKNOWN OBJECT' : (object.callsign ?? object.id)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Header(object: object),
          const SizedBox(height: AppSpacing.lg),
          _Section(title: 'IDENTIFICATION', children: [
            _Row('LEVEL', object.identificationLabel),
            _Row('CATEGORY', object.categoryLabel),
            _Row('CONFIDENCE', '${(object.confidence * 100).toStringAsFixed(0)}%  (${object.confidenceLabel})'),
            _Row('SOURCE', object.sources.join(', ')),
          ]),
          const SizedBox(height: AppSpacing.md),
          _Section(title: 'KINEMATICS', children: [
            _Row('ALTITUDE', object.altitudeMeters != null
                ? '${object.altitudeMeters!.toStringAsFixed(0)} m'
                : 'UNAVAILABLE'),
            _Row('SPEED', object.speedKmh != null
                ? '${object.speedKmh!.toStringAsFixed(0)} km/h'
                : 'UNAVAILABLE'),
            _Row('HEADING', object.headingDegrees != null
                ? '${object.headingDegrees!.toStringAsFixed(0)}°'
                : 'UNAVAILABLE'),
            _Row('DISTANCE', object.distanceKm != null
                ? '${object.distanceKm!.toStringAsFixed(1)} km'
                : 'HIDDEN / N/A'),
          ]),
          const SizedBox(height: AppSpacing.md),
          _Section(title: 'DATA QUALITY', children: [
            _Row('FRESHNESS', object.freshnessLabel),
            _Row('FIRST SEEN', _fmt(object.firstSeen)),
            _Row('LAST SEEN', _fmt(object.lastSeen)),
            _Row('UPDATES', '${object.updateCount}'),
            _Row('VALID', object.isValid ? 'YES' : 'NO'),
          ]),
          const SizedBox(height: AppSpacing.lg),
          if (object.identification == IdentificationLevel.unknown ||
              object.confidence < 0.5)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'IDENTIFICATION UNCERTAIN\nData is incomplete or confidence is low. Do not treat as confirmed identity.',
                style: TextStyle(color: Colors.amber, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
  }
}

class _Header extends StatelessWidget {
  final AirObject object;
  const _Header({required this.object});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(
            object.isUnknown ? Icons.help_outline : Icons.flight,
            size: 48,
            color: object.isUnknown ? Colors.amber : AppColors.militaryGreen,
          ),
          const SizedBox(height: 12),
          Text(
            object.id.toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          if (object.callsign != null)
            Text(object.callsign!, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.militaryGreen,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
