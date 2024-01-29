import 'package:eschool/ui/screens/reports/models/assignmentList.dart';
import 'package:eschool/ui/screens/reports/models/examList.dart';

import 'package:eschool/utils/api.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/errorMessageKeysAndCodes.dart';
import 'package:flutter/foundation.dart';

class ReportRepository {
  Future<Map<String, dynamic>> getExamOnlineReport({
    int? page,
    required int subjectId,
    required int childId,
    required bool useParentApi,
  }) async {
    try {
      final result = await Api.get(
        url: useParentApi
            ? Api.parentOnlineExamReport
            : Api.studentOnlineExamReport,
        useAuthToken: true,
        queryParameters: {
          'subject_id': subjectId,
          if (page != 0 && page != null) 'page': page,
          if (useParentApi) 'child_id': childId,
        },
      );
      if (kDebugMode) {
        print("Exam Report - ${result['data']}");
      }
      final resultData = result['data'];
      if (resultData is List && resultData.isEmpty) {
        throw ApiException(ErrorMessageKeysAndCode.noOnlineExamReportFoundCode);
      }
      return {
        "examList": ExamList.fromJson(Map.from(resultData['exam_list'])),
        "attempted": resultData['attempted'],
        "missedExams": resultData['missed_exams'],
        "totalExams": resultData['total_exams'],
        "percentage": resultData['percentage'],
        "totalObtainedMarks": resultData['total_obtained_marks'],
        "totalMarks": resultData['total_marks'],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getAssignmentReport({
    int? page,
    required int subjectId,
    required int childId,
    required bool useParentApi,
  }) async {
    try {
      final result = await Api.get(
        url: useParentApi
            ? Api.parentAssignmentReport
            : Api.studentAssignmentReport,
        useAuthToken: true,
        queryParameters: {
          if (subjectId != 0) 'subject_id': subjectId,
          if (page != 0) 'page': page,
          if (useParentApi) 'child_id': childId,
        },
      );
      final resultData = result['data'];

      return {
        "assignmentList":
        AssignmentList.fromJson(
          resultData['submitted_assignment_with_points_data'],
        ),
        "assignments": resultData['assignments'],
        "submittedAssignments": resultData['submitted_assignments'],
        "unsubmittedAssignments": resultData['unsubmitted_assignments'],
        "percentage": resultData['percentage'],
        "totalObtainedPoints": resultData['total_obtained_points'],
        "totalPoints": resultData['total_points'],
      };
    } catch (e) {
      logger.e(e);
      throw ApiException(e.toString());
    }
  }
}
