import 'package:eschool/utils/constants.dart';

class CustomNotification {
  int id;
  String title;
  String type;
  String message;
  int? sendTo;
  String? image;
  DateTime date;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  CustomNotification(
      {required this.id,
      required this.title,
      required this.type,
      required this.message,
      this.sendTo,
      this.image,
      required this.date,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  factory CustomNotification.fromJson(Map<String, dynamic> json) {
    logger.i(json);
    return CustomNotification(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      type: json['type'] ?? "custom",
      message: json['message'] ?? "",
      sendTo:int.parse((json['send_to']??0).toString()),
      image: json['image'],
      date: DateTime.tryParse(json['date']) ?? DateTime.now(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['type'] = type;
    data['message'] = message;
    data['send_to'] = sendTo;
    data['image'] = image;
    data['date'] = date;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}
