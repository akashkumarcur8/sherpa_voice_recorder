import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart'; // For parsing the JSON string

class AgentLocationDetail {
  final String name;
  final List<History> history;
  final List<Destination> destinations;
  final CallSummary lastCallSummary;

  AgentLocationDetail({
    required this.name,
    required this.history,
    required this.destinations,
    required this.lastCallSummary,
  });

  factory AgentLocationDetail.fromJson(Map<String, dynamic> json) {
    var historyList = json['history'] as List;
    var destinationsList = json['destinations'] as List;

    return AgentLocationDetail(
      name: json['fullname'] ?? '', // Provide a default value if name is null
      history: historyList.map((i) => History.fromJson(i)).toList(),
      destinations: destinationsList.map((i) => Destination.fromJson(i)).toList(),
      lastCallSummary: CallSummary.fromJson(json), // Pass the whole json to CallSummary
    );
  }
}

class History {
  final double lat;
  final double lng;
  final String firstSeen;
  final String lastSeen;
  String? address; // Add address field to store the fetched address

  History({
    required this.lat,
    required this.lng,
    required this.firstSeen,
    required this.lastSeen,
    this.address, // Address can be nullable
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      lat: json['lat'],
      lng: json['lng'],
      firstSeen: json['first_seen'],
      lastSeen: json['last_seen'],
      address: null, // Initially null, will be updated after fetching the address
    );
  }

  // Adding position as a getter for convenience
  LatLng get position => LatLng(lat, lng);
}


class Destination {
  final String scheduledArrival;
  final String status;
  final double lat;
  final double lng;
  String? address; // Nullable address field, it will be updated after fetching the address

  Destination({
    required this.scheduledArrival,
    required this.status,
    required this.lat,
    required this.lng,
    this.address, // Address is now nullable
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      scheduledArrival: json['scheduledArrival'] ?? '', // Default to an empty string if null
      status: json['status'] ?? '', // Default to an empty string if null
      lat: (json['lat'] != null) ? json['lat'].toDouble() : 0.0, // Default to 0.0 if lat is null
      lng: (json['lng'] != null) ? json['lng'].toDouble() : 0.0, // Default to 0.0 if lng is null
      address: null, // Initially null, will be updated after fetching the address
    );
  }

  // Adding position as a getter for convenience
  LatLng get position => LatLng(lat, lng);
}


class CallSummary {
  final String title;
  final String body;

  CallSummary({required this.title, required this.body});

  factory CallSummary.fromJson(Map<String, dynamic> json) {
    // Parse the 'call_summary' string if it is a string
    String? callSummaryStr = json['call_summary'];
    Map<String, dynamic> callSummary = {};

    if (callSummaryStr != null && callSummaryStr.isNotEmpty) {
      // Decode the JSON string into a Map
      try {
        callSummary = jsonDecode(callSummaryStr);
      } catch (e) {
      }
    }

    // Now extract the summary fields
    Map<String, dynamic> summary = callSummary['summary'] ?? {};
    String title = summary['title'] ?? '';
    String body = summary['value'] ?? '';

    return CallSummary(
      title: title,
      body: body,
    );
  }
}
