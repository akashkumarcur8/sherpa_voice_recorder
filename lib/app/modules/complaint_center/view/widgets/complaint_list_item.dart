import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/complaint_model.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'ticket_details_bottom_sheet.dart';

class ComplaintListItem extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintListItem({
    super.key,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        TicketDetailsBottomSheet.show(context, complaint);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE5E5EA), // Gray 5
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Agent name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    complaint.agentName,
                    style: AppTextStyles.interSemiBold14.copyWith(
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                _buildStatusBadge(complaint.status),
              ],
            ),
            const SizedBox(height: 8),
            // Complaint ID
            Text(
              complaint.complaintId,
              style: AppTextStyles.interRegular12.copyWith(
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            // Date and time
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(complaint.dateTime),
              style: AppTextStyles.interRegular12.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            // Issue description
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Issue: ',
                    style: AppTextStyles.interSemiBold14.copyWith(
                      color: Colors.grey.shade800,
                    ),
                  ),
                  TextSpan(
                    text: complaint.issueRaised,
                    style: AppTextStyles.interRegular12.copyWith(
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusLower = status.toLowerCase();
    final isPending = statusLower == 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending
            ? const Color(0xFFFFE5CC) // Light orange
            : const Color(0xFFE8F5E9), // Light green
        borderRadius: BorderRadius.circular(6), // Less rounded edges
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isPending
                  ? const Color(0xFFFF9800) // Orange
                  : const Color(0xFF4CAF50), // Green
              shape: BoxShape.circle, // Circle shape
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.isEmpty
                ? status
                : status[0].toUpperCase() + status.substring(1).toLowerCase(),
            style: TextStyle(
              fontFamily: AppTextStyles.inter,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: isPending
                  ? const Color(0xFFFF8D28) // Accent orange
                  : const Color(0xFF4CAF50), // Green
            ),
          ),
        ],
      ),
    );
  }
}
