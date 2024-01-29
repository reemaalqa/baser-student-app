class Teacher {
  late final String subjectName;
  late final String profileUrl;
  late final String firstName;
  late final String lastName;
  late final String mobile;
  late final String email;

  Teacher.fromJson(Map<String, dynamic> json) {
    subjectName = json['subject'] == null ? "" : json['subject']['name'] ?? "";
    profileUrl =
        json['teacher'] == null ? "" : json['teacher']['user']['image'] ?? "";
    firstName = json['teacher'] == null
        ? ""
        : json['teacher']['user']['first_name'] ?? "";
    lastName = json['teacher'] == null
        ? ""
        : json['teacher']['user']['last_name'] ?? "";
    mobile =
        json['teacher'] == null ? "" : json['teacher']['user']['mobile'] ?? "";
    email =
        json['teacher'] == null ? "" : json['teacher']['user']['email'] ?? "";
  }
}
