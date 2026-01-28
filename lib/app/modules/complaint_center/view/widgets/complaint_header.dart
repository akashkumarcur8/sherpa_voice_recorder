import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_text_styles.dart';

class ComplaintHeader extends StatelessWidget {
  const ComplaintHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF5B6BC6),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
            Text(
              'Complaint Center',
              style: AppTextStyles.manropeBold20.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
