
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/agent_model.dart';
import '../../../../core/constants/app_colors.dart';

class AgentListItemWidget extends StatelessWidget {
  final AgentModel agent;

  const AgentListItemWidget({
    super.key,
    required this.agent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Only navigate to detail screen if agent status is delivered
        if (agent.isDelivered) {
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
          // Add shadow for better UX
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Agent Name : ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          agent.agentName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'Agent ID : ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        agent.agentId,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'Device Status : ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                ],
              ),
            ),
            // Add arrow icon for delivered agents to indicate clickability
            if (agent.isDelivered)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isPending = agent.isPending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending
            ? AppColors.grey.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending ? Icons.access_time : Icons.check_circle,
            size: 14,
            color: isPending ? AppColors.grey : AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            isPending ? 'Pending' : 'Delivered',
            style: TextStyle(
              fontSize: 12,
              color: isPending ? AppColors.grey : AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}