import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/controllers/mark_conversation_controller.dart' as mark_conv;

class MarkConversationDialog extends StatelessWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final VoidCallback? showToast;
  final Function()? onFetchStatistics;
  final Function(int userId, DateTime date)? onRefreshSessions;

  const MarkConversationDialog({
    super.key,
    this.onSuccess,
    this.onError,
    this.showToast,
    this.onFetchStatistics,
    this.onRefreshSessions,
  });

  static Future<bool?> show({
    required BuildContext context,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    VoidCallback? showToast,
    Function()? onFetchStatistics,
    Function(int userId, DateTime date)? onRefreshSessions,
  }) {
    final controller = Get.put(mark_conv.ConversationController());
    controller.reset();

    return Get.dialog(
      Builder(
        builder: (dialogContext) {
          return MarkConversationDialog(
            onSuccess: onSuccess,
            onError: onError,
            showToast: showToast,
            onFetchStatistics: onFetchStatistics,
            onRefreshSessions: onRefreshSessions,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      title: const Text(
        "Mark a Conversation",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            minWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: GetBuilder<mark_conv.ConversationController>(
            builder: (controller) {
              return Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Enter Product Name',
                            style: TextStyle(
                              color: AppColors.textLabel,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.productInputController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.scaffoldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: controller.productInputController.text
                                    .trim()
                                    .isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      color: AppColors.rosePink,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        controller.addProductFromInput();
                                      },
                                    ),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            controller.update();
                          },
                          validator: (value) {
                            if ((controller.selectedProducts.isEmpty &&
                                (value == null || value.trim().isEmpty))) {
                              return "Product Name is required";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Chips of selected Products
                    Obx(() => controller.selectedProducts.isEmpty
                        ? const SizedBox.shrink()
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.selectedProducts
                                .map((product) => Chip(
                                      label: Text(
                                        product,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                        side: BorderSide.none,
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      onDeleted: () =>
                                          controller.removeProduct(product),
                                      labelPadding: const EdgeInsets.only(
                                        left: 8,
                                        right: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 0,
                                      ),
                                    ))
                                .toList(),
                          )),
                    const SizedBox(height: 16),

                    // Customer ID input (optional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer ID',
                          style: TextStyle(
                            color: AppColors.textLabel,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.customerIdController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.scaffoldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date range picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Choose Start Time & End Time',
                            style: TextStyle(
                              color: AppColors.textLabel,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.dateRangeController,
                          readOnly: true,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'hh:mm to hh:mm',
                            hintStyle: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: AppColors.scaffoldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0.9,
                                color: AppColors.primary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.iconBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 18,
                                  color: Color(0xFF565ADD),
                                ),
                              ),
                              onPressed: () {
                                controller.pickDateRange(context);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Start Time & End Time is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Obx(() {
            final controller = Get.find<mark_conv.ConversationController>();
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isFormValid.value
                    ? () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        await Future.delayed(
                          const Duration(milliseconds: 100),
                        );
                        if (!controller.formKey.currentState!.validate()) {
                          if (showToast != null) {
                            showToast!();
                          }
                          return;
                        }
                        var message = await controller.submitForm();

                        if (message != null &&
                            message ==
                                "Conversation session saved successfully") {
                          if (onFetchStatistics != null) {
                            await onFetchStatistics!();
                          }
                          Get.back(result: true);
                          if (onSuccess != null) {
                            onSuccess!();
                          }
                        } else {
                          Get.back(result: false);
                          if (onError != null) {
                            onError!();
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isFormValid.value
                      ? AppColors.primary
                      : AppColors.disabledBackground,
                  foregroundColor: controller.isFormValid.value
                      ? Colors.white
                      : AppColors.textDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
