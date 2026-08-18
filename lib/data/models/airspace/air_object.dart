/// Core Air Object model for Cheleban Airspace Awareness.
/// Responsible identification only — never over-claim.
enum AirCategory {
  aircraft,
  helicopter,
  uav,
  unknown,
}

enum IdentificationLevel {
  identified,
  partiallyIdentified,
  unknown,
  dataStale,
  invalid,
}

enum DataFreshness {
  live,    // < 15s
  recent,  // < 60s
  stale,   // >= 60s
  offline,
}

enum AirObjectStatus {
  normal,
  watch,
  caution,
  alert,
}

class AirObject {
  final String id;
  final String source; // e.g. "ADS-B", "UNKNOWN"
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double? altitudeMeters;
  final double? speedKmh;
  final double? headingDegrees;
  final AirCategory category;
  final IdentificationLevel identification;
  final double confidence; // 0.0 – 1.0
  final DataFreshness freshness;
  final AirObjectStatus status;
  final String? callsign;
  final String? originCountry;
  final double? distanceKm;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final int updateCount;
  final List<String> sources;
  final bool isValid;

  const AirObject({
    required this.id,
    required this.source,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.altitudeMeters,
    this.speedKmh,
    this.headingDegrees,
    required this.category,
    required this.identification,
    required this.confidence,
    required this.freshness,
    required this.status,
    this.callsign,
    this.originCountry,
    this.distanceKm,
    required this.firstSeen,
    required this.lastSeen,
    this.updateCount = 1,
    this.sources = const ['ADS-B'],
    this.isValid = true,
  });

  bool get isUnknown =>
      identification == IdentificationLevel.unknown ||
      category == AirCategory.unknown;

  bool get hasPosition => latitude != null && longitude != null;

  String get confidenceLabel {
    if (confidence >= 0.80) return 'HIGH';
    if (confidence >= 0.50) return 'MEDIUM';
    return 'LOW';
  }

  String get identificationLabel {
    switch (identification) {
      case IdentificationLevel.identified:
        return 'IDENTIFIED';
      case IdentificationLevel.partiallyIdentified:
        return 'PARTIALLY IDENTIFIED';
      case IdentificationLevel.unknown:
        return 'UNKNOWN';
      case IdentificationLevel.dataStale:
        return 'DATA STALE';
      case IdentificationLevel.invalid:
        return 'INVALID';
    }
  }

  String get categoryLabel {
    switch (category) {
      case AirCategory.aircraft:
        return 'AIRCRAFT';
      case AirCategory.helicopter:
        return 'HELICOPTER';
      case AirCategory.uav:
        return 'UAV';
      case AirCategory.unknown:
        return 'UNKNOWN';
    }
  }

  String get freshnessLabel {
    switch (freshness) {
      case DataFreshness.live:
        return 'LIVE';
      case DataFreshness.recent:
        return 'RECENT';
      case DataFreshness.stale:
        return 'STALE';
      case DataFreshness.offline:
        return 'OFFLINE';
    }
  }

  AirObject copyWith({
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? altitudeMeters,
    double? speedKmh,
    double? headingDegrees,
    AirCategory? category,
    IdentificationLevel? identification,
    double? confidence,
    DataFreshness? freshness,
    AirObjectStatus? status,
    String? callsign,
    double? distanceKm,
    DateTime? lastSeen,
    int? updateCount,
    List<String>? sources,
    bool? isValid,
  }) {
    return AirObject(
      id: id,
      source: source,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      speedKmh: speedKmh ?? this.speedKmh,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      category: category ?? this.category,
      identification: identification ?? this.identification,
      confidence: confidence ?? this.confidence,
      freshness: freshness ?? this.freshness,
      status: status ?? this.status,
      callsign: callsign ?? this.callsign,
      originCountry: originCountry ?? this.originCountry,
      distanceKm: distanceKm ?? this.distanceKm,
      firstSeen: firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      updateCount: updateCount ?? this.updateCount,
      sources: sources ?? this.sources,
      isValid: isValid ?? this.isValid,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'altitudeMeters': altitudeMeters,
        'speedKmh': speedKmh,
        'headingDegrees': headingDegrees,
        'category': category.name,
        'identification': identification.name,
        'confidence': confidence,
        'freshness': freshness.name,
        'status': status.name,
        'callsign': callsign,
        'originCountry': originCountry,
        'distanceKm': distanceKm,
        'firstSeen': firstSeen.toIso8601String(),
        'lastSeen': lastSeen.toIso8601String(),
        'updateCount': updateCount,
        'sources': sources,
        'isValid': isValid,
      };

  factory AirObject.fromJson(Map<String, dynamic> json) {
    return AirObject(
      id: json['id'] as String,
      source: json['source'] as String? ?? 'UNKNOWN',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble(),
      speedKmh: (json['speedKmh'] as num?)?.toDouble(),
      headingDegrees: (json['headingDegrees'] as num?)?.toDouble(),
      category: AirCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AirCategory.unknown,
      ),
      identification: IdentificationLevel.values.firstWhere(
        (e) => e.name == json['identification'],
        orElse: () => IdentificationLevel.unknown,
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      freshness: DataFreshness.values.firstWhere(
        (e) => e.name == json['freshness'],
        orElse: () => DataFreshness.stale,
      ),
      status: AirObjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AirObjectStatus.normal,
      ),
      callsign: json['callsign'] as String?,
      originCountry: json['originCountry'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      firstSeen: DateTime.tryParse(json['firstSeen'] as String? ?? '') ?? DateTime.now(),
      lastSeen: DateTime.tryParse(json['lastSeen'] as String? ?? '') ?? DateTime.now(),
      updateCount: json['updateCount'] as int? ?? 1,
      sources: (json['sources'] as List?)?.map((e) => e.toString()).toList() ?? ['ADS-B'],
      isValid: json['isValid'] as bool? ?? true,
    );
  }
}
