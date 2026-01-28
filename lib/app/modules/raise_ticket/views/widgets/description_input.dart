import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../controllers/raise_ticket_controller.dart';

class DescriptionInput extends GetView<RaiseTicketController> {
  const DescriptionInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showOthersDescription.value) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: AppStrings.description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: AppStrings.requiredField,
                  style: TextStyle(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: AppStrings.enterDescription,
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: controller.descriptionError.value.isEmpty
                      ? AppColors.border
                      : AppColors.borderError,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: controller.descriptionError.value.isEmpty
                      ? AppColors.borderFocused
                      : AppColors.borderError,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.borderError,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.borderError,
                  width: 2,
                ),
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
          Obx(() {
            if (controller.descriptionError.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  controller.descriptionError.value,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      );
    });
  }
}