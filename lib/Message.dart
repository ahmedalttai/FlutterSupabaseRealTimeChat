

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
    return rows
        .map<Message>((row) => Message(
      id: row['id'] as int,
      userId: (row['sender'] as int).toString(),
      insertedAt: DateTime.parse(row['created_at'] as String),
      message: row['content'] as String, mtype: row['mtype'] as int,
    ))
        .toList();
  }
}

class ChatUser {
  final String id;
  final String name;

  ChatUser({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory ChatUser.fromMap(dynamic map) {


    return ChatUser(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}