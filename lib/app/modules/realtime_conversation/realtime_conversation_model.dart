class Session {
  final String sessionId;
  final Report report;
  Session({ required this.sessionId, required this.report });
  factory Session.fromJson(Map<String, dynamic> j) =>
      Session(
        sessionId: j['session_id'],
        report: Report.fromJson(j['report']),
      );



  Session copyWith({ Report? report }) {
    return Session(
      sessionId: sessionId,
      report: report ?? this.report,
    );
  }

}

class Report {
  final String productName;      // ← will now come from products_identified
  final String agentId;
  final DateTime startTime, endTime;
  final List<Category> categories;
  final String callId;           // ← new


  Report({
    required this.productName,
    required this.agentId,
    required this.startTime,
    required this.endTime,
    required this.categories,
    required this.callId,        // ← new

  });

  factory Report.fromJson(Map<String, dynamic> j) {
    // Extract products_identified.value (or NA)
    final slider = j['slider_summary'] as Map<String, dynamic>;
    final rawPid = (slider['products_identified']['value'] as String?)?.trim() ?? '';
    final pid = rawPid.isNotEmpty ? rawPid : 'NA';

    return Report(
      callId: j['call_id'] as String,
      productName: pid,
      agentId: j['agent_id'],
      startTime: DateTime.parse(j['start_time']),
      endTime:   DateTime.parse(j['end_time']),
      categories: (j['categories'] as List)
          .map((c) => Category.fromJson(c))
          .toList(),
    );
  }


  Report copyWith({ String? callId,String? productName }) {
    return Report(
      callId:      callId      ?? this.callId,
      productName: productName ?? this.productName,
      agentId:     agentId,
      startTime:   startTime,
      endTime:     endTime,
      categories:  categories,
    );
  }

}


class Category {
  final String name;
  final List<Subcategory> subcategories;
  Category({ required this.name, required this.subcategories });
  factory Category.fromJson(Map<String, dynamic> j) => Category(
    name: j['name'],
    subcategories: (j['subcategories'] as List)
        .map((s) => Subcategory.fromJson(s))
        .toList(),
  );
}

class Subcategory {
  final String name;
  final String nudges;
  Subcategory({ required this.name, required this.nudges });
  factory Subcategory.fromJson(Map<String, dynamic> j) => Subcategory(
    name: j['name'],
    nudges: j['nudges'] is String ? j['nudges'] : "",
  );
}

