import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/errorMessageKeysAndCodes.dart';
import 'package:eschool/utils/hiveBoxKeys.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ApiException implements Exception {
  String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

// ignore: avoid_classes_with_only_static_members
class Api {
  static Map<String, dynamic> headers() {
    final String jwtToken = Hive.box(authBoxKey).get(jwtTokenKey) ?? "";
    if (kDebugMode) {
      print("token is: $jwtToken");
    }
    return {"Authorization": "Bearer $jwtToken"};
  }

  //
  //Student app apis
  //
  static String studentLogin = "${databaseUrl}student/login";
  static String studentProfile = "${databaseUrl}student/get-profile-data";
  static String studentSubjects = "${databaseUrl}student/subjects";

  //get subjects of given class
  static String classSubjects = "${databaseUrl}student/class-subjects";
  static String studentTimeTable = "${databaseUrl}student/timetable";
  static String studentExamList = "${databaseUrl}student/get-exam-list";

  static String studentExamDetails = "${databaseUrl}student/get-exam-details";
  static String selectStudentElectiveSubjects =
      "${databaseUrl}student/select-subjects";
  static String getLessonsOfSubject = "${databaseUrl}student/lessons";
  static String getstudyMaterialsOfTopic =
      "${databaseUrl}student/lesson-topics";
  static String getStudentAttendance = "${databaseUrl}student/attendance";
  static String getAssignments = "${databaseUrl}student/assignments";
  static String submitAssignment = "${databaseUrl}student/submit-assignment";
  static String editSubmittedAssignment =
      "${databaseUrl}student/edit-assignment";
  static String generalAnnouncements = "${databaseUrl}student/announcements";
  static String parentDetailsOfStudent = "${databaseUrl}student/parent-details";
  static String deleteAssignment =
      "${databaseUrl}student/delete-assignment-submission";

  static String studentResults = "${databaseUrl}student/exam-marks";
  static String requestResetPassword = "${databaseUrl}student/forgot-password";

  static String studentExamOnlineList =
      "${databaseUrl}student/get-online-exam-list";
  static String studentExamOnlineQuestions =
      "${databaseUrl}student/get-online-exam-questions";
  static String studentSubmitOnlineExamAnswers =
      "${databaseUrl}student/submit-online-exam-answers";

  static String studentOnlineExamResultList =
      "${databaseUrl}student/get-online-exam-result-list";

  static String studentOnlineExamResult =
      "${databaseUrl}student/get-online-exam-result";

  static String studentOnlineExamReport =
      "${databaseUrl}student/get-online-exam-report";
  static String studentAssignmentReport =
      "${databaseUrl}student/get-assignments-report";

  //
  //Apis that will be use in both student and parent app
  //
  static String getSliders = "${databaseUrl}sliders";
  static String logout = "${databaseUrl}logout";
  static String settings = "${databaseUrl}settings";
  static String holidays = "${databaseUrl}holidays";

  static String changePassword = "${databaseUrl}change-password";

  //
  //Parent app apis
  //
  static String subjectsByChildId = "${databaseUrl}parent/subjects";
  static String parentLogin = "${databaseUrl}parent/login";
  static String parentProfile = "${databaseUrl}parent/get-profile-data";
  static String lessonsOfSubjectParent = "${databaseUrl}parent/lessons";
  static String getstudyMaterialsOfTopicParent =
      "${databaseUrl}parent/lesson-topics";
  static String getAssignmentsParent = "${databaseUrl}parent/assignments";
  static String getStudentAttendanceParent = "${databaseUrl}parent/attendance";
  static String getStudentTimetableParent = "${databaseUrl}parent/timetable";
  static String getStudentExamListParent = "${databaseUrl}parent/get-exam-list";
  static String getStudentResultsParent = "${databaseUrl}parent/exam-marks";
  static String getStudentExamDetailsParent =
      "${databaseUrl}parent/get-exam-details";

  static String generalAnnouncementsParent =
      "${databaseUrl}parent/announcements";

  static String getStudentTeachersParent = "${databaseUrl}parent/teachers";
  static String forgotPassword = "${databaseUrl}forgot-password";

