class AircraftInfo {
  final String icao24;
  final String? callsign;
  final String? originCountry;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? velocity;
  final double distanceKm;
  final DateTime detectedAt;

  const AircraftInfo({
    required this.icao24,
    this.callsign,
    this.originCountry,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.velocity,
    required this.distanceKm,
    required this.detectedAt,
  });

  bool get isUnknown => callsign == null || callsign!.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        'icao24': icao24,
        'callsign': callsign,
        'originCountry': originCountry,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'velocity': velocity,
        'distanceKm': distanceKm,
        'detectedAt': detectedAt.toIso8601String(),
      };

  factory AircraftInfo.fromJson(Map<String, dynamic> json) {
    return AircraftInfo(
      icao24: json['icao24'] as String,
      callsign: json['callsign'] as String?,
      originCountry: json['originCountry'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      velocity: (json['velocity'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }
}
