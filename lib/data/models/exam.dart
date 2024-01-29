import 'package:eschool/data/models/subject.dart';

class Exam {
  int? examID;
  String? examName;
  String? description;
  int? publish;
  String? sessionYear;
  String? examStartingDate;
  String? examEndingDate;
  String? examStatus;


  Exam(
      {this.examID,
      this.examName,
      this.description,
      this.publish,
      this.sessionYear,
      this.examStartingDate,
      this.examEndingDate,
      this.examStatus,});

  Exam.fromExamJson(Map<String, dynamic> json) {
    examID = int.parse((json['id'].toString()));
    examName = json['name'] ?? "";
    description = json['description'] ?? "";
    publish = int.parse((json['publish'] ?? 0).toString());
    sessionYear = json['session_year'] ?? "";
    examStartingDate = json['exam_starting_date'] ?? "";
    examEndingDate = json['exam_ending_date'] ?? "";
    examStatus = json['exam_status'] ?? "";
  }

}

class ExamTimeTable {
  int? id;
  int? totalMarks;
  int? passingMarks;
  String? date;
  String? startingTime;
  String? endingTime;
  Subject? subject;

  ExamTimeTable(
      {this.id,
      this.totalMarks,
      this.passingMarks,
      this.date,
      this.startingTime,
      this.endingTime,
      this.subject,});

  ExamTimeTable.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalMarks = json['total_marks'] ?? 0;
    passingMarks = json['passing_marks'] ?? 0;
    date = json['date'] ?? '';
    startingTime = json['starting_time'] ?? '';
    endingTime = json['ending_time'] ?? '';
    subject = Subject.fromJson(json['subject']);
  }
}
