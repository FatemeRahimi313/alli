import 'package:hive/hive.dart';

part 'cheleh_day.g.dart';

@HiveType(typeId: 0)
class ChelehDay extends HiveObject {
  @HiveField(0)
  final int dayNumber; // 1..40

  @HiveField(1)
  final String dateIso; // yyyy-MM-dd of the night

  @HiveField(2)
  bool namazShab;

  @HiveField(3)
  bool ziyaratAshura;

  @HiveField(4)
  bool doayeTavassol;

  @HiveField(5)
  int? mood; // 1-5

  @HiveField(6)
  int? energy; // 1-5

  @HiveField(7)
  int? sleep; // 1-5

  @HiveField(8)
  String? note;

  @HiveField(9)
  String? audioPath;

  @HiveField(10)
  String? dailyZikr;

  @HiveField(11)
  DateTime? completedAt;

  @HiveField(12)
  DateTime updatedAt;

  ChelehDay({
    required this.dayNumber,
    required this.dateIso,
    this.namazShab = false,
    this.ziyaratAshura = false,
    this.doayeTavassol = false,
    this.mood,
    this.energy,
    this.sleep,
    this.note,
    this.audioPath,
    this.dailyZikr,
    this.completedAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  bool get isComplete => namazShab && ziyaratAshura && doayeTavassol;
  bool get isPartial => (namazShab || ziyaratAshura || doayeTavassol) && !isComplete;
  bool get isEmpty => !namazShab && !ziyaratAshura && !doayeTavassol;

  int get completedCount {
    int c = 0;
    if (namazShab) c++;
    if (ziyaratAshura) c++;
    if (doayeTavassol) c++;
    return c;
  }

  ChelehDay copyWith({
    bool? namazShab,
    bool? ziyaratAshura,
    bool? doayeTavassol,
    int? mood,
    int? energy,
    int? sleep,
    String? note,
    String? audioPath,
    String? dailyZikr,
    DateTime? completedAt,
  }) {
    return ChelehDay(
      dayNumber: dayNumber,
      dateIso: dateIso,
      namazShab: namazShab ?? this.namazShab,
      ziyaratAshura: ziyaratAshura ?? this.ziyaratAshura,
      doayeTavassol: doayeTavassol ?? this.doayeTavassol,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      sleep: sleep ?? this.sleep,
      note: note ?? this.note,
      audioPath: audioPath ?? this.audioPath,
      dailyZikr: dailyZikr ?? this.dailyZikr,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'dateIso': dateIso,
        'namazShab': namazShab,
        'ziyaratAshura': ziyaratAshura,
        'doayeTavassol': doayeTavassol,
        'mood': mood,
        'energy': energy,
        'sleep': sleep,
        'note': note,
        'audioPath': audioPath,
        'dailyZikr': dailyZikr,
        'completedAt': completedAt?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChelehDay.fromJson(Map<String, dynamic> json) {
    return ChelehDay(
      dayNumber: json['dayNumber'] as int,
      dateIso: json['dateIso'] as String,
      namazShab: json['namazShab'] as bool? ?? false,
      ziyaratAshura: json['ziyaratAshura'] as bool? ?? false,
      doayeTavassol: json['doayeTavassol'] as bool? ?? false,
      mood: json['mood'] as int?,
      energy: json['energy'] as int?,
      sleep: json['sleep'] as int?,
      note: json['note'] as String?,
      audioPath: json['audioPath'] as String?,
      dailyZikr: json['dailyZikr'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
