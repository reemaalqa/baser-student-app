import 'package:eschool/data/models/subject.dart';
import 'package:eschool/utils/constants.dart';

class CoreSubject extends Subject {
  late final int classId;

  CoreSubject.fromJson({required Map<String, dynamic> json})
      : super.fromJson(Map.from(json['subject'] ?? {})) {
    classId = int.parse((json['class_id'] ?? 0).toString());
  }
}
