

enum DeviceStatus { pending, delivered }

class AgentModel {
  final String agentName;
  final String agentId;
  final String userId;
  final DeviceStatus deviceStatus;
  final String? issueDate; // Optional issue date field

  AgentModel({
    required this.agentName,
    required this.agentId,
    required this.userId,
    required this.deviceStatus,
    this.issueDate,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      agentName: json['agentName'] ?? '',
      agentId: json['agentId'] ?? '',
      userId: json['userId'] ?? '',
      deviceStatus: json['deviceStatus'] == 'delivered'
          ? DeviceStatus.delivered
          : DeviceStatus.pending,
      issueDate: json['issueDate'] ?? json['issue_date'] ?? json['dateOfDeviceDelivery'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentName': agentName,
      'agentId': agentId,
      'userId': userId,
      'deviceStatus':
      deviceStatus == DeviceStatus.delivered ? 'delivered' : 'pending',
      if (issueDate != null) 'issueDate': issueDate,
    };
  }

  AgentModel copyWith({
    String? agentName,
    String? agentId,
    String? userId,
    DeviceStatus? deviceStatus,
    String? issueDate,
  }) {
    return AgentModel(
      agentName: agentName ?? this.agentName,
      agentId: agentId ?? this.agentId,
      userId: userId ?? this.userId,
      deviceStatus: deviceStatus ?? this.deviceStatus,
      issueDate: issueDate ?? this.issueDate,
    );
  }

  bool get isPending => deviceStatus == DeviceStatus.pending;
  bool get isDelivered => deviceStatus == DeviceStatus.delivered;
}