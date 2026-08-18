import 'dart:math';

/// محاسبه فاصله بین دو نقطه جغرافیایی به کیلومتر (Haversine)
double haversineDistanceKm(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const R = 6371.0; // Earth radius in km
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _toRadians(double deg) => deg * pi / 180;
