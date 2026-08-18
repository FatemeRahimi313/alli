import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/audit_entry.dart';

/// Local Audit Log — never records secrets, exact location or personal IDs.
class AuditService {
  static const _boxName = 'audit_log';
  late Box _box;
  final _uuid = const Uuid();

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> log(AuditAction action, {String? detail}) async {
    final safeDetail = _sanitize(detail);
    final entry = AuditEntry(
      id: _uuid.v4(),
      action: action,
      timestamp: DateTime.now(),
      detail: safeDetail,
    );
    await _box.add(entry.toJson());
    if (_box.length > 200) {
      final excess = _box.length - 200;
      for (var i = 0; i < excess; i++) {
        await _box.deleteAt(0);
      }
    }
  }

  List<AuditEntry> getEntries({int limit = 50}) {
    final list = <AuditEntry>[];
    final keys = _box.keys.toList().reversed.take(limit);
    for (final key in keys) {
      final data = _box.get(key);
      if (data != null) {
        try {
          list.add(AuditEntry.fromJson(Map<String, dynamic>.from(data as Map)));
        } catch (_) {}
      }
    }
    return list;
  }

  Future<void> clear() async {
    await _box.clear();
  }

  String? _sanitize(String? input) {
    if (input == null || input.isEmpty) return null;
    final lower = input.toLowerCase();
    if (lower.contains('password') ||
        lower.contains('token') ||
        lower.contains('key') ||
        lower.contains('pin') ||
        lower.contains('secret') ||
        lower.contains('lat') ||
        lower.contains('lon') ||
        lower.contains('location')) {
      return null;
    }
    if (input.length > 120) return input.substring(0, 120);
    return input;
  }
}
