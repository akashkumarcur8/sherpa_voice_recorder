import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/agent_model.dart';
import '../../controllers/delivery_tracker_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:intl/intl.dart';

class AgentListItemWidget extends StatelessWidget {
  final AgentModel agent;

  const AgentListItemWidget({
    super.key,
    required this.agent,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryTrackerController>();

    return Obx(() {
      final isPendingTab = controller.selectedFilter.value == 'Pending';
      final currentIsSelected = controller.isAgentSelected(agent.agentId);

      return GestureDetector(
        onTap: () {
          if (isPendingTab) {
            // Toggle selection for pending agents
            controller.toggleAgentSelection(agent.agentId);
          } else if (agent.isDelivered) {
            // Only navigate to detail screen if agent status is delivered
            Get.toNamed(
              '/agent-detail',
              arguments: {'agentId': agent.agentId},
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPendingTab && currentIsSelected
                ? AppColors.lightPurple
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPendingTab && currentIsSelected
                  ? AppColors.primary
                  : AppColors.lightGrey,
              width: isPendingTab && currentIsSelected ? 1.5 : 1,
            ),
            // Subtle shadow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Agent Name
                  _buildInfoRow(
                    label: 'Agent Name',
                    value: agent.agentName,
                  ),
                  const SizedBox(height: 8),
                  // Agent ID
                  _buildInfoRow(
                    label: 'Agent ID',
                    value: agent.agentId,
                  ),
                  const SizedBox(height: 8),
                  // Device Status
                  _buildInfoRow(
                    label: 'Device Status',
                    value: agent.isPending ? 'Pending' : 'Delivered',
                    valueColor:
                        agent.isPending ? AppColors.error : AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  // Issue Date
                  _buildInfoRow(
                    label: 'Issue Date',
                    value: _formatDate(agent.issueDate),
                  ),
                ],
              ),
              // Checkbox in top right corner - only visible when selected
              if (isPendingTab && currentIsSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110, // Fixed width for labels to align values
          child: Text(
            '$label:',
            style: AppTextStyles.interRegular14.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.interRegular14.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }

    try {
      // Try to parse the date string
      DateTime? date;

      // Try different date formats
      if (dateString.contains('/')) {
        // Format: 12/12/2025
        final parts = dateString.split('/');
        if (parts.length == 3) {
          date = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } else {
        // Try ISO format or other formats
        date = DateTime.tryParse(dateString);
      }

      if (date != null) {
        // Format as DD/MM/YYYY
        return DateFormat('dd/MM/yyyy').format(date);
      }

      return dateString; // Return as-is if parsing fails
    } catch (e) {
      return dateString; // Return as-is if any error occurs
    }
  }
}
