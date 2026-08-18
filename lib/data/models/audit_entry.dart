/// Local Audit Log entry — never stores secrets or exact location.
enum AuditAction {
  appOpened,
  missionCompleted,
  missionUncompleted,
  settingsChanged,
  securityEnabled,
  securityDisabled,
  privacyModeToggled,
  dataReset,
  alertReceived,
  backupCreated,
  lockFailed,
}

class AuditEntry {
  final String id;
  final AuditAction action;
  final DateTime timestamp;
  final String? detail;

  const AuditEntry({
    required this.id,
    required this.action,
    required this.timestamp,
    this.detail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action.name,
        'timestamp': timestamp.toIso8601String(),
        'detail': detail,
      };

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String,
      action: AuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => AuditAction.appOpened,
      ),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      detail: json['detail'] as String?,
    );
  }

  String get localizedLabel {
    switch (action) {
      case AuditAction.appOpened:
        return 'ورود به اپ';
      case AuditAction.missionCompleted:
        return 'ثبت مأموریت روز';
      case AuditAction.missionUncompleted:
        return 'لغو ثبت مأموریت';
      case AuditAction.settingsChanged:
        return 'تغییر تنظیمات';
      case AuditAction.securityEnabled:
        return 'فعال‌سازی قفل امنیتی';
      case AuditAction.securityDisabled:
        return 'غیرفعال‌سازی قفل';
      case AuditAction.privacyModeToggled:
        return 'تغییر حالت حریم خصوصی';
      case AuditAction.dataReset:
        return 'بازنشانی داده‌ها';
      case AuditAction.alertReceived:
        return 'هشدار هوایی';
      case AuditAction.backupCreated:
        return 'ایجاد پشتیبان';
      case AuditAction.lockFailed:
        return 'تلاش ناموفق برای باز کردن';
    }
  }
}
