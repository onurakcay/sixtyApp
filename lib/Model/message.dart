import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String from;
  final String to;
  final bool fromMe;
  final String message;
  final Timestamp date;

  Message({this.from, this.to, this.fromMe, this.message, this.date});

  Map<String, dynamic> toMap() {
    return {
      "from": from,
      "to": to,
      "fromMe": fromMe,
      "message": message,
      "date": date ?? Timestamp.now(),
    };
  }

  Message.fromMap(Map<String, dynamic> map)
      : from = map['from'],
        to = map['to'],
        fromMe = map['fromMe'],
        message = map['message'],
        date = map['date'];

  @override
  String toString() {
    return 'Message{from: $from, to: $to, fromMe: $fromMe, message: $message, date: $date}';
  }
}
