import 'package:eschool/data/models/coreSubject.dart';
import 'package:eschool/data/models/electiveSubject.dart';
import 'package:eschool/data/models/customNotification.dart';
import 'package:eschool/data/models/teacher.dart';
import 'package:eschool/utils/api.dart';
import 'package:flutter/foundation.dart';

class ParentRepository {
  Future<Map<String, dynamic>> fetchChildSubjects({
    required int childId,
  }) async {
    try {
      final result = await Api.get(
        url: Api.subjectsByChildId,
        useAuthToken: true,
        queryParameters: {"child_id": childId},
      );

      final coreSubjects = (result['data']['core_subject'] as List)
          .map((e) => CoreSubject.fromJson(json: Map.from(e)))
          .toList();

      //If class have any elective subjects then of key of elective subject will be there
      //if elective subject key has empty list means student has not slected any
      //elective subjctes

      //If there is not electvie subjects key in result means no elective subjects
      //in given class

      final electiveSubjects =
          ((result['data']['elective_subject'] ?? []) as List)
              .map(
                (e) => ElectiveSubject.fromJson(
                  electiveSubjectGroupId: 0,
                  json: Map.from(e['subject']),
                ),
              )
              .toList();

      return {
        "coreSubjects": coreSubjects,
        "electiveSubjects": electiveSubjects,
        "doesClassHaveElectiveSubjects":
            result['data']['elective_subject'] != null
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Teacher>> fetchChildTeachers({required int childId}) async {
    try {
      final result = await Api.get(
        url: Api.getStudentTeachersParent,
        useAuthToken: true,
        queryParameters: {"child_id": childId},
      );
      return (result['data'] as List)
          .map((teacher) => Teacher.fromJson(Map.from(teacher)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  //get custom notifications for parent
  Future<Map<String, dynamic>> fetchNotifications({required int page}) async {
    try {
      final response = await Api.get(
        url: Api.getParentNotifications,
        useAuthToken: true,
        queryParameters: {"page": page},
      );

      List<CustomNotification> notifications = [];

      for (int i = 0; i < response['data']['data'].length; i++) {
        notifications.add(
          CustomNotification.fromJson(
            response['data']['data'][i],
          ),
        );
      }

      return {
        "notifications": notifications,
        "currentPage": response['data']['current_page'],
        "totalPage": response['data']['last_page'],
      };
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw ApiException(error.toString());
    }
  }
}
