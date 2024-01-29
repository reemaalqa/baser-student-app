import 'package:eschool/data/models/resultOnline.dart';
import 'package:eschool/data/models/resultOnlineDetails.dart';
import 'package:eschool/utils/api.dart';
import 'package:flutter/foundation.dart';

class ResultOnlineRepository {
  Future<Map<String, dynamic>> getResultOnline({
    int? page,
    required int subjectId,
    required bool useParentApi,
    required int childId,
  }) async {
    try {
      final result = await Api.get(
        url: useParentApi
            ? Api.parentOnlineExamResultList
            : Api.studentOnlineExamResultList,
        useAuthToken: true,
        queryParameters: {
          if (subjectId != 0) 'subject_id': subjectId,
          if (page != 0) 'page': page,
          if (useParentApi) 'child_id': childId,
        },
      );
      if (kDebugMode) {
        print(result['data']);
      }

      return {
        "results": (result['data']['data'] as List)
            .map((e) => ResultOnline.fromJson(Map.from(e)))
            .toList(),
        "totalPage": result['data']['last_page'] as int,
        "currentPage": result['data']['current_page'] as int,
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<ResultOnlineDetails> getOnlineResultDetails({
    required int examId,
    required bool useParentApi,
    required int childId,
  }) async {
    try {
      final result = await Api.get(
        url: useParentApi
            ? Api.parentOnlineExamResult
            : Api.studentOnlineExamResult,
        useAuthToken: true,
        queryParameters: {
          if (examId != 0) 'online_exam_id': examId,
          if (useParentApi) 'child_id': childId,
        },
      );
      return ResultOnlineDetails.fromJson(result['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
