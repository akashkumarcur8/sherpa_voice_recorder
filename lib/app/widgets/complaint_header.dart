import 'package:flutter/material.dart';
import '../core/constants/app_text_styles.dart';

/// A reusable app header widget with back button and title
/// 
/// This widget provides a consistent header design across the app
/// with customizable title, background color, and styling options.
class AppHeader extends StatelessWidget {
  /// Title text to display in the center
  final String title;
  
  /// Background color (used if useGradient is false)
  final Color? backgroundColor;
  
  /// Whether to use gradient background
  final bool useGradient;
  
  /// Gradient colors (used if useGradient is true)
  final List<Color>? gradientColors;
  
  /// Whether to use SafeArea
  final bool useSafeArea;
  
  /// Fixed height (used if useSafeArea is false)
  final double? height;

  const AppHeader({
    super.key,
    required this.title,
    this.backgroundColor,
    this.useGradient = false,
    this.gradientColors,
    this.useSafeArea = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = useGradient
        ? BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors ??
                  const [Color(0xFF565ADD), Color(0xFF6A5AE0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          )
        : BoxDecoration(
            color: backgroundColor ?? const Color(0xFF5B6BC6),
          );

    final content = Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Text(
          title,
          style: AppTextStyles.manropeBold20.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );

    if (useSafeArea) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: decoration,
        child: SafeArea(
          bottom: false,
          child: content,
        ),
      );
    } else {
      return Container(
        height: height ?? 60,
        decoration: decoration,
        child: content,
      );
    }
  }
}

