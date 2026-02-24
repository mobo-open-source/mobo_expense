import 'package:flutter/material.dart';
import '../../../model/app_error_typr.dart';

class CustomErrorDialog {
  static void show(BuildContext context, AppErrorType type, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        /// Auto close after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });

        switch (type) {
          case AppErrorType.access:
            return _accessDialog();
          case AppErrorType.validation:
            return _validationDialog(message);
          case AppErrorType.network:
            return _networkDialog();
          default:
            return _unknownDialog();
        }
      },
    );
  }

  static AlertDialog _accessDialog() {
    return _baseDialog(
      tit: "Access Restricted",
      message:
          "You do not have permission to perform this action."
          "Please switch company or contact the administrator.",
    );
  }

  static AlertDialog _validationDialog(String? message) {
    return _baseDialog(
      tit: "Action Not Allowed",
      message:
          message ??
          "Some required data is missing or invalid."
              "Please review and try again.",
    );
  }

  static AlertDialog _networkDialog() {
    return _baseDialog(
      tit: "Network Error",
      message: "Please check your internet connectionand try again.",
    );
  }

  static AlertDialog _unknownDialog() {
    return _baseDialog(
      tit: "Unexpected Error",
      message: "An unexpected error occurred.Please try again later.",
    );
  }

  /// Reusable dialog UI
  static AlertDialog _baseDialog({
    required String tit,
    required String message,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 26),
          const SizedBox(width: 8),
          Text(
            tit,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
