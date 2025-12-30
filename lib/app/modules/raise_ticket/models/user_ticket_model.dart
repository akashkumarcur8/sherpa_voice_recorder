class UserTicketModel {
  final String ticketId;
  final DateTime dateTime;
  final String issueRaised;
  final String description;
  final String status;
  final String? agentId; // Optional, may not be in list response

  UserTicketModel({
    required this.ticketId,
    required this.dateTime,
    required this.issueRaised,
    required this.description,
    required this.status,
    this.agentId,
  });

  factory UserTicketModel.fromJson(Map<String, dynamic> json) {
    return UserTicketModel(
      ticketId: json['ticket_id'] ?? json['ticketId'] ?? json['complaintId'] ?? '',
      dateTime: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['dateTime'] != null
              ? DateTime.parse(json['dateTime'])
              : DateTime.now()),
      issueRaised: json['issue_title'] ?? json['issueRaised'] ?? '',
      description: json['issue_description'] ?? json['description'] ?? '',
      status: json['status'] ?? 'pending',
      agentId: json['agent_id']?.toString() ?? json['agentId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'created_at': dateTime.toIso8601String(),
      'issue_title': issueRaised,
      'issue_description': description,
      'status': status,
      if (agentId != null) 'agent_id': agentId,
    };
  }
}

