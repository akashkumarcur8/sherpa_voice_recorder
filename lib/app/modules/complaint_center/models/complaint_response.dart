import 'complaint_model.dart';

class ComplaintResponse {
  final List pendingComplaints;
  final List resolvedComplaints;
  final Statistics statistics;
  final String message;
  final bool status;

  ComplaintResponse({
    required this.pendingComplaints,
    required this.resolvedComplaints,
    required this.statistics,
    required this.message,
    required this.status,
  });

  factory ComplaintResponse.fromJson(Map json) {
    return ComplaintResponse(
      pendingComplaints: (json['data']['complaints']['pending'] as List?)
          ?.map((e) => ComplaintModel.fromJson(e))
          .toList() ??
          [],
      resolvedComplaints: (json['data']['complaints']['resolved'] as List?)
          ?.map((e) => ComplaintModel.fromJson(e))
          .toList() ??
          [],
      statistics: Statistics.fromJson(json['data']['statistics']),
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class Statistics {
  final int pending;
  final int resolved;
  final int total;

  Statistics({
    required this.pending,
    required this.resolved,
    required this.total,
  });

  factory Statistics.fromJson(Map json) {
    return Statistics(
      pending: json['pending'] ?? 0,
      resolved: json['resolved'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}