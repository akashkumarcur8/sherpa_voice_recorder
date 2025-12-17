

enum DeviceStatus { pending, delivered }

class AgentModel {
  final String agentName;
  final String agentId;
  final DeviceStatus deviceStatus;

  AgentModel({
    required this.agentName,
    required this.agentId,
    required this.deviceStatus,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      agentName: json['agentName'] ?? '',
      agentId: json['agentId'] ?? '',
      deviceStatus: json['deviceStatus'] == 'delivered'
          ? DeviceStatus.delivered
          : DeviceStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentName': agentName,
      'agentId': agentId,
      'deviceStatus':
      deviceStatus == DeviceStatus.delivered ? 'delivered' : 'pending',
    };
  }

  AgentModel copyWith({
    String? agentName,
    String? agentId,
    DeviceStatus? deviceStatus,
  }) {
    return AgentModel(
      agentName: agentName ?? this.agentName,
      agentId: agentId ?? this.agentId,
      deviceStatus: deviceStatus ?? this.deviceStatus,
    );
  }

  bool get isPending => deviceStatus == DeviceStatus.pending;
  bool get isDelivered => deviceStatus == DeviceStatus.delivered;
}