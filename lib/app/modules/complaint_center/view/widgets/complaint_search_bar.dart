import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';

class ComplaintSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const ComplaintSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
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
          hintText: 'Search Ticket ID/Agent Name',
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

