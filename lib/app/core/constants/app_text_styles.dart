// lib/app/core/constants/app_text_styles.dart

import 'package:flutter/material.dart';

/// Application text style constants
/// Centralized text style management for consistent typography
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // Font Families
  static const String manropeBold = 'Manrope';
  static const String inter = 'Inter';

  // Manrope Bold - Font Size 20
  static const TextStyle manropeBold20 = TextStyle(
    fontFamily: manropeBold,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Inter Regular - Font Size 12
  static const TextStyle interRegular12 = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Inter Regular - Font Size 10
  static const TextStyle interRegular10 = TextStyle(
    fontFamily: inter,
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );

  // Inter SemiBold - Font Size 20
  static const TextStyle interSemiBold20 = TextStyle(
    fontFamily: inter,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Inter SemiBold - Font Size 14
  static const TextStyle interSemiBold14 = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Inter Medium - Font Size 14
  static const TextStyle interMedium14 = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // Inter Regular - Font Size 14
  static const TextStyle interRegular14 = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Manrope SemiBold - Font Size 16
  static const TextStyle manropeSemibold16 = TextStyle(
    fontFamily: manropeBold,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
