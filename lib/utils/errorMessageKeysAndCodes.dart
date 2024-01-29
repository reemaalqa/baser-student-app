import 'package:eschool/utils/labelKeys.dart';

// ignore: avoid_classes_with_only_static_members
class ErrorMessageKeysAndCode {
  static const String defaultErrorMessageKey = "defaultErrorMessage";
  static const String noInternetKey = "noInternet";
  static const String internetServerErrorKey = "internetServerError";
  static const String invalidLogInCredentialsKey = "invalidLogInCredentials";

  static const String assignmentAlreadySubmittedKey =
      "assignmentAlreadySubmitted";

  static String invalidUserDetailsKey = "invalidUserDetails";

  static String invalidPasswordKey = "invalidPassword";

  static String canNotSendResetPasswordRequestKey =
      "canNotSendResetPasswordRequest";

  static String examOnlineAttendedKey = "examOnlineAttended";

  static String examOnlineNotStartedYetKey = "examOnlineNotStartedYet";

  static String noOnlineExamReportFoundKey = "noOnlineExamReportFound";

  //These are ui side error codes
  static const String internetServerErrorCode = "500";
  static const String fileNotFoundErrorCode = "404";
  static const String permissionNotGivenCode = "300";
  static const String noInternetCode = "301";
  static const String defaultErrorMessageCode = "302";
  static const String noOnlineExamReportFoundCode = "303";

  //Visit here to watch error message keys and codes
  //https://docs.google.com/document/d/1JsRC_DXvWZ64GRZE1vkQOrHMfb_ghFtsQh9xJJruAIk/edit?usp=sharing
  static String getErrorMessageKeyFromCode(String errorCode) {
    //
    if (errorCode == "101") {
      return invalidLogInCredentialsKey;
    }
    if (errorCode == "104") {
      return assignmentAlreadySubmittedKey;
    }

    if (errorCode == "107") {
      return invalidUserDetailsKey;
    }

    if (errorCode == "108") {
      return canNotSendResetPasswordRequestKey;
    }

    if (errorCode == "109") {
      return invalidPasswordKey;
    }

    if (errorCode == "105") {
      return examOnlineAttendedKey;
    }
    if (errorCode == "106") {
      return examOnlineNotStartedYetKey;
    }
    if (errorCode == noOnlineExamReportFoundCode) {
      return noOnlineExamReportFoundKey;
    }
    if (errorCode == permissionNotGivenCode) {
      return permissionsNotGivenKey;
    }
    if (errorCode == noInternetCode) {
      return noInternetKey;
    }
    if (errorCode == internetServerErrorCode) {
      return internetServerErrorKey;
    }
    if (errorCode == fileNotFoundErrorCode) {
      return fileDownloadingFailedKey;
    }
    if (errorCode == defaultErrorMessageCode) {
      return defaultErrorMessageKey;
    } else {
      return defaultErrorMessageKey;
    }
  }
}
