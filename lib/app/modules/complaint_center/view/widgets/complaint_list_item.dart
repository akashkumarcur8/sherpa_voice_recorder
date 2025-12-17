import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/complaint_model.dart';

class ComplaintListItem extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintListItem({
    Key? key,
    required this.complaint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Complaint ID', complaint.complaintId),
          const SizedBox(height: 8),
          _buildRow('Agent Name', complaint.agentName),
          const SizedBox(height: 8),
          _buildRow('Agent ID', complaint.agentId),
          const SizedBox(height: 8),
          _buildRow(
            'Date & Time',
            DateFormat('dd MMM yyyy \'at\' hh:mm a').format(complaint.dateTime),
          ),
          const SizedBox(height: 8),
          _buildRow('Issue Raised', complaint.issueRaised),
          const SizedBox(height: 8),
          _buildDescriptionRow('Description', complaint.description),
          const SizedBox(height: 8),
          _buildStatusBadge(complaint.status),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label :',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPending = status.toLowerCase() == 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPending
            ? Colors.orange.shade50
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending
              ? Colors.orange.shade300
              : Colors.green.shade300,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPending
              ? Colors.orange.shade700
              : Colors.green.shade700,
        ),
      ),
    );
  }
}