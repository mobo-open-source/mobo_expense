import '../../../model/app_error_typr.dart';

AppErrorType detectErrorType(Object e) {
  final error = e.toString();

  ///  Access / permission errors
  if (error.contains('odoo.exceptions.AccessError')) {
    return AppErrorType.access;
  }

  /// Business / validation errors (THIS CASE)
  if (error.contains('odoo.exceptions.UserError') ||
      error.contains('ValidationError')) {
    return AppErrorType.validation;
  }

  ///  Network errors
  if (error.contains('SocketException') || error.contains('TimeoutException')) {
    return AppErrorType.network;
  }

  return AppErrorType.unknown;
}
