

enum DeviceStatus { pending, delivered }

class AgentModel {
  final String agentName;
  final String agentId;
  final String userId;
  final DeviceStatus deviceStatus;


  AgentModel({
    required this.agentName,
    required this.agentId,
    required this.userId,
    required this.deviceStatus,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      agentName: json['agentName'] ?? '',
      agentId: json['agentId'] ?? '',
      userId: json['userId'] ?? '',
      deviceStatus: json['deviceStatus'] == 'delivered'
          ? DeviceStatus.delivered
          : DeviceStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentName': agentName,
      'agentId': agentId,
      'userId': userId,
      'deviceStatus':
      deviceStatus == DeviceStatus.delivered ? 'delivered' : 'pending',
    };
  }

  AgentModel copyWith({
    String? agentName,
    String? agentId,
    String? userId,
    DeviceStatus? deviceStatus,
  }) {
    return AgentModel(
      agentName: agentName ?? this.agentName,
      agentId: agentId ?? this.agentId,
      userId: userId ?? this.userId,
      deviceStatus: deviceStatus ?? this.deviceStatus,
    );
  }

  bool get isPending => deviceStatus == DeviceStatus.pending;
  bool get isDelivered => deviceStatus == DeviceStatus.delivered;
}