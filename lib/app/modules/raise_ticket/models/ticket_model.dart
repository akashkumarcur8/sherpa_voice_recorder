class TicketModel {
  final String? userId;
  final String? managerId;
  final String? companyId;
  final String agentId;
  final String queryId;
  final String queryTitle;
  final String description;
  final DateTime createdAt;
  final String status;

  TicketModel({
    this.userId,
    this.managerId,
    this.companyId,
    required this.agentId,
    required this.queryId,
    required this.queryTitle,
    required this.description,
    DateTime? createdAt,
    this.status = 'pending',
  }) : createdAt = createdAt ?? DateTime.now();

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      agentId: json['agentId'] ?? '',
      queryId: json['queryId'] ?? '',
      queryTitle: json['queryTitle'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'],
      managerId: json['managerId'],
      companyId: json['companyId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'queryId': queryId,
      'queryTitle': queryTitle,
      'description': description,
      'userId': userId,
      'managerId': managerId,
      'companyId': companyId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  TicketModel copyWith({

    String? agentId,
    String? queryId,
    String? queryTitle,
    String? description,
    String? userId,
    String? managerId,
    String? companyId,
    DateTime? createdAt,
    String? status,
  }) {
    return TicketModel(
      agentId: agentId ?? this.agentId,
      queryId: queryId ?? this.queryId,
      queryTitle: queryTitle ?? this.queryTitle,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      managerId: managerId ?? this.managerId,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}