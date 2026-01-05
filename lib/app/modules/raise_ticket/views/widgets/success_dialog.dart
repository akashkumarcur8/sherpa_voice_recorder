import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Reusable success dialog widget
/// Can be used for various success scenarios like ticket raised, reminder sent, etc.
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? recipientName;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.recipientName,
  });

  /// Show the success dialog
  static void show({
    required String title,
    required String message,
    String? recipientName,
  }) {
    Get.dialog(
      SuccessDialog(
        title: title,
        message: message,
        recipientName: recipientName,
      ),
      barrierDismissible: false,
    );

    // Auto close dialog after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green tick icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.lightGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'asset/images/green_tick.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: AppTextStyles.interSemiBold20.copyWith(
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            // Message with optional recipient name
            if (recipientName != null)
              Column(
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.interRegular14.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipientName!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.interSemiBold14.copyWith(
                      color: const Color(0xFF565ADD), // Primary blue color
                      height: 1.5,
                    ),
                  ),
                ],
              )
            else
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.interRegular14.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
