/// Personal Profile — sensitive data only from Secure Storage.
/// Never hardcode real user information.
class PersonalProfile {
  final String displayName;
  final String? callsign;
  final String? avatarPath;
  final bool privacyMode;
  final DateTime updatedAt;

  const PersonalProfile({
    this.displayName = 'فرمانده',
    this.callsign,
    this.avatarPath,
    this.privacyMode = false,
    required this.updatedAt,
  });

  factory PersonalProfile.defaultProfile() => PersonalProfile(
        displayName: 'فرمانده',
        updatedAt: DateTime.now(),
      );

  PersonalProfile copyWith({
    String? displayName,
    String? callsign,
    String? avatarPath,
    bool? privacyMode,
    DateTime? updatedAt,
  }) {
    return PersonalProfile(
      displayName: displayName ?? this.displayName,
      callsign: callsign ?? this.callsign,
      avatarPath: avatarPath ?? this.avatarPath,
      privacyMode: privacyMode ?? this.privacyMode,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'callsign': callsign,
        'avatarPath': avatarPath,
        'privacyMode': privacyMode,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PersonalProfile.fromJson(Map<String, dynamic> json) {
    return PersonalProfile(
      displayName: json['displayName'] as String? ?? 'فرمانده',
      callsign: json['callsign'] as String?,
      avatarPath: json['avatarPath'] as String?,
      privacyMode: json['privacyMode'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
