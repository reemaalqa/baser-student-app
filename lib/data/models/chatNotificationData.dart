// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'chatMessage.dart';
import 'chatUser.dart';

/*
this is a general data model to get data of chat message or user when a notification arrives
this model is not connected to any API response
it's internally used, currently used to stream it's instances when a chat notification arrives
also useful to get data of notifications that came while in background
*/
class ChatNotificationData {
  ChatMessage receivedMessage;
  ChatUser fromUser;
  ChatNotificationData(
    this.receivedMessage,
    this.fromUser,
  );

  factory ChatNotificationData.fromRemoteMessage(
      {required RemoteMessage remoteMessage}) {
    final data = jsonDecode(remoteMessage.data['sender_info']);
    return ChatNotificationData(ChatMessage.fromJsonAPI(data['last_message']),
        ChatUser.fromJsonAPI(data));
  }

  ChatNotificationData copyWith({
    ChatMessage? receivedMessage,
    ChatUser? fromUser,
  }) {
    return ChatNotificationData(
      receivedMessage ?? this.receivedMessage,
      fromUser ?? this.fromUser,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'receivedMessage': receivedMessage.toMap(),
      'fromUser': fromUser.toMap(),
    };
  }

  factory ChatNotificationData.fromMap(Map<String, dynamic> map) {
    return ChatNotificationData(
      ChatMessage.fromMap(map['receivedMessage'] as Map<String, dynamic>),
      ChatUser.fromMap(map['fromUser'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatNotificationData.fromJson(String source) =>
      ChatNotificationData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ChatNotificationData(receivedMessage: $receivedMessage, fromUser: $fromUser)';
}
