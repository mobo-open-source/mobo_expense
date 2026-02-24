String getUserFriendlyErrorMessage(dynamic error) {
  final errorString = error.toString().toLowerCase();

  if (errorString.contains('socketexception') ||
      errorString.contains('failed host lookup') ||
      errorString.contains('no address associated') ||
      errorString.contains('connection refused') ||
      errorString.contains('connection timeout') ||
      errorString.contains('host unreachable') ||
      errorString.contains('no route to host') ||
      errorString.contains('network is unreachable') ||
      errorString.contains('failed to connect') ||
      errorString.contains('connection failed')) {
    return 'Unable to connect to server. Please check your internet connection.';
  } else if (errorString.contains('timeout') ||
      errorString.contains('timed out')) {
    return 'Connection timed out. Please check your internet connection and try again.';
  } else if (errorString.contains('html instead of json') ||
      errorString.contains('formatexception')) {
    return 'Server configuration issue. Please contact your administrator.';
  } else if (errorString.contains('session') ||
      errorString.contains('authentication')) {
    return 'Your session has expired. Please log in again.';
  } else if (errorString.contains('access') ||
      errorString.contains('permission')) {
    return 'You do not have permission to access products. Please contact your administrator.';
  }

  return 'Unable to load products. Please try again or contact support.';
}
