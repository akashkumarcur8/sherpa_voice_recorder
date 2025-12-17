import 'package:flutter/material.dart';
import 'package:path/path.dart';

extension ContextSnackbar on BuildContext {
  /// Shows a standard success snackbar
  void showSuccessSnackBar(String message, {Duration? duration}) {
    _showSnackBar(
      message,
      duration: duration,
      backgroundColor: const Color(0xFFFFFFFF),
      icon: const Icon(Icons.check_circle, color: Color(0xFF00E244),size: 30),
      borderColor: const Color(0XFF6B7071),
      textColor: const Color(0XFF000000),

    );
  }

  /// Shows a standard error snackbar
  void showErrorSnackBar(String message, {Duration? duration}) {
    _showSnackBar(
      message,
      duration: duration,
      backgroundColor: Color(0XFFFFFFFF),
      icon: const Icon(Icons.error_outline,
          color: Color(0xFFFF2222),size: 30),
      borderColor: const Color(0XFF6B7071),
      textColor: const Color(0XFF000000),

    );
  }

  /// Shows a standard warning snackbar
  void showWarningSnackBar(String message, {Duration? duration}) {
    _showSnackBar(
      message,
      duration: duration,
      backgroundColor: Color(0XFFFFFFFF),
      icon: const Icon(Icons.error_outline,
          color: Color(0xFFFF2222),size: 30),
      borderColor: const Color(0XFF6B7071),
      textColor: const Color(0XFF000000),

    );
  }
  void showIncorrectInputSnackbar(String message, {Duration? duration}) {
    _showSnackBar(
      message,
      duration: duration,
      backgroundColor: const Color(0xFFFFD5D5),
      // icon: const Icon(Icons., color: Color(0xFF941717),size: 40,),


    );
  }


  /// Shows a standard info snackbar
  void showInfoSnackBar(String message, {Duration? duration}) {
    _showSnackBar(
      message,
      duration: duration,
      backgroundColor: Colors.blue.shade700,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  /// Private method that handles the actual snackbar display
  void _showSnackBar(
      String message, {
        Duration? duration,
        Color? backgroundColor,
        Color? borderColor,
        Color? textColor,
        Widget? icon,
      }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[icon, const SizedBox(width: 8)],
            Expanded(
              child: Text(
                message,
                style:  TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor!, // Slightly transparent
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
      ),
    );
  }
}