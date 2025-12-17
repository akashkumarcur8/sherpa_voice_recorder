class TicketQuery {
  final String id;
  final String title;

  TicketQuery({
    required this.id,
    required this.title,
  });

  factory TicketQuery.fromJson(Map<String, dynamic> json) {
    return TicketQuery(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class TicketQueryData {
  // Dummy data for queries
  static List<TicketQuery> getDummyQueries() {
    return [
      TicketQuery(id: '1', title: 'Device not powering on'),
      TicketQuery(id: '2', title: 'App not responding'),
      TicketQuery(id: '3', title: 'Audio test failed'),
      TicketQuery(id: '4', title: 'Received physically damage'),
      TicketQuery(id: '5', title: 'Others'),
    ];
  }
}