

class AgentDetailModel {
  final String agentId;
  final String agentName;
  final String dateOfDeviceDelivery;
  final List<String> deviceImages;
  final String geotrackingLocation;
  final bool audioQualityTestPassed;
  final String status;

  AgentDetailModel({
    required this.agentId,
    required this.agentName,
    required this.dateOfDeviceDelivery,
    required this.deviceImages,
    required this.geotrackingLocation,
    required this.audioQualityTestPassed,
    required this.status,
  });

  factory AgentDetailModel.fromJson(Map<String, dynamic> json) {
    return AgentDetailModel(
      agentId: json['agentId'] ?? '',
      agentName: json['agentName'] ?? '',
      dateOfDeviceDelivery: json['dateOfDeviceDelivery'] ?? '',
      deviceImages: List<String>.from(json['deviceImages'] ?? []),
      geotrackingLocation: json['geotrackingLocation'] ?? '',
      audioQualityTestPassed: json['audioQualityTestPassed'] ?? false,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'agentName': agentName,
      'dateOfDeviceDelivery': dateOfDeviceDelivery,
      'deviceImages': deviceImages,
      'geotrackingLocation': geotrackingLocation,
      'audioQualityTestPassed': audioQualityTestPassed,
      'status': status,
    };
  }

  AgentDetailModel copyWith({
    String? agentId,
    String? agentName,
    String? dateOfDeviceDelivery,
    List<String>? deviceImages,
    String? geotrackingLocation,
    bool? audioQualityTestPassed,
    String? status,
  }) {
    return AgentDetailModel(
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      dateOfDeviceDelivery: dateOfDeviceDelivery ?? this.dateOfDeviceDelivery,
      deviceImages: deviceImages ?? this.deviceImages,
      geotrackingLocation: geotrackingLocation ?? this.geotrackingLocation,
      audioQualityTestPassed:
      audioQualityTestPassed ?? this.audioQualityTestPassed,
      status: status ?? this.status,
    );
  }
}