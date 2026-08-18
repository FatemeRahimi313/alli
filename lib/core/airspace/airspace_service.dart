import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../../data/models/airspace/air_object.dart';
import '../../data/models/airspace/airspace_status.dart';
import '../utils/haversine.dart';
import '../errors/app_exception.dart';
import 'validation.dart';
import 'confidence.dart';
import 'classification.dart';
import 'freshness.dart';
import 'airspace_engine.dart';

/// Full Airspace pipeline:
/// ADS-B → Normalize → Validate → Classify → Confidence → Freshness → Engine
class AirspaceService {
  static const _baseUrl = 'https://opensky-network.org/api/states/all';
  static const _timeout = Duration(seconds: 12);
  static const _minInterval = Duration(seconds: 8); // rate limit friendly

  DateTime? _lastFetch;
  final Map<String, AirObject> _history = {}; // local track by id

  /// Fetch + process nearby objects. Returns validated AirObjects only.
  Future<List<AirObject>> fetchNearby({
    required double centerLat,
    required double centerLon,
    required double radiusKm,
  }) async {
    // Simple rate limiting
    if (_lastFetch != null) {
      final elapsed = DateTime.now().difference(_lastFetch!);
      if (elapsed < _minInterval) {
        await Future.delayed(_minInterval - elapsed);
      }
    }

    final deltaLat = radiusKm / 111.0;
    final cosLat = math.cos(centerLat * math.pi / 180).abs().clamp(0.2, 1.0);
    final deltaLon = radiusKm / (111.0 * cosLat);

    final uri = Uri.parse(
      '$_baseUrl'
      '?lamin=${centerLat - deltaLat}'
      '&lomin=${centerLon - deltaLon}'
      '&lamax=${centerLat + deltaLat}'
      '&lomax=${centerLon + deltaLon}',
    );

    try {
      final response = await http.get(uri).timeout(_timeout);
      _lastFetch = DateTime.now();

      if (response.statusCode == 429) {
        throw const NetworkException('DATA SERVICE RATE LIMITED');
      }
      if (response.statusCode != 200) {
        throw NetworkException('پاسخ نامعتبر از سرویس هوایی (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final states = data['states'] as List? ?? [];
      final now = DateTime.now();
      final results = <AirObject>[];

      for (final s in states) {
        if (s == null || s is! List || s.length < 8) continue;

        final icao = s[0]?.toString() ?? '';
        if (icao.isEmpty) continue;

        final lon = s[5] != null ? (s[5] as num).toDouble() : null;
        final lat = s[6] != null ? (s[6] as num).toDouble() : null;
        final alt = s[7] != null ? (s[7] as num).toDouble() : null;
        final velocityMs = s.length > 9 && s[9] != null ? (s[9] as num).toDouble() : null;
        final heading = s.length > 10 && s[10] != null ? (s[10] as num).toDouble() : null;
        final callsign = s[1]?.toString().trim();
        final country = s[2]?.toString();

        // Validation gate
        final validationError = AirspaceValidator.validateRaw(
          lat: lat,
          lon: lon,
          altitude: alt,
          speed: velocityMs != null ? velocityMs * 3.6 : null,
          heading: heading,
          timestamp: now,
        );
        if (validationError != null) continue; // drop invalid

        final dist = haversineDistanceKm(centerLat, centerLon, lat!, lon!);
        if (dist > radiusKm) continue;

        final speedKmh = velocityMs != null ? velocityMs * 3.6 : null;
        final freshness = FreshnessEngine.fromTimestamp(now);
        final category = ClassificationEngine.classifyFromAdsb(
          callsign: callsign,
          originCountry: country,
          altitudeMeters: alt,
          speedKmh: speedKmh,
        );

        final confidence = ConfidenceEngine.calculate(
          source: 'ADS-B',
          hasCallsign: callsign != null && callsign.isNotEmpty,
          hasAltitude: alt != null,
          hasSpeed: speedKmh != null,
          hasHeading: heading != null,
          freshness: freshness,
          hasValidId: icao.isNotEmpty,
        );

        final identification = ConfidenceEngine.levelFromConfidence(
          confidence,
          hasIdentity: callsign != null && callsign.isNotEmpty,
          freshness: freshness,
        );

        // History / track
        final existing = _history[icao];
        final firstSeen = existing?.firstSeen ?? now;
        final updateCount = (existing?.updateCount ?? 0) + 1;

        final obj = AirObject(
          id: icao,
          source: 'ADS-B',
          timestamp: now,
          latitude: lat,
          longitude: lon,
          altitudeMeters: alt,
          speedKmh: speedKmh,
          headingDegrees: heading,
          category: category,
          identification: identification,
          confidence: confidence,
          freshness: freshness,
          status: AirObjectStatus.normal,
          callsign: callsign?.isEmpty == true ? null : callsign,
          originCountry: country,
          distanceKm: dist,
          firstSeen: firstSeen,
          lastSeen: now,
          updateCount: updateCount,
          sources: const ['ADS-B'],
          isValid: true,
        );

        _history[icao] = obj;
        results.add(obj);
      }

      results.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
      return results;
    } on TimeoutException {
      throw const NetworkException('زمان درخواست به پایان رسید.');
    } on http.ClientException {
      throw const NetworkException('اتصال شبکه برقرار نشد.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException();
    }
  }

  AirspaceSnapshot evaluate(List<AirObject> objects, {bool online = true}) {
    return AirspaceEngine.evaluate(objects, dataLinkOnline: online);
  }

  void clearHistory() {
    _history.clear();
  }

  List<AirObject> getHistorySnapshot() => _history.values.toList();
}
