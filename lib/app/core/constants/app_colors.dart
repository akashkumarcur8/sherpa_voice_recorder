// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// Application color constants
/// Centralized color management for consistent theming
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF565ADD);
  static const Color primaryLight = Color(0xFF7B7FEE);
  static const Color primaryDark = Color(0xFF3B3FBE);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Basic Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color rosePink = Color(0xFFD6D9FF);
  static const Color lightPurple = Color(0xFFE5E5FF);

  // Grey Scale
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF616161);
  static const Color extraLightGrey = Color(0xFFF5F5F5);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFFAFAFA);
  static const Color iconBackground = Color(0xFFEFEFEF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textPrimaryLight = Color(0xFF31373D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLabel = Color(0xFF555E67);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFFE0E0E0);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color inputBorder = Color(0xFFECEDF0);

  // Transparent
  static const Color transparent = Colors.transparent;

  // Shadow
  static Color shadow = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.2);

  static const Color disabledBackground = Color(0xFFE0E0E0);

  static const Color textError = Color(0xFFD32F2F);

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color borderFocused = Color(0xFF5B5FED);
  static const Color borderError = Color(0xFFD32F2F);

  // Additional Colors
  static const Color disabled = Color(0xFFBDBDBD);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
