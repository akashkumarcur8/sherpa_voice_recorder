import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Isolate for JSON parsing operations
/// Offloads JSON decoding from main thread to prevent UI blocking
class JsonParserIsolate {
  /// Parse JSON string in isolate
  static Future<Map<String, dynamic>> parse(String jsonString) async {
    return await compute(_parseJson, jsonString);
  }
  
  static Map<String, dynamic> _parseJson(String jsonString) {
    return json.decode(jsonString);
  }
  
  /// Parse JSON array in isolate
  static Future<List<dynamic>> parseList(String jsonString) async {
    return await compute(_parseJsonList, jsonString);
  }
  
  static List<dynamic> _parseJsonList(String jsonString) {
    return json.decode(jsonString) as List<dynamic>;
  }
}