  static String getStudentFeesDetailParent =
      "${databaseUrl}parent/fees-details";
  static String addFeesTransaction =
      "${databaseUrl}parent/add-fees-transaction";
  static String failPaymentTransaction =
      "${databaseUrl}parent/fail-payment-transaction";
  static String storeFeesParent = "${databaseUrl}parent/store-fees";

  static String getPaidFeesListParent = "${databaseUrl}parent/fees-paid-list";
  static String downloadFeesPaidReceiptParent =
      "${databaseUrl}parent/fees-paid-receipt-pdf";

  static String parentExamOnlineList =
      "${databaseUrl}parent/get-online-exam-list";
  static String parentOnlineExamResultList =
      "${databaseUrl}parent/get-online-exam-result-list";
  static String parentOnlineExamResult =
      "${databaseUrl}parent/get-online-exam-result";
  static String parentOnlineExamReport =
      "${databaseUrl}parent/get-online-exam-report";
  static String parentAssignmentReport =
      "${databaseUrl}parent/get-assignments-report";

  static String getFeesTransactions =
      "${databaseUrl}parent/fees-transactions-list";
  static String verifyStripePayment = "${databaseUrl}parent/get-payment-status";

  static String getStudentNotifications =
      "${databaseUrl}student/get-notification";
  static String getParentNotifications =
      "${databaseUrl}parent/get-notification";

  //chat related APIs
  //student
  static String getChatUsersStudent = "${databaseUrl}student/get-user-list";
  static String getChatMessagesStudent =
      "${databaseUrl}student/get-user-message";
  static String sendChatMessageStudent = "${databaseUrl}student/send-message";
  static String readAllMessagesStudent =
      "${databaseUrl}student/read-all-message";
  //parent
  static String getChatUsersParent = "${databaseUrl}parent/get-user-list";
  static String getChatMessagesParent = "${databaseUrl}parent/get-user-message";
  static String sendChatMessageParent = "${databaseUrl}parent/send-message";
  static String readAllMessagesParent = "${databaseUrl}parent/read-all-message";

  static Future<Map<String, dynamic>> post({
    required Map<String, dynamic> body,
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Dio dio = Dio();
      final FormData formData =
      FormData.fromMap(body, ListFormat.multiCompatible);
      if (kDebugMode) {
        print("API Called POST: $url with $queryParameters");
        print("Body Params: $body");
      }
      final response = await dio.post(
        url,
        data: formData,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      if (kDebugMode) {
        print("Response: ${response.data}");
      }
      if (response.data['error']) {
        if (kDebugMode) {
          print("POST ERROR: ${response.data}");
        }
        throw ApiException(response.data['code'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 503 || e.response?.statusCode == 500) {
        throw ApiException(ErrorMessageKeysAndCode.internetServerErrorCode);
      }
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Dio dio = Dio();
      if (kDebugMode) {
        print("API Called GET: $url with $queryParameters");
      }

      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: useAuthToken ? Options(headers: headers()) : null,
      );
      if (kDebugMode) {
        print("Response: ${response.data}");
      }

      if (response.data['error']) {
        if (kDebugMode) {
          print("GET ERROR: ${response.data}");
        }
        throw ApiException(response.data['code'].toString());
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 503 || e.response?.statusCode == 500) {
        throw ApiException(ErrorMessageKeysAndCode.internetServerErrorCode);
      }
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<void> download({
    required String url,
    required CancelToken cancelToken,
    required String savePath,
    required Function updateDownloadedPercentage,
  }) async {
    try {
      final Dio dio = Dio();
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          final double percentage = (count / total) * 100;
          updateDownloadedPercentage(percentage < 0.0 ? 99.0 : percentage);
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 503 || e.response?.statusCode == 500) {
        throw ApiException(ErrorMessageKeysAndCode.internetServerErrorCode);
      }
      if (e.response?.statusCode == 404) {
        throw ApiException(ErrorMessageKeysAndCode.fileNotFoundErrorCode);
      }
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }
}
