class ChatUser {
  final String id;
  final String name;

  ChatUser({
    required this.id,
    required this.name,
});

  Map<String,dynamic> toMap() {
    return {
      'id':id,
      'name':name
    };
  }

  factory ChatUser.fromMap(dynamic map) {
    return ChatUser(id: map['id'] as String,
        name: map['name'] as String);
  }
}