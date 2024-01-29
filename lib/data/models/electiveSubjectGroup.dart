import 'package:eschool/data/models/electiveSubject.dart';

import '../../utils/constants.dart';

class ElectiveSubjectGroup {
  late final int id;
  late final int totalSelectableSubjects;
  late final int totalSubjects;
  late final List<ElectiveSubject> subjects;

  ElectiveSubjectGroup(
      {required this.id,
      required this.totalSelectableSubjects,
      required this.subjects,
      required this.totalSubjects,});

  ElectiveSubjectGroup.fromJson(Map<String, dynamic> json) {
    // logger.i(json);
    id = json['id'] ?? 0;
    totalSelectableSubjects = json['total_selectable_subjects'] ?? 0;
    totalSubjects = json['total_subjects'] ?? 0;
    subjects = json['elective_subjects'] == null
        ? [] as List<ElectiveSubject>
        : (json['elective_subjects'] as List)
            .map((electiveSubject) => ElectiveSubject.fromJson(
                electiveSubjectGroupId: id,
                json: Map.from(electiveSubject['subject']),),)
            .toList();
  }
}
