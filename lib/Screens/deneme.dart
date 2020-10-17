import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chat_owner;
  final String talking_to;
  final String last_sent_message;
  final bool seen;
  final Timestamp created_at;
  final Timestamp seen_date;

  Chat(
      {this.chat_owner,
        this.talking_to,
        this.last_sent_message,
        this.seen,
        this.created_at,
        this.seen_date});

  Map<String, dynamic> toMap() {
    return {
      "chat_owner": chat_owner,
      "talking_to": talking_to,
      "last_sent_message": last_sent_message ?? Timestamp.now(),
      "seen": seen,
      "created_at": created_at ?? Timestamp.now(),
    };
  }

  Chat.fromMap(Map<String, dynamic> map)
      : chat_owner = map['chat_owner'],
        talking_to = map['talking_to'],
        last_sent_message = map['last_sent_message'],
        seen = map['seen'],
        created_at = map['created_at'],
        seen_date = map['seen_date'];

  @override
  String toString() {
    return 'Chat{chat_owner: $chat_owner, talking_to: $talking_to, last_sent_message: $last_sent_message, seen: $seen, created_at: $created_at, seen_date: $seen_date}';
  }
}
