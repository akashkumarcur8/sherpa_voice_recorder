import 'package:flutter/material.dart';
import '../core/constants/app_text_styles.dart';

/// A reusable search bar widget with customizable hint text
///
/// This widget provides a consistent search input field that can be used
/// across different screens with different hint texts.
class AppSearchBar extends StatelessWidget {
  /// Text editing controller for the search field
  final TextEditingController controller;

  /// Callback when the search text changes
  final ValueChanged<String>? onChanged;

  /// Hint text to display in the search field
  final String hintText;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.interRegular12.copyWith(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.interRegular12.copyWith(
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
