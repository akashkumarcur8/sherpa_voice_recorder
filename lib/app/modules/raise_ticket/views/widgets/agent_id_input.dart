import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../controllers/raise_ticket_controller.dart';

class AgentIdInput extends GetView<RaiseTicketController> {
  const AgentIdInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: AppStrings.agentId,
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
        Obx(() => TextField(
          controller: controller.agentIdController,
          decoration: InputDecoration(
            hintText: AppStrings.enterYourAgentId,
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
                color: controller.agentIdError.value.isEmpty
                    ? AppColors.border
                    : AppColors.borderError,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: controller.agentIdError.value.isEmpty
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
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        )),
        Obx(() {
          if (controller.agentIdError.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                controller.agentIdError.value,
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
  }
}