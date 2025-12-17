class StatisticsDataModel {
  int? local_id;
  int userId;
  String date;
  String totalRecordingHours;
  String totalQualityAudioHours;
  int numberOfDisconnects;
  int numberOfSyncs;
  String last_sync;
  int conversationCount;



  StatisticsDataModel({
    this.local_id,
    required this.userId,
    required this.date,
    required this.totalRecordingHours,
    required this.totalQualityAudioHours,
    required this.numberOfDisconnects,
    required this.numberOfSyncs,
    required this.last_sync,
    required this.conversationCount,
  });

  factory StatisticsDataModel.fromMap(Map<String, dynamic> json) => StatisticsDataModel(
    local_id: json["local_id"] ?? " ",
    userId: json["userId"] ?? 0,
    date: json["date"] ?? "",
    totalRecordingHours: json["totalRecordingHours"] ?? "",
    totalQualityAudioHours: json["totalQualityAudioHours"] ?? "",
    numberOfDisconnects: json["numberOfDisconnects"] ?? 0,
    numberOfSyncs: json["numberOfSyncs"] ?? 0,
    last_sync: json["last_sync"] ?? "",
    conversationCount: json["conversationCount"] ?? 0,


  );

  Map<String, dynamic> toMap() => {
    "local_id": local_id,
    "userId": userId,
    "date": date,
    "totalRecordingHours": totalRecordingHours,
    "totalQualityAudioHours": totalQualityAudioHours,
    "numberOfDisconnects": numberOfDisconnects,
    "numberOfSyncs": numberOfSyncs,
    "last_sync": last_sync,
    "conversationCount": conversationCount,
  };

  Map<String, dynamic> toJson() => {
    "local_id": local_id,
    "userId": userId,
    "date": date,
    "totalRecordingHours": totalRecordingHours,
    "totalQualityAudioHours": totalQualityAudioHours,
    "numberOfDisconnects": numberOfDisconnects,
    "numberOfSyncs": numberOfSyncs,
    "last_sync": last_sync,
    "conversationCount": conversationCount,
  };

  static const String tableName = "statistics_data";

  static const String COLUMN_local_id = "local_id";
  static const String COLUMN_userId = "userId";
  static const String COLUMN_date = "date";
  static const String COLUMN_totalRecordingHours = "totalRecordingHours";
  static const String COLUMN_totalQualityAudioHours = "totalQualityAudioHours";
  static const String COLUMN_numberOfDisconnects = "numberOfDisconnects";
  static const String COLUMN_numberOfSyncs = "numberOfSyncs";
  static const String COLUMN_last_sync = "last_sync";
  static const String COLUMN_conversationCount = "conversationCount";

  static const String createTable = "CREATE TABLE $tableName ("
      "$COLUMN_local_id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "$COLUMN_userId INTEGER, "
      "$COLUMN_date TEXT, "
      "$COLUMN_totalRecordingHours TEXT, "
      "$COLUMN_totalQualityAudioHours TEXT, "
      "$COLUMN_numberOfDisconnects INTEGER, "
      "$COLUMN_numberOfSyncs INTEGER, "
      "$COLUMN_conversationCount INTEGER, "
      "$COLUMN_last_sync TEXT"
      ")";
}
