import 'package:eschool/data/models/studyMaterial.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/utils/constants.dart';
import 'package:flutter/foundation.dart';

class Assignment {
  Assignment({
    required this.id,
    required this.classSectionId,
    required this.subjectId,
    required this.name,
    required this.instructions,
    required this.dueDate,
    required this.points,
    required this.resubmission,
    required this.extraDaysForResubmission,
    required this.sessionYearId,
    required this.subject,
    required this.createdAt,
    required this.assignmentSubmission,
    required this.referenceMaterials,
  });

  late final int id;
  late final int classSectionId;
  late final int subjectId;
  late final String name;
  late final DateTime createdAt; //It will work as assigned date
  late List<StudyMaterial> referenceMaterials;
  late final String instructions;
  late final DateTime dueDate;
  late final int points;
  late final int resubmission;
  late final int extraDaysForResubmission;
  late final int sessionYearId;
  late final AssignmentSubmission assignmentSubmission;
  late final Subject subject;

  Assignment updateAssignmentSubmission(
    AssignmentSubmission newAssignmentSubmission,
  ) {
    return Assignment(
      createdAt: createdAt,
      id: id,
      classSectionId: classSectionId,
      subjectId: subjectId,
      name: name,
      instructions: instructions,
      dueDate: dueDate,
      points: points,
      resubmission: resubmission,
      extraDaysForResubmission: extraDaysForResubmission,
      sessionYearId: sessionYearId,
      subject: subject,
      assignmentSubmission: newAssignmentSubmission,
      referenceMaterials: referenceMaterials,
    );
  }

  Assignment.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    classSectionId = int.parse((json['class_section_id'] ?? 0).toString());
    subjectId = int.parse((json['subject_id'] ?? 0).toString());
    name = json['name'] ?? "";
    instructions = json['instructions'] ?? "";
    dueDate = json['due_date'] == null
        ? DateTime.now()
        : DateTime.parse(json['due_date']);
    points = int.parse((json['points'] ?? 0).toString());
    resubmission =int.parse((json['resubmission'] ?? -1).toString());
    extraDaysForResubmission = int.parse((json['extra_days_for_resubmission'] ?? 0).toString());
    sessionYearId =int.parse((json['session_year_id'] ?? 0).toString());
    referenceMaterials = ((json['file'] ?? []) as List)
        .map((file) => StudyMaterial.fromJson(Map.from(file)))
        .toList();
    assignmentSubmission =
        AssignmentSubmission.fromJson(Map.from(json['submission'] ?? {}));
    subject = Subject.fromJson(json['subject'] ?? {});
    createdAt = json['created_at'] == null
        ? DateTime.now()
        : DateTime.parse(json['created_at'].toString());
  }
}

class AssignmentSubmission {
  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.sessionYearId,
    required this.feedback,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.points,
    required this.submittedFiles,
    required this.edited,
  });
  late final int id;
  late final List<StudyMaterial> submittedFiles;
  late final int assignmentId;
  late final int studentId;
  late final int sessionYearId;
  late final String feedback;
  late final int status;
  late final DateTime createdAt;
  late final int points;
  late final DateTime updatedAt;
  late final bool edited;

  AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    //logger.i(json);
    id = json['id'] ?? 0;
    points = int.parse((json['points'] ?? 0).toString());
    assignmentId = int.parse((json['assignment_id'] ?? 0).toString());
    studentId =int.parse((json['student_id'] ?? 0).toString());
    sessionYearId =int.parse((json['session_year_id'] ?? 0).toString());
    feedback = json['feedback'] ?? "";
    status = int.parse((json['status'] ?? -1).toString());
    createdAt = json['created_at'] == null
        ? DateTime.now()
        : DateTime.parse(json['created_at']);
    updatedAt = json['updated_at'] == null
        ? DateTime.now()
        : DateTime.parse(json['updated_at']);
    edited =(int.parse((json['editing'] ?? 0).toString()) != 1);
    submittedFiles = ((json['file'] ?? []) as List)
        .map(
          (submittedFiles) => StudyMaterial.fromJson(Map.from(submittedFiles)),
        )
        .toList();
  }
}
