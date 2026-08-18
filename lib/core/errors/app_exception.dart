sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(
    this.message, {
    this.code,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(
    [String message = 'اتصال به اینترنت برقرار نشد.'],
    {String? code}
  ) : super(message, code: code);
}

class StorageException extends AppException {
  const StorageException(
    [String message = 'خطا در ذخیره‌سازی داده.'],
    {String? code}
  ) : super(message, code: code);
}

class AuthException extends AppException {
  const AuthException(
    [String message = 'احراز هویت ناموفق بود.'],
    {String? code}
  ) : super(message, code: code);
}

class ValidationException extends AppException {
  const ValidationException(
    [String message = 'داده‌های وارد شده نامعتبر است.'],
    {String? code}
  ) : super(message, code: code);
}

class NotFoundException extends AppException {
  const NotFoundException(
    [String message = 'مورد یافت نشد.'],
    {String? code}
  ) : super(message, code: code);
}

class PermissionException extends AppException {
  const PermissionException(
    [String message = 'دسترسی لازم داده نشده است.'],
    {String? code}
  ) : super(message, code: code);
}

class UnknownException extends AppException {
  const UnknownException(
    [String message = 'خطای ناشناخته رخ داد.'],
    {String? code}
  ) : super(message, code: code);
}

/// پیام کاربرپسند فارسی برای نمایش در UI
String userFriendlyMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }

  if (error is FormatException) {
    return 'فرمت داده نامعتبر است.';
  }

  return 'خطایی رخ داد. لطفاً دوباره تلاش کنید.';
}
