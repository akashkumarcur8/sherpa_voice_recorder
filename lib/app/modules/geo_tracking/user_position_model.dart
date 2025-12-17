import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final int userId;
  final String name;
  final double latitude, longitude;
  final DateTime lastSeen;
  final String address;
  final String emailid;

  UserLocation({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.lastSeen,
    required this.address,
    required this.emailid,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory UserLocation.fromJson(Map<String, dynamic> j) => UserLocation(
    userId: j['userid'],
    name: j['fullname'],
    latitude: j['latitude'],
    longitude: j['longitude'],
    lastSeen: DateTime.parse(j['timestamp']),
    address: j['address'],
    emailid: j['email_id'],
  );
}

class CallSummary {
  final String title, body;
  CallSummary({required this.title, required this.body});
  factory CallSummary.fromJson(Map<String, dynamic> j) => CallSummary(
    title: j['title'],
    body: j['body'],
  );
}

class HistoryEntry {
  final LatLng position;
  final DateTime timestamp;
  HistoryEntry({required this.position, required this.timestamp});
  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
    position: LatLng(j['lat'], j['lng']),
    timestamp: DateTime.parse(j['timestamp']),
  );
}

enum DestinationStatus { upcoming, visited }

class Destination {
  final int id;
  final String address;
  final LatLng position;
  final DateTime scheduledArrival;
  final int etaMinutes;
  final DestinationStatus status;

  Destination({
    required this.id,
    required this.address,
    required this.position,
    required this.scheduledArrival,
    required this.etaMinutes,
    required this.status,
  });

  factory Destination.fromJson(Map<String, dynamic> j) => Destination(
    id: j['id'],
    address: j['address'],
    position: LatLng(j['lat'], j['lng']),
    scheduledArrival: DateTime.parse(j['scheduledArrival']),
    etaMinutes: j['etaMinutes'],
    status: j['status'] == 'upcoming'
        ? DestinationStatus.upcoming
        : DestinationStatus.visited,
  );
}

class AgentDetail {
  final int userId;
  final String name;
  final String status;
  final DateTime lastSeen;
  final CallSummary lastCallSummary;
  final List<HistoryEntry> history;
  final List<Destination> destinations;

  AgentDetail({
    required this.userId,
    required this.name,
    required this.status,
    required this.lastSeen,
    required this.lastCallSummary,
    required this.history,
    required this.destinations,
  });

  factory AgentDetail.fromJson(Map<String, dynamic> j) => AgentDetail(
    userId: j['userId'],
    name: j['name'],
    status: j['status'],
    lastSeen: DateTime.parse(j['lastSeen']),
    lastCallSummary: CallSummary.fromJson(j['lastCallSummary']),
    history: (j['history'] as List)
        .map((e) => HistoryEntry.fromJson(e))
        .toList(),
    destinations: (j['destinations'] as List)
        .map((e) => Destination.fromJson(e))
        .toList(),
  );
}
