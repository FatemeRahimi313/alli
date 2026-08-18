sealed class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'اتصال به اینترنت برقرار نشد.', super.code]);
}

class StorageException extends AppException {
  const StorageException([super.message = 'خطا در ذخیره‌سازی داده.', super.code]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'احراز هویت ناموفق بود.', super.code]);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'داده‌های وارد شده نامعتبر است.', super.code]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'مورد یافت نشد.', super.code]);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'دسترسی لازم داده نشده است.', super.code]);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'خطای ناشناخته رخ داد.', super.code]);
}

/// پیام کاربرپسند فارسی برای نمایش در UI
String userFriendlyMessage(Object error) {
  if (error is AppException) return error.message;
  if (error is FormatException) return 'فرمت داده نامعتبر است.';
  return 'خطایی رخ داد. لطفاً دوباره تلاش کنید.';
}
