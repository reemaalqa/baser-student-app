// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:eschool/utils/uiUtils.dart';

import '../../utils/constants.dart';

enum ChatMessageType {
  textMessage,
  imageMessage,
  fileMessage,
}

class ChatMessage {
  int id;
  DateTime sendOrReceiveDateTime;
  int senderId;
  bool isLocallyStored;
  String message;
  ChatMessageType messageType;
  List<String> files;
  ChatMessage({
    required this.id,
    required this.sendOrReceiveDateTime,
    required this.senderId,
    required this.isLocallyStored,
    required this.message,
    required this.files,
    this.messageType = ChatMessageType.textMessage,
  });

  //this constructor will return proper message type according to the data provided
  factory ChatMessage.fromJsonAPI(Map json) {
    logger.i(json);
    ChatMessageType messageType = ChatMessageType.textMessage;
    if (json['files']?.isNotEmpty ?? false) {
      //if there is a single file that's not image
      if (!((json['files'] as List).any((e) => e.toString().isImage()))) {
        messageType = ChatMessageType.fileMessage;
      } else {
        messageType = ChatMessageType.imageMessage;
      }
    }
    return ChatMessage(
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ??
          <String>[],
      id: json['id'] ?? 0,
      message: json['body'] ?? "",
      messageType: messageType,
      sendOrReceiveDateTime:
          DateTime.tryParse(json['date'].toString())?.toLocal() ??
              DateTime.now(),
      senderId: int.parse((json['sender_id'] ?? 0).toString()),
      isLocallyStored: false,
    );
  }

  ChatMessage copyWith({
    int? id,
    DateTime? sendOrReceiveDateTime,
    int? senderId,
    bool? isLocallyStored,
    String? message,
    List<String>? files,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sendOrReceiveDateTime:
          sendOrReceiveDateTime ?? this.sendOrReceiveDateTime,
      senderId: senderId ?? this.senderId,
      isLocallyStored: isLocallyStored ?? this.isLocallyStored,
      message: message ?? this.message,
      files: files ?? this.files,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sendOrReceiveDateTime': sendOrReceiveDateTime.millisecondsSinceEpoch,
      'senderId': senderId,
      'isLocallyStored': isLocallyStored,
      'message': message,
      'files': files,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int,
      sendOrReceiveDateTime: DateTime.fromMillisecondsSinceEpoch(
          map['sendOrReceiveDateTime'] as int),
      senderId:int.parse((map['sender_id'] ?? 0).toString()),
      isLocallyStored: map['isLocallyStored'] as bool,
      message: map['message'] as String,
      files:
          (map['files'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatMessage(id: $id, sendOrReceiveDateTime: $sendOrReceiveDateTime, senderId: $senderId, isLocallyStored: $isLocallyStored, message: $message, files: $files)';
  }
}
