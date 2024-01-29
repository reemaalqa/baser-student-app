class AttendanceDay {
  AttendanceDay({
    required this.id,
    required this.studentId,
    required this.sessionYearId,
    required this.type,
    required this.date,
    required this.remark,
  });
  late final int id;
  late final int studentId;
  late final int sessionYearId;
  late final int type;
  late final DateTime date;
  late final String remark;

  AttendanceDay.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    studentId = int.parse((json['student_id'] ?? 0).toString());
    sessionYearId = int.parse((json['session_year_id'] ?? 0).toString());
    type = int.parse((json['type'] ?? -1).toString());
    date = json['date'] == null ? DateTime.now() : DateTime.parse(json['date']);
    remark = json['remark'] ?? "";
  }
}
