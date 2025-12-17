import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as dbPath;
import 'package:sqflite/sqflite.dart';

import '../../../data/model/statistics_data_model.dart';
class DatabaseHelper {
  /// Database configuration
  static final String _databaseName = "sherpa.db";
  static final int _databaseVersion = 1;

  /// Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Get or initialize the database
  Future<Database?> get database async {
    if (_database != null) return _database;

    // Get the path to the document directory
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = dbPath.join(documentsDirectory.path, _databaseName);
    print("Database path: $path"); // 👈 Add this line

    // Open the database
    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );

    return _database;
  }

  /// Called only once when the database is created
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(StatisticsDataModel.createTable);
    // await db.execute(ConversationSummaryModel.createTable);


  }


  static Future<void> insertOrUpdateStats(StatisticsDataModel stats) async {
    final db = await DatabaseHelper().database;

    // Check if a row already exists for the given userId and date
    final existing = await db!.query(
      'statistics_data',
      where: 'userId = ? AND date = ?',
      whereArgs: [stats.userId, stats.date],
    );

    if (existing.isNotEmpty) {
      // If found, update the record
      int count = await db.update(
        'statistics_data',
        {
          'totalRecordingHours': stats.totalRecordingHours,
          'totalQualityAudioHours': stats.totalQualityAudioHours,
           'numberOfSyncs': stats.numberOfSyncs,
          'last_sync': stats.last_sync,
           'numberOfDisconnects':stats.numberOfDisconnects,
          'conversationCount': stats.conversationCount,
        },
        where: 'userId = ? AND date = ?',
        whereArgs: [stats.userId, stats.date],
      );
      print('Updated $count row(s)');
    } else {
      // If not found, insert a new row
      int id = await db.insert(
        'statistics_data',
        stats.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted row ID: $id');
    }
  }


  static Future<StatisticsDataModel?> getStats(int userId, String date) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'statistics_data',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'last_sync DESC', // Ensure latest one is picked if duplicates exist
    );



    if (maps.isNotEmpty) {
      return StatisticsDataModel.fromMap(maps.first);
    }
    return null;
  }




  // Future<void> incrementDisconnectCount(DateTime date) async {
  //   final database = await DatabaseHelper().database;
  //   final dateString = DateFormat('yyyy-MM-dd').format(date);
  //
  //   // 1. Try to fetch existing count
  //   final result = await database!.query(
  //     'statistics_data',
  //     columns: ['numberOfDisconnects'],
  //     where: 'date = ?',
  //     whereArgs: [dateString],
  //   );
  //
  //   if (result.isNotEmpty) {
  //     // 2a. If exists, increment
  //     final current = result.first['numberOfDisconnects'] as int;
  //     await database.update(
  //       'statistics_data',
  //       {'numberOfDisconnects': current + 0},
  //       where: 'date = ?',
  //       whereArgs: [dateString],
  //     );
  //   } else {
  //     // 2b. Otherwise insert new row
  //     await database.insert(
  //       'statistics_data',
  //       {
  //         'date': dateString,
  //         'numberOfDisconnects': 1,
  //       },
  //     );
  //   }
  // }







}
