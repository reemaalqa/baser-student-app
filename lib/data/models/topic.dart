import 'package:eschool/data/models/studyMaterial.dart';

class Topic {
  Topic(
      {required this.id,
      required this.name,
      required this.lessonId,
      required this.description,});
  late final int id;
  late final String description;
  late final String name;
  late final int lessonId;
  late final List<StudyMaterial> studyMaterials;

  Topic.fromJson(Map<String, dynamic> json) {
    id = int.parse((json['id'] ?? 0).toString());
    name = json['name'] ?? "";
    lessonId = int.parse((json['lesson_id'] ?? 0).toString());
    description = json['description'] ?? "";

    studyMaterials = ((json['file'] ?? []) as List)
        .map((file) => StudyMaterial.fromJson(Map.from(file)))
        .toList();
  }
}
