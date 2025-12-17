class ComplaintModel {
  final String agentName;
  final String agentId;
  final String complaintId;
  final DateTime dateTime;
  final String issueRaised;
  final String description;
  final String status;

  ComplaintModel({
    required this.agentName,
    required this.agentId,
    required this.complaintId,
    required this.dateTime,
    required this.issueRaised,
    required this.description,
    required this.status,
  });

  factory ComplaintModel.fromJson(Map json) {
    return ComplaintModel(
      agentName: json['agentName'] ?? 'N/A',
      agentId: json['agentId']?.toString() ?? 'N/A',
      complaintId: json['complaintId'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      issueRaised: json['issueRaised'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map toJson() {
    return {
      'agentName': agentName,
      'agentId': agentId,
      'complaintId': complaintId,
      'dateTime': dateTime.toIso8601String(),
      'issueRaised': issueRaised,
      'description': description,
      'status': status,
    };
  }
}