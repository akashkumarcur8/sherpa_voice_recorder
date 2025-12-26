import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StatsCardWidget extends StatelessWidget {
  final String value;
  final String label;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool isSelected;

  const StatsCardWidget({
    Key? key,
    required this.value,
    required this.label,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white
              : backgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B6BC6) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          // Add shadow for clickable effect
          boxShadow: onTap != null
              ? [
            BoxShadow(
              color: const Color(0xFF5B6BC6).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
