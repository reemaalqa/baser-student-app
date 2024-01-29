class SubjectMark {
  // final Subject subject;
  final int totalMarks;
  final String subjectName;
  final String subjectType;
  final int obtainedMarks;
  final String grade;

  // final int passingStatus;
  final int passingMarks;
  // final DateTime examDate;

  SubjectMark({
    required this.grade,
    //required this.examDate,
    // required this.passingStatus,
    required this.obtainedMarks,
    required this.subjectName,
    required this.subjectType,
    // required this.subject,
    required this.passingMarks,
    required this.totalMarks,
  });

  static SubjectMark fromJson(Map<String, dynamic> json) {
    return SubjectMark(
      grade: json['grade'] ?? "",
      obtainedMarks: int.parse((json['obtained_marks'] ?? 0).toString()),
      totalMarks: int.parse((json['total_marks'] ?? 0).toString()),
      subjectName: json['subject_name'] ?? '',
      subjectType: json['subject_type'] ?? '',
      passingMarks: int.parse((json['passing_marks'] ?? 0).toString()),
      // subject: Subject.fromJson(Map.from(json['subject'] ?? {})),
      /*      passingStatus: json['passing_status'] ?? -1,
        
        examDate: json['timetable'] == null
            ? DateTime.now()
            : json['timetable']['date'] == null
                ? DateTime.now()
                : DateTime.parse(json['timetable']['date']),*/
    );
  }
}
