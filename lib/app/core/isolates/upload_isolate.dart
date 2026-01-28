import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Isolate for preparing audio upload data
/// This offloads heavy file I/O operations from the main thread
class UploadIsolate {
  /// Prepare upload data in isolate
  /// Reads file chunks in background thread to prevent UI blocking
  static Future<UploadPreparedData> prepareUploadData(UploadParams params) async {
    return await compute(_prepareUploadDataInIsolate, params);
  }
  
  static UploadPreparedData _prepareUploadDataInIsolate(UploadParams params) {
    // Read file chunk in isolate (potentially MBs of data)
    final file = File(params.filePath);
    
    if (!file.existsSync()) {
      return UploadPreparedData(
        bytes: Uint8List(0),
        totalFileSize: 0,
        isEmpty: true,
      );
    }
    
    final totalFileSize = file.lengthSync();
    
    if (totalFileSize <= params.lastPosition) {
      return UploadPreparedData(
        bytes: Uint8List(0),
        totalFileSize: totalFileSize,
        isEmpty: true,
      );
    }
    
    // Read new bytes from last position
    final allBytes = file.readAsBytesSync();
    final newBytes = Uint8List.fromList(
      allBytes.sublist(params.lastPosition)
    );
    
    return UploadPreparedData(
      bytes: newBytes,
      totalFileSize: totalFileSize,
      isEmpty: false,
    );
  }
  
  /// Prepare local data for upload in isolate
  /// Converts List<int> to Uint8List in background thread
  static Future<Uint8List> prepareLocalDataBytes(List<int> fileBytes) async {
    return await compute(_convertToUint8List, fileBytes);
  }
  
  static Uint8List _convertToUint8List(List<int> bytes) {
    return Uint8List.fromList(bytes);
  }
}

/// Parameters for upload preparation
class UploadParams {
  final String filePath;
  final int lastPosition;
  
  UploadParams({required this.filePath, required this.lastPosition});
}

/// Result of upload preparation
class UploadPreparedData {
  final Uint8List bytes;
  final int totalFileSize;
  final bool isEmpty;
  
  UploadPreparedData({
    required this.bytes,
    required this.totalFileSize,
    required this.isEmpty,
  });
}
