import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../models/complaint_model.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';

class TicketDetailsBottomSheet extends StatelessWidget {
  final ComplaintModel complaint;

  const TicketDetailsBottomSheet({
    super.key,
    required this.complaint,
  });

  static void show(BuildContext context, ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketDetailsBottomSheet(complaint: complaint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusLower = complaint.status.toLowerCase();
    final isPending = statusLower == 'pending';

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ticket Details',
                      style: AppTextStyles.interSemiBold14.copyWith(
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    _buildStatusBadge(complaint.status, isPending),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        iconPath: 'asset/icons/agentId.svg',
                        label: 'Agent ID',
                        value: complaint.agentId,
                      ),
                      const SizedBox(height: 16),
                      // Agent Name and Ticket ID in a row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              iconPath: 'asset/icons/person.svg',
                              label: 'Agent Name',
                              value: complaint.agentName,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              iconPath: 'asset/icons/ticket1.svg',
                              label: 'Ticket ID',
                              value: complaint.complaintId,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        iconPath: 'asset/icons/calender.svg',
                        label: 'Date & Time',
                        value: DateFormat('dd MMM yyyy, hh:mm a').format(complaint.dateTime),
                      ),
                      const SizedBox(height: 24),
                      // Complaint Subject
                      Text(
                        complaint.issueRaised,
                        style: AppTextStyles.interSemiBold14.copyWith(
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Complaint Description
                      Text(
                        complaint.description,
                        style: AppTextStyles.interRegular12.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required String iconPath,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.interRegular10.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.interMedium14.copyWith(
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, bool isPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending
            ? const Color(0xFFFFE5CC) // Light orange
            : const Color(0xFFE8F5E9), // Light green
        borderRadius: BorderRadius.circular(6),
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
              shape: BoxShape.circle,
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

