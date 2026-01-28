import 'package:intl/intl.dart';

class ConversationSession {
  final String clientId;
  final List<String> productNames;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isMarked;

  ConversationSession({
    required this.clientId,
    required this.productNames,
    this.startTime,
    this.endTime,
    required this.isMarked,
  });

  factory ConversationSession.fromJson(
      Map<String, dynamic> json, {
        required bool isMarked,
      }) {
    // Safely toString() these
    final clientIdRaw = json['client_id'];
    final productsRaw = json['product_names'];

    // Build List<String>
    final productNames = <String>[];
    if (productsRaw is List) {
      for (var p in productsRaw) {
        if (p != null) productNames.add(p.toString());
      }
    }

    // Helper that returns null on null, else tries ISO → time-only
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      var s = raw.toString().trim();

      // normalize lowercase “t” to uppercase “T”
      s = s.replaceFirstMapped(
        RegExp(r'^(\d{4}-\d{2}-\d{2})[tT](\d{2}:\d{2}:\d{2})$'),
            (m) => '${m[1]}T${m[2]}',
      );

      // full ISO?
      final iso = DateTime.tryParse(s);
      if (iso != null) return iso;

      // fallback to HH:mm:ss → attach today’s date
      try {
        final t = DateFormat('HH:mm:ss').parseLoose(s);
        final now = DateTime.now();
        return DateTime(
          now.year, now.month, now.day, t.hour, t.minute, t.second,
        );
      } catch (_) {
        // final fallback: null
        return null;
      }
    }

    return ConversationSession(
      clientId: clientIdRaw?.toString() ?? '',
      productNames: productNames,
      startTime: parseDate(json['conversation_start_time']),
      endTime:   parseDate(json['conversation_end_time']),
      isMarked:  isMarked,
    );
  }
}
