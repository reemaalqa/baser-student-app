import 'package:eschool/utils/uiUtils.dart';

class Shift {
  String id;
  String title;
  String? startTime;
  String? endTime;

  String? get startToEndTime {
    if (startTime == null || endTime == null) {
      return null;
    } else {
      return "${UiUtils.formatTime(startTime!)} - ${UiUtils.formatTime(endTime!)}";
    }
  }

  Shift({required this.id, required this.title, this.startTime, this.endTime});

  factory Shift.fromJson(Map<String, dynamic> jsonData) {
    return Shift(
      id: jsonData['id'].toString(),
      title: jsonData['title'].toString(),
      startTime: jsonData['start_time'],
      endTime: jsonData['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
