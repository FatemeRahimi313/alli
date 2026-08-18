import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../../data/models/aircraft_info.dart';
import '../utils/haversine.dart';
import '../errors/app_exception.dart';

class AdsbService {
  static const _baseUrl = 'https://opensky-network.org/api/states/all';
  static const _timeout = Duration(seconds: 12);

  /// دریافت هواپیماهای داخل محدوده. فقط داده‌های عمومی OpenSky.
  Future<List<AircraftInfo>> fetchNearby({
    required double centerLat,
    required double centerLon,
    required double radiusKm,
  }) async {
    final deltaLat = radiusKm / 111.0;
    final deltaLon = radiusKm / (111.0 * math.cos(centerLat * math.pi / 180).abs().clamp(0.2, 1.0));

    final uri = Uri.parse(
      '$_baseUrl'
      '?lamin=${centerLat - deltaLat}'
      '&lomin=${centerLon - deltaLon}'
      '&lamax=${centerLat + deltaLat}'
      '&lomax=${centerLon + deltaLon}',
    );

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 429) {
        throw const NetworkException('محدودیت نرخ درخواست. لطفاً کمی صبر کنید.');
      }
      if (response.statusCode != 200) {
        throw NetworkException('پاسخ نامعتبر از سرویس هوایی (${response.statusCode}).');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final states = data['states'] as List? ?? [];

      final results = <AircraftInfo>[];
      final now = DateTime.now();

      for (final s in states) {
        if (s == null || s is! List || s.length < 8) continue;
        if (s[5] == null || s[6] == null) continue;

        final lon = (s[5] as num).toDouble();
        final lat = (s[6] as num).toDouble();
        final dist = haversineDistanceKm(centerLat, centerLon, lat, lon);

        if (dist <= radiusKm) {
          results.add(AircraftInfo(
            icao24: s[0]?.toString() ?? '',
            callsign: s[1]?.toString().trim(),
            originCountry: s[2]?.toString(),
            latitude: lat,
            longitude: lon,
            altitude: s[7] != null ? (s[7] as num).toDouble() : null,
            velocity: s.length > 9 && s[9] != null ? (s[9] as num).toDouble() : null,
            distanceKm: dist,
            detectedAt: now,
          ));
        }
      }

      results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return results;
    } on TimeoutException {
      throw const NetworkException('زمان درخواست به پایان رسید.');
    } on http.ClientException {
      throw const NetworkException();
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException();
    }
  }
}
