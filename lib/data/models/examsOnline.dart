import 'package:eschool/data/models/subject.dart';

class ExamsOnline {
  ExamsOnline({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.examKey,
    required this.duration,
    required this.totalMarks,
    required this.subject,
  });
  late final int id;
  late final String title;
  late final String startDate;
  late final String endDate;
  late final int examKey;
  late final int duration;
  late final String totalMarks;
  late final Subject subject;

  ExamsOnline.fromJson(Map<String, dynamic> json) {
    id = json['exam_id'];
    title = json['title'];
    examKey =int.parse(( json['exam_key']).toString());
    duration = int.parse((json['duration'].toString()));
    startDate = json['start_date'];
    endDate = json['end_date'];
    totalMarks = json['total_marks'] ?? "";
    subject = Subject.fromJson(json['subject']);
  }
}
