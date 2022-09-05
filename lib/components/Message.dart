class Message {
  final int id;
  final String userId;
  final DateTime insertedAt;
  final String message;
  final int mtype;
  final bool isSending;

  Message({
    required this.id,
    required this.userId,
    required this.insertedAt,
    required this.message,
    required this.mtype,
    this.isSending = false,
});

  static List<Message> fromRows(List<dynamic> rows) {
    return rows.map((row) => Message(id: row['id'] as int,
        userId: (row['sender'] as int).toString(), insertedAt: DateTime.parse(row['created_at'] as String),
        message: row['content'] as String, mtype: row['mtype'] as int)).toList();
  }
}