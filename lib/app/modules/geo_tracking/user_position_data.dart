import 'dart:convert';
import 'package:mice_activeg/app/modules/geo_tracking/user_position_model.dart';
const _usersJson =
'''
[
  {
    "userId": 1,
    "name": "Rajeev Butola",
    "latitude": 28.4595,
    "longitude": 77.0266,
    "lastSeen": "2025-07-31T14:29:50Z",
    "address": "Imperia Mindspace, Sector 62"
  },
  {
    "userId": 2,
    "name": "Love Mittal",
    "latitude": 27.1767,
    "longitude": 78.0081,
    "lastSeen": "2025-07-31T12:00:00Z",
    "address": "Worldmark, Sector 64"
  },
  
  
   {
    "userId": 3,
    "name": "Akash Kumar",
    "latitude": 25.6093,
    "longitude": 85.1239,
    "lastSeen": "2025-07-31T14:29:50Z",
    "address": "Imperia Mindspace, Sector 62"
  },
  {
    "userId": 4,
    "name": "Suraj Singh",
    "latitude": 23.2665,
    "longitude": 77.4131,
    "lastSeen": "2025-07-31T12:00:00Z",
    "address": "Worldmark, Sector 64"
  }
]
''';

const _agentJson = '''
{
  "userId": 1,
  "name": "Rajeev Butola",
  "status": "online",
  "lastSeen": "2025-07-31T14:29:50Z",
  "lastCallSummary": {
    "title": "Last Call Summary",
    "body": "The responses showed empathy..."
  },
  "history": [
    { "lat": 28.4595, "lng": 77.0266, "timestamp": "2025-07-31T14:00:00Z" },
    { "lat": 28.4600, "lng": 77.0270, "timestamp": "2025-07-31T14:10:00Z" },
    { "lat": 28.4605, "lng": 77.0275, "timestamp": "2025-07-31T14:20:00Z" }
  ],
  "destinations": [
    {
      
      "address": "Paras Trinity, Sector 61",
      "lat": 28.4620,
      "lng": 77.0250,
      "scheduledArrival": "2025-07-31T10:30:00Z",
      "etaMinutes": 7,
      "status": "upcoming"
    },
    {
 
      "address": "Sohna Road, Sector 68",
      "lat": 28.4602,
      "lng": 77.0272,
      "scheduledArrival": "2025-07-31T11:09:00Z",
      "etaMinutes": 12,
      "status": "visited"
    },
    {
,
      "address": "Imperia Mindspace, Sector 62",
      "lat": 28.4587,
      "lng": 77.0284,
      "scheduledArrival": "2025-07-31T12:22:00Z",
      "etaMinutes": 16,
      "status": "visited"
    },
    {

      "address": "Worldmark, Sector 64",
      "lat": 28.4573,
      "lng": 77.0291,
      "scheduledArrival": "2025-07-31T18:38:00Z",
      "etaMinutes": 6,
      "status": "visited"
    }
  ]
}
''';

List<UserLocation> loadUsers() {
  final list = jsonDecode(_usersJson) as List;
  return list.map((e) => UserLocation.fromJson(e)).toList();
}

AgentDetail loadAgentDetail() {
  final map = jsonDecode(_agentJson) as Map<String, dynamic>;
  return AgentDetail.fromJson(map);
}
