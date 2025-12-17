




class TodayAnalytics {
  final int callCount;
  final int avgScore;
  TodayAnalytics({ required this.callCount, required this.avgScore });

  // accept a possibly-null map
  factory TodayAnalytics.fromJson(Map<String, dynamic>? j) {
    j ??= <String,dynamic>{};
    return TodayAnalytics(
      callCount: j['callCount'] is int
          ? j['callCount'] as int
          : int.tryParse(j['callCount']?.toString() ?? '') ?? 0,
      avgScore: j['avgScore'] is int
          ? j['avgScore'] as int
          : int.tryParse(j['avgScore']?.toString() ?? '') ?? 0,
    );
  }
}

class ScoreHistory {
  final String day;
  final String date;
  final int score;
  ScoreHistory({
    required this.day,
    required this.date,
    required this.score,
  });

  factory ScoreHistory.fromJson(Map<String, dynamic>? j) {
    j ??= <String,dynamic>{};
    return ScoreHistory(
      day:  j['day']?.toString()  ?? '',
      date: j['date']?.toString() ?? '',
      // "score" is sometimes null or a string
      score: int.tryParse(j['score']?.toString() ?? '') ?? 0,
    );
  }
}

class AgentAnalytics {
  final int callCount;
  final int avgScore;
  final List<ScoreHistory> scoreHistory;

  AgentAnalytics({
    required this.callCount,
    required this.avgScore,
    required this.scoreHistory,
  });

  // also accept a nullable map
  factory AgentAnalytics.fromJson(Map<String, dynamic>? j) {
    j ??= <String,dynamic>{};
    final rawList = j['scoreHistory'] as List<dynamic>? ?? [];
    return AgentAnalytics(
      callCount: j['callCount'] is int
          ? j['callCount'] as int
          : int.tryParse(j['callCount']?.toString() ?? '') ?? 0,
      avgScore: j['avgScore'] is int
          ? j['avgScore'] as int
          : int.tryParse(j['avgScore']?.toString() ?? '') ?? 0,
      scoreHistory: rawList
          .map((e) => ScoreHistory.fromJson(e as Map<String, dynamic>?))
          .toList(),
    );
  }
}

class OverallScores {
  final int agentScore;
  final int avgProductScore;
  final int avgBehaviorScore;

  OverallScores({
    required this.agentScore,
    required this.avgProductScore,
    required this.avgBehaviorScore,
  });

  factory OverallScores.fromJson(Map<String, dynamic>? j) {
    j ??= <String,dynamic>{};
    return OverallScores(
      agentScore:      j['agentScore'] is int
          ? j['agentScore'] as int
          : int.tryParse(j['agentScore']?.toString() ?? '') ?? 0,
      avgProductScore: j['avgProductScore'] is int
          ? j['avgProductScore'] as int
          : int.tryParse(j['avgProductScore']?.toString() ?? '') ?? 0,
      avgBehaviorScore:j['avgBehaviorScore'] is int
          ? j['avgBehaviorScore'] as int
          : int.tryParse(j['avgBehaviorScore']?.toString() ?? '') ?? 0,
    );
  }
}

class AnalyticsData {
  final TodayAnalytics  today;
  final AgentAnalytics  agent;
  final OverallScores   overall;

  AnalyticsData({
    required this.today,
    required this.agent,
    required this.overall,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic>? j) {
    j ??= <String,dynamic>{};
    return AnalyticsData(
      today:   TodayAnalytics.fromJson(j['todayAnalytics'] as Map<String,dynamic>?),
      agent:   AgentAnalytics.fromJson(j['agentAnalytics']  as Map<String,dynamic>?),
      overall: OverallScores.fromJson(j['overallScores']   as Map<String,dynamic>?),
    );
  }
}

