// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:eschool/data/models/chatMessage.dart';

class ChatUser {
  int id;
  int userId;
  String firstName;
  String lastName;
  String profileUrl;
  List<String> subjectNames;
  ChatMessage? lastMessage;
  String mobileNumber;
  String email;
  String qualification;
  List<String>? classTeacher;
  int unreadCount;
  List<String>? studentNames;

  //getters for the UI
  int get unreadNotificationsCount => unreadCount;
  bool get hasUnreadMessages => unreadNotificationsCount != 0;
  String get classTeacherString =>
      classTeacher
          ?.toString()
          .substring(1, classTeacher.toString().length - 1) ??
          "";
  String get userName => "$firstName $lastName";
  String get subjects =>
      subjectNames.toString().substring(1, subjectNames.toString().length - 1);
  String get studentNamesString =>
      studentNames
          ?.toString()
          .substring(1, studentNames!.toString().length - 1) ??
          "";
  bool get isClassTeacher => subjectNames.isEmpty;

  ChatUser({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profileUrl,
    required this.subjectNames,
    required this.lastMessage,
    required this.mobileNumber,
    required this.email,
    required this.qualification,
    this.classTeacher,
    required this.unreadCount,
    this.studentNames,
  });

  factory ChatUser.fromJsonAPI(Map json) {
    return ChatUser(
      id: json['id'] ?? 0,
      userId: int.parse((json['user_id'] ?? 0).toString()),
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      profileUrl: json['image'] ?? "",
      subjectNames: json['subjects']?.isEmpty ?? true
          ? <String>[]
          : json['subjects'].map<String>((e) => e['name'].toString()).toList(),
      lastMessage: json['last_message'] == null || json['last_message'].isEmpty
          ? null
          : ChatMessage.fromJsonAPI(json['last_message']),
      mobileNumber: json['mobile_no'] ?? "",
      email: json['email'] ?? "",
      qualification: json['qualification'] ?? "",
      classTeacher: json['class_teacher']?.isEmpty ?? true
          ? null
          : json['class_teacher'].map<String>((e) => e.toString()).toList(),
      unreadCount: int.parse((json['unread_message'] ?? 0).toString()),
      studentNames: json['student_name']?.isEmpty ?? true
          ? <String>[]
          : json['student_name'].map<String>((e) => e.toString()).toList(),
    );
  }

  ChatUser copyWith({
    int? id,
    int? userId,
    String? firstName,
    String? lastName,
    String? profileUrl,
    List<String>? subjectNames,
    ChatMessage? lastMessage,
    String? mobileNumber,
    String? email,
    String? qualification,
    List<String>? classTeacher,
    int? unreadCount,
    List<String>? studentNames,
  }) {
    return ChatUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileUrl: profileUrl ?? this.profileUrl,
      subjectNames: subjectNames ?? this.subjectNames,
      lastMessage: lastMessage ?? this.lastMessage,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      qualification: qualification ?? this.qualification,
      classTeacher: classTeacher ?? this.classTeacher,
      unreadCount: unreadCount ?? this.unreadCount,
      studentNames: studentNames ?? this.studentNames,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'profileUrl': profileUrl,
      'subjectNames': subjectNames,
      'lastMessage': lastMessage?.toJson(),
      'mobileNumber': mobileNumber,
      'email': email,
      'qualification': qualification,
      'classTeacher': classTeacher,
      'unreadCount': unreadCount,
      'studentNames': studentNames,
    };
  }

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
        id: map['id'] as int,
        userId: int.parse((map['userId']??0).toString()),
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        profileUrl: map['profileUrl'] as String,
        subjectNames: (map['subjectNames'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            [],
        unreadCount: int.parse((map['unreadCount']??0).toString()),
        lastMessage: ChatMessage.fromJson(map['lastMessage']),
        mobileNumber: map['mobileNumber'] as String,
        email: map['email'] as String,
        qualification: map['qualification'] as String,
        classTeacher: (map['classTeacher'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        studentNames: (map['studentNames'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList());
  }

  String toJson() => json.encode(toMap());

  factory ChatUser.fromJson(String source) =>
      ChatUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatUser(id: $id, userId: $userId, firstName: $firstName, lastName: $lastName, profileUrl: $profileUrl, subjectNames: $subjectNames, lastMessage: $lastMessage, mobileNumber: $mobileNumber, email: $email, qualification: $qualification, classTeacher: $classTeacher)';
  }

  @override
  bool operator ==(covariant ChatUser other) {
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
