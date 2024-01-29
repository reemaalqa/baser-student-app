import 'package:eschool/data/models/subjectMark.dart';

class Result {
  Result({
    required this.resultId,
    required this.examId,
    required this.examName,
    required this.description,
    required this.examDate,
    required this.sessionYear,
    required this.grade,
    required this.obtainedMark,
    required this.percentage,
    required this.subjectMarks,
    required this.totalMark,
  });

  bool get isPassed {
    try {
      return !subjectMarks
          .any((element) => element.obtainedMarks < element.passingMarks);
    } catch (_) {
      return true;
    }
  }

  late final int resultId;
  late final int examId;
  late final List<SubjectMark> subjectMarks;
  late final String examName;
  late final String description;
  late final String examDate;
  late final int totalMark;
  late final int obtainedMark;
  late final double percentage;
  late final String grade;
  late final String sessionYear;

  Result.fromJson(Map<String, dynamic> json) {
    resultId = json['result']['result_id'] ?? 0;
    examName = json['result']['exam_name'] ?? "";
    subjectMarks = ((json['exam_marks'] ?? []) as List)
        .map((subjectMark) => SubjectMark.fromJson(Map.from(subjectMark)))
        .toList();
    description = json['result']['description'] ?? "";
    examDate = json['result']['exam_date'] ?? "";
    sessionYear = json['result']['session_year'] ?? 0;
    totalMark = int.parse((json['result']['total_marks'] ?? 0).toString());
    obtainedMark = int.parse((json['result']['obtained_marks'] ?? 0).toString());
    percentage = double.parse((json['result']['percentage'] ?? 0).toString());
    grade = json['result']['grade'] ?? "";
  }
}
