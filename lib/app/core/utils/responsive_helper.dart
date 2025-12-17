// lib/core/utils/responsive_helper.dart

import 'package:flutter/material.dart';

/// Helper class for responsive design
/// Provides utilities for handling different screen sizes
class ResponsiveHelper {
  // Prevent instantiation
  ResponsiveHelper._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  /// Check if current device is mobile
  /// Mobile: width < 600px
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Check if current device is tablet
  /// Tablet: 600px <= width < 1024px
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
          MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Check if current device is desktop
  /// Desktop: width >= 1024px
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Get screen width
  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get responsive value based on screen size
  ///
  /// Usage:
  /// ```dart
  /// double fontSize = ResponsiveHelper.getResponsiveValue(
  ///   context,
  ///   mobile: 14.0,
  ///   tablet: 16.0,
  ///   desktop: 18.0,
  /// );
  /// ```
  static T getResponsiveValue<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
        T? desktop,
      }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Get responsive padding for screens
  ///
  /// Returns adaptive padding based on screen size:
  /// - Mobile: 16px horizontal
  /// - Tablet: 24px horizontal
  /// - Desktop: 32px horizontal
  static EdgeInsets getResponsivePadding(BuildContext context) {
    double horizontalPadding = getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 16,
    );
  }

  /// Get responsive font size
  ///
  /// Usage:
  /// ```dart
  /// double fontSize = ResponsiveHelper.getResponsiveFontSize(
  ///   context,
  ///   mobile: 14.0,
  ///   tablet: 16.0,
  ///   desktop: 18.0,
  /// );
  /// ```
  static double getResponsiveFontSize(
      BuildContext context, {
        required double mobile,
        double? tablet,
        double? desktop,
      }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive spacing
  ///
  /// Returns adaptive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  /// Get responsive margin
  ///
  /// Returns adaptive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    double margin = getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    return EdgeInsets.all(margin);
  }

  /// Get responsive border radius
  ///
  /// Returns adaptive border radius based on screen size
  static double getResponsiveBorderRadius(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  /// Get responsive icon size
  ///
  /// Returns adaptive icon size based on screen size
  static double getResponsiveIconSize(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
  }

  /// Get number of columns for grid
  ///
  /// Returns adaptive column count based on screen size
  static int getGridColumnCount(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }

  /// Get max width for content
  ///
  /// Returns max content width to prevent stretching on large screens
  static double getMaxContentWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 800.0,
      desktop: 1200.0,
    );
  }

  /// Calculate percentage of screen width
  ///
  /// [percentage] - value between 0 and 1
  static double percentWidth(BuildContext context, double percentage) {
    return getWidth(context) * percentage;
  }

  /// Calculate percentage of screen height
  ///
  /// [percentage] - value between 0 and 1
  static double percentHeight(BuildContext context, double percentage) {
    return getHeight(context) * percentage;
  }

  /// Get device orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }














  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600;
    } else {
      return 800;
    }
  }

  static EdgeInsets getResponsiveScreenPadding(BuildContext context) {
    final padding = getResponsivePadding(context);
    return const EdgeInsets.all(10);
  }

  static SizedBox verticalSpace(double height) {
    return SizedBox(height: height);
  }

  static SizedBox horizontalSpace(double width) {
    return SizedBox(width: width);
  }
}