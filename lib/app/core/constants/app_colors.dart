// lib/app/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// Application color constants
/// Centralized color management for consistent theming across the app
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================================
  // PRIMARY BRAND COLORS
  // ============================================================================
  
  /// Main brand purple - Used for primary actions, headers, and key UI elements
  static const Color primaryPurple = Color(0xFF565ADD);
  
  /// Alias for primaryPurple - for backward compatibility
  static const Color primary = primaryPurple;
  
  /// Dark variant of primary purple - Used in gradients and darker sections
  static const Color primaryPurpleDark = Color(0xFF2E3077);
  
  /// Light variant of primary purple
  static const Color primaryPurpleLight = Color(0xFF7B7FEE);
  
  /// Secondary purple shade
  static const Color secondaryPurple = Color(0xFF6A5AE0);
  
  /// Lighter purple for backgrounds
  static const Color lightPurple = Color(0xFFE5E5FF);
  
  /// Rose pink tint
  static const Color rosePink = Color(0xFFD6D9FF);
  
  /// Deep purple for avatars
  static const Color deepPurple = Color(0xFF9C27B0);
  
  /// Purple for badges/icons
  static const Color badgePurple = Color(0xFF6A5AE0);
  
  /// Light purple background
  static const Color purpleBackground = Color(0xFFC4D0FB);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================
  
  /// Primary text color - darkest, for main content
  static const Color textPrimary = Color(0xFF212121);
  
  /// Dark text - for headings and important text
  static const Color textDark = Color(0xFF1A1A1A);
  
  /// Primary light text
  static const Color textPrimaryLight = Color(0xFF31373D);
  
  /// Secondary text - for less important content
  static const Color textSecondary = Color(0xFF757575);
  
  /// Medium grey text
  static const Color textMedium = Color(0xFF9D9D9D);
  
  /// Light grey text
  static const Color textLight = Color(0xFFAFB0B0);
  
  /// Label text color
  static const Color textLabel = Color(0xFF555E67);
  
  /// Hint text color
  static const Color textHint = Color(0xFFBDBDBD);
  
  /// Disabled text color
  static const Color textDisabled = Color(0xFFE0E0E0);
  
  /// Error text color
  static const Color textError = Color(0xFFD32F2F);
  
  /// Grey text for secondary info
  static const Color textGrey = Color(0xFF7B7676);

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================
  
  /// Main app background
  static const Color background = Color(0xFFF5F5F5);
  
  /// Light background for sections
  static const Color backgroundLight = Color(0xFFF8F9FC);
  
  /// Card background
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  /// Scaffold background
  static const Color scaffoldBackground = Color(0xFFFAFAFA);
  
  /// Icon background
  static const Color iconBackground = Color(0xFFEFEFEF);
  
  /// Extra light grey background
  static const Color extraLightGrey = Color(0xFFF5F5F5);
  
  /// Success background (light green)
  static const Color backgroundSuccess = Color(0xFFE2FFE9);
  
  /// Success background variant
  static const Color backgroundSuccessAlt = Color(0xFFC9F2E9);
  
  /// Error background (light red)
  static const Color backgroundError = Color(0xFFFFEFEF);
  
  /// Info background (light blue)
  static const Color backgroundInfo = Color(0xFFE8F0FF);
  
  /// Warning background (light yellow)
  static const Color backgroundWarning = Color(0xFFFFF9C2);
  
  /// Pink background
  static const Color backgroundPink = Color(0xFFFFD6DD);
  
  /// Blue background
  static const Color backgroundBlue = Color(0xFFD6F0FF);
  
  /// Disabled background
  static const Color disabledBackground = Color(0xFFE0E0E0);

  // ============================================================================
  // BORDER & DIVIDER COLORS
  // ============================================================================
  
  /// Standard border color
  static const Color border = Color(0xFFE0E0E0);
  
  /// Light border
  static const Color borderLight = Color(0xFFEBEBEB);
  
  /// Medium border
  static const Color borderMedium = Color(0xFFE5E5E5);
  
  /// Input border
  static const Color inputBorder = Color(0xFFECEDF0);
  
  /// Focused border
  static const Color borderFocused = Color(0xFF5B5FED);
  
  /// Error border
  static const Color borderError = Color(0xFFD32F2F);
  
  /// Divider color
  static const Color divider = Color(0xFFBDBDBD);
  
  /// Light divider
  static const Color dividerLight = Color(0xFFDFDFDF);

  // ============================================================================
  // STATUS & ACCENT COLORS
  // ============================================================================
  
  /// Success green
  static const Color success = Color(0xFF4CAF50);
  
  /// Success green variant
  static const Color successGreen = Color(0xFF0EC16E);
  
  /// Success green bright
  static const Color successBright = Color(0xFF00E244);
  
  /// Warning orange
  static const Color warning = Color(0xFFFFA726);
  
  /// Error red
  static const Color error = Color(0xFFF44336);
  
  /// Error red variant
  static const Color errorRed = Color(0xFFFF4444);
  
  /// Info blue
  static const Color info = Color(0xFF2196F3);
  
  /// Gold/Yellow accent
  static const Color goldAccent = Color(0xFFFFC93D);
  
  /// Yellow accent variant
  static const Color yellowAccent = Color(0xFFFFD51A);
  
  /// Teal/Cyan accent
  static const Color tealAccent = Color(0xFF5EDEC3);
  
  /// Pink accent
  static const Color pinkAccent = Color(0xFFFF6B84);
  
  /// Blue accent
  static const Color blueAccent = Color(0xFF6BB8FF);
  
  /// Cyan accent
  static const Color cyanAccent = Color(0xFF00BCD4);

  // ============================================================================
  // AVATAR & BADGE COLORS
  // ============================================================================
  
  /// Avatar green
  static const Color avatarGreen = Color(0xFF4CAF50);
  
  /// Avatar orange
  static const Color avatarOrange = Color(0xFFFF9800);
  
  /// Avatar blue
  static const Color avatarBlue = Color(0xFF2196F3);
  
  /// Avatar pink
  static const Color avatarPink = Color(0xFFE91E63);
  
  /// Avatar deep purple
  static const Color avatarDeepPurple = Color(0xFF9C27B0);
  
  /// Avatar cyan
  static const Color avatarCyan = Color(0xFF00BCD4);
  
  /// Avatar deep orange
  static const Color avatarDeepOrange = Color(0xFFFF5722);

  // ============================================================================
  // BASIC COLORS
  // ============================================================================
  
  /// Pure white
  static const Color white = Color(0xFFFFFFFF);
  
  /// Pure black
  static const Color black = Color(0xFF000000);
  
  /// Transparent
  static const Color transparent = Colors.transparent;
  
  /// Grey
  static const Color grey = Color(0xFF9E9E9E);
  
  /// Light grey
  static const Color lightGrey = Color(0xFFE0E0E0);
  
  /// Dark grey
  static const Color darkGrey = Color(0xFF616161);
  
  /// Disabled grey
  static const Color disabled = Color(0xFFBDBDBD);

  // ============================================================================
  // SHADOWS
  // ============================================================================
  
  /// Standard shadow
  static Color shadow = Colors.black.withOpacity(0.1);
  
  /// Dark shadow
  static Color shadowDark = Colors.black.withOpacity(0.2);

  // ============================================================================
  // GRADIENTS
  // ============================================================================
  
  /// Primary gradient (purple)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, secondaryPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  /// Header gradient (purple dark to light)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryPurple, primaryPurpleDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  /// Analytics gradient
  static const LinearGradient analyticsGradient = LinearGradient(
    colors: [primaryPurple, Color(0xFFD4B2FB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get avatar color by index (cycles through avatar colors)
  static Color getAvatarColor(int index) {
    final colors = [
      avatarGreen,
      avatarOrange,
      avatarBlue,
      avatarPink,
      avatarDeepPurple,
      avatarCyan,
      avatarDeepOrange,
      primaryPurple,
    ];
    return colors[index % colors.length];
  }
}
