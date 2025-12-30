import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/raise_ticket_controller.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'agent_id_input.dart';
import 'query_dropdown.dart';
import 'description_input.dart';
import 'submit_button.dart';

class RaiseTicketBottomSheet extends StatelessWidget {
  const RaiseTicketBottomSheet({super.key});

  static void show(BuildContext context) {
    // Initialize controller if not already registered
    if (!Get.isRegistered<RaiseTicketController>()) {
      Get.put(RaiseTicketController());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RaiseTicketBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaiseTicketController>();
    
    return Obx(() {
      // Adjust height based on whether "Others" is selected
      final initialSize = controller.showOthersDescription.value ? 0.65 : 0.5;
      final minSize = controller.showOthersDescription.value ? 0.45 : 0.35;
      
      return DraggableScrollableSheet(
        key: ValueKey(controller.showOthersDescription.value), // Force rebuild when size changes
        initialChildSize: initialSize,
        minChildSize: minSize,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  'Raise a Ticket',
                  style: AppTextStyles.manropeBold20.copyWith(
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const AgentIdInput(),
                      const SizedBox(height: 20),
                      const QueryDropdown(),
                      const SizedBox(height: 20),
                      const DescriptionInput(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Submit button (fixed at bottom)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: const SubmitButton(),
              ),
            ],
          ),
        );
        },
      );
    });
  }
}

