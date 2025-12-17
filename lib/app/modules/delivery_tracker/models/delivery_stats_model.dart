
class DeliveryStatsModel {
  final int pending;
  final int delivered;
  final int totalAgents;

  DeliveryStatsModel({
    required this.pending,
    required this.delivered,
    required this.totalAgents,
  });

  factory DeliveryStatsModel.fromJson(Map<String, dynamic> json) {
    return DeliveryStatsModel(
      pending: json['pending'] ?? 0,
      delivered: json['delivered'] ?? 0,
      totalAgents: json['totalAgents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'delivered': delivered,
      'totalAgents': totalAgents,
    };
  }

  DeliveryStatsModel copyWith({
    int? pending,
    int? delivered,
    int? totalAgents,
  }) {
    return DeliveryStatsModel(
      pending: pending ?? this.pending,
      delivered: delivered ?? this.delivered,
      totalAgents: totalAgents ?? this.totalAgents,
    );
  }
}