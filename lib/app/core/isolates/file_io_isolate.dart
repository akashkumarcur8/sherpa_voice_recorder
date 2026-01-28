import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Isolate for file I/O operations
/// Offloads file reading from main thread to prevent UI blocking
class FileIoIsolate {
  /// Read entire file in isolate
  static Future<Uint8List> readFile(String filePath) async {
    return await compute(_readFileBytes, filePath);
  }
  
  static Uint8List _readFileBytes(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return Uint8List(0);
    }
    return file.readAsBytesSync();
  }
  
  /// Read file range in isolate
  static Future<List<int>> readFileRange(FileRangeParams params) async {
    return await compute(_readFileRangeBytes, params);
  }
  
  static List<int> _readFileRangeBytes(FileRangeParams params) {
    final file = File(params.filePath);
    if (!file.existsSync()) {
      return [];
    }
    
    final bytes = file.readAsBytesSync();
    
    if (params.end != null) {
      return bytes.sublist(params.start, params.end);
    } else {
      return bytes.sublist(params.start);
    }
  }
  
  /// Get file size in isolate
  static Future<int> getFileSize(String filePath) async {
    return await compute(_getFileSizeSync, filePath);
  }
  
  static int _getFileSizeSync(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return 0;
    }
    return file.lengthSync();
  }
}

/// Parameters for file range reading
class FileRangeParams {
  final String filePath;
  final int start;
  final int? end;
  
  FileRangeParams({
    required this.filePath,
    required this.start,
    this.end,
  });
}
