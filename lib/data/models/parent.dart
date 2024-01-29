import 'package:eschool/data/models/student.dart';

class Parent {
  Parent({
    required this.id,
    required this.gender,
    required this.email,
    required this.children,
    required this.mobile,
    required this.image,
    required this.dob,
    required this.status,
    required this.userId,
    required this.occupation,
    required this.lastName,
    required this.firstName,
  });
  late final int id;
  late final String gender;
  late final String email;
  late final String mobile;
  late final String image;
  late final String dob;
  late final int status;
  late final int userId;
  late final String occupation;
  late final String lastName;
  late final String firstName;
  late final List<Student> children;
  late final String currentAddress;
  late final String permanentAddress;

  Parent.fromJson(Map<String, dynamic> json) {
    currentAddress = json['current_address'] ?? "";
    permanentAddress = json['permanent_address'] ?? "";
    id = json['id'] ?? 0;
    gender = json['gender'] ?? "";
    email = json['email'] ?? "";
    mobile = json['mobile'] ?? "";
    image = json['image'] ?? "";
    dob = json['dob'] ?? "";
    status = int.parse((json['status'] ?? 0).toString());
    userId = int.parse((json['user_id'] ?? 0).toString());
    occupation = json['occupation'] ?? "";
    lastName = json['last_name'] ?? "";
    firstName = json['first_name'] ?? "";
    children = json['children'] == null
        ? []
        : (json['children'] as List)
            .map((studentJson) => Student.fromJson(Map.from(studentJson)))
            .toList();
  }

  String getFullName() {
    return "$firstName $lastName";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['gender'] = gender;
    data['email'] = email;
    data['mobile'] = mobile;
    data['image'] = image;
    data['dob'] = dob;
    data['status'] = status;
    data['user_id'] = userId;
    data['occupation'] = occupation;
    data['last_name'] = lastName;
    data['first_name'] = firstName;
    data['children'] = children.map((student) => student.toJson()).toList();
    return data;
  }
}

// import 'package:eschool/data/models/student.dart';
// import 'package:eschool/utils/constants.dart';
//
// class Parent {
//   Parent({
//     required this.id,
//     required this.gender,
//     required this.email,
//     required this.children,
//     required this.mobile,
//     required this.image,
//     required this.dob,
//     required this.status,
//     required this.userId,
//     required this.occupation,
//     required this.lastName,
//     required this.firstName,
//   });
//   late final int id;
//   late final String gender;
//   late final String email;
//   late final String mobile;
//   late final String image;
//   late final String dob;
//   late final String status;
//   late final String userId;
//   late final String occupation;
//   late final String lastName;
//   late final String firstName;
//   late final List<Student> children;
//   late final String currentAddress;
//   late final String permanentAddress;
//
//   Parent.fromJson(Map<String, dynamic> json) {
//     logger.i(json);
//     currentAddress = json['current_address'] ?? "";
//     permanentAddress = json['permanent_address'] ?? "";
//     id = json['id'] ?? 0;
//     gender = json['gender'] ?? "";
//     email = json['email'] ?? "";
//     mobile = json['mobile'] ?? "";
//     image = json['image'] ?? "";
//     dob = json['dob'] ?? "";
//     status = json['status'] ?? "0";
//     userId = json['user_id'] ?? "0";
//     occupation = json['occupation'] ?? "";
//     lastName = json['last_name'] ?? "";
//     firstName = json['first_name'] ?? "";
//     children = json['children'] == null
//         ? []
//         : (json['children'] as List)
//         .map((studentJson) => Student.fromJson(Map.from(studentJson)))
//         .toList();
//   }
//
//   String getFullName() {
//     return "$firstName $lastName";
//   }
//
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['id'] = id;
//     data['gender'] = gender;
//     data['email'] = email;
//     data['mobile'] = mobile;
//     data['image'] = image;
//     data['dob'] = dob;
//     data['status'] = status;
//     data['user_id'] = userId;
//     data['occupation'] = occupation;
//     data['last_name'] = lastName;
//     data['first_name'] = firstName;
//     data['children'] = children.map((student) => student.toJson()).toList();
//     return data;
//   }
// }
