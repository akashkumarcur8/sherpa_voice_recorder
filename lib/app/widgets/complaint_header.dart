import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    final content = Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 24,
          ),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.manropeBold20.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          // Invisible spacer to balance the back button for centered text
          const SizedBox(width: 48),
        ],
      ),
    );

    // Always use SafeArea for the top to avoid notch/status bar
    return Container(
      decoration: decoration,
      child: SafeArea(
        bottom: false,
        child: useSafeArea
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: content,
              )
            : content,
      ),
    );
  }
}
