import 'package:eschool/ui/screens/aboutUsScreen.dart';
import 'package:eschool/ui/screens/assignment/assignmentScreen.dart';
import 'package:eschool/ui/screens/auth/authScreen.dart';
import 'package:eschool/ui/screens/auth/parentLoginScreen.dart';
import 'package:eschool/ui/screens/auth/studentLoginScreen.dart';
import 'package:eschool/ui/screens/chapterDetails/chapterDetailsScreen.dart';
import 'package:eschool/ui/screens/chat/chatMessagesScreen.dart';
import 'package:eschool/ui/screens/chat/chatUserProfileScreen.dart';
import 'package:eschool/ui/screens/childAssignmentsScreen.dart';
import 'package:eschool/ui/screens/childAttendanceScreen.dart';
import 'package:eschool/ui/screens/childDetailMenuScreen.dart';
import 'package:eschool/ui/screens/childResultsScreen.dart';
import 'package:eschool/ui/screens/childTeachers.dart';
import 'package:eschool/ui/screens/childTimeTableScreen.dart';
import 'package:eschool/ui/screens/contactUsScreen.dart';
import 'package:eschool/ui/screens/exam/examTimeTableScreen.dart';
import 'package:eschool/ui/screens/exam/onlineExam/examOnlineScreen.dart';
import 'package:eschool/ui/screens/examScreen.dart';
import 'package:eschool/ui/screens/faqsScreen.dart';
import 'package:eschool/ui/screens/fees/feesDetailsScreen.dart';
import 'package:eschool/ui/screens/fees/feesPaymentVerification.dart';
import 'package:eschool/ui/screens/fees/feesStatusScreen.dart';
import 'package:eschool/ui/screens/fees/feesTransactionScreen.dart';
import 'package:eschool/ui/screens/fileViews/imageFileScreen.dart';
import 'package:eschool/ui/screens/fileViews/pdfFileScreen.dart';
import 'package:eschool/ui/screens/holidaysScreen.dart';
import 'package:eschool/ui/screens/home/homeScreen.dart';
import 'package:eschool/ui/screens/noticeBoardScreen.dart';
import 'package:eschool/ui/screens/notificationsScreen.dart';
import 'package:eschool/ui/screens/parentHomeScreen.dart';
import 'package:eschool/ui/screens/parentProfileScreen.dart';
import 'package:eschool/ui/screens/playVideo/playVideoScreen.dart';
import 'package:eschool/ui/screens/reports/reportSubjectsContainer.dart';
import 'package:eschool/ui/screens/reports/subjectWiseDetailedReport.dart';
import 'package:eschool/ui/screens/resultOnline/resultOnlineScreen.dart';
import 'package:eschool/ui/screens/studentProfileScreen.dart';
import 'package:eschool/ui/screens/resultScreen.dart';
import 'package:eschool/ui/screens/selectSubjectsScreen.dart';
import 'package:eschool/ui/screens/settingsScreen.dart';
import 'package:eschool/ui/screens/splashScreen.dart';
import 'package:eschool/ui/screens/childDetailsScreen.dart';
import 'package:eschool/ui/screens/subjectDetails/subjectDetailsScreen.dart';
import 'package:eschool/ui/screens/privacyPolicyScreen.dart';
import 'package:eschool/ui/screens/termsAndConditionScreen.dart';
import 'package:eschool/ui/screens/topicDetailsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ui/screens/userManual.dart';

// ignore: avoid_classes_with_only_static_members
class Routes {
  static const String splash = "splash";
  static const String home = "/";

  static const String auth = "auth";
  static const String parentLogin = "parentLogin";
  static const String studentLogin = "studentLogin";
  static const String studentProfile = "/studentProfile";
  static const String assignment = "/assignment";

  static const String exam = "/exam";

  static const String examTimeTable = "/examTimeTable";

  static const String subjectDetails = "/subjectDetails";

  static const String chapterDetails = "/chapterDetails";

  static const String aboutUs = "/aboutUs";
  static const String privacyPolicy = "/privacyPolicy";
  static const String userManual = "/userManual";

  static const String contactUs = "/contactUs";
  static const String faqs = "/faqs";

  static const String termsAndCondition = "/termsAndCondition";

  static const String selectSubjects = "/selectSubjects";
  static const String result = "/result";
  static const String parentHome = "parent/";

  static const String studentDetails = "parent/studentDetails";

  static const String parentMenu = "parent/studentDetailsMenu";

  static const String topicDetails = "/topicDetails";

  static const String playVideo = "/playVideo";

  static const String childAssignments = "/childAssignments";

  static const String childAttendance = "/childAttendance";

  static const String childTimeTable = "/childTimeTable";

  static const String childResults = "/childResults";

  static const String childTeachers = "/childTeachers";

  static const String settings = "/settings";

  static const String parentProfile = "/parentProfile";

  static const String noticeBoard = "/noticeBoard";

  static const String holidays = "/holidays";

  static const String childFees = "/fees";

  static const String feesDetails = "/feesDetails";

  static const String paymentVerify = "/paymentVerify";

  static const String subjectWiseReport = "/reportSubjectsContainer";
  static const String subjectWiseDetailedReport = "/subjectWiseDetailedReport";

  static const String examOnline = "/examOnline";

  static const String resultOnline = "/resultOnline";

  static const String feesTransaction = "/feesTransaction";

  static const String notifications = "/notifications";

  static const String pdfFileView = "/pdfFileView";
  static const String imageFileView = "/imageFileView";

  static const String chatMessages = "/chatMessages";
  static const String chatUserProfile = "/chatUserProfile";

  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    currentRoute = routeSettings.name ?? "";
    if (kDebugMode) {
      print("Route: $currentRoute");
    }
    switch (routeSettings.name) {
      case splash:
        {
          return SplashScreen.route(routeSettings);
        }
      case auth:
        {
          return CupertinoPageRoute(builder: (_) => const AuthScreen());
        }
      case studentLogin:
        {
          return StudentLoginScreen.route(routeSettings);
        }

      case parentLogin:
        {
          return ParentLoginScreen.route(routeSettings);
        }

      case home:
        {
          return HomeScreen.route(routeSettings);
        }
      case parentHome:
        {
          return ParentHomeScreen.route(routeSettings);
        }
      case assignment:
        {
          return AssignmentScreen.route(routeSettings);
        }
      case exam:
        {
          return ExamScreen.route(routeSettings);
        }
      case examTimeTable:
        {
          return ExamTimeTableScreen.route(routeSettings);
        }
      case subjectDetails:
        {
          return SubjectDetailsScreen.route(routeSettings);
        }
      case chapterDetails:
        {
          return ChapterDetailsScreen.route(routeSettings);
        }

      case studentProfile:
        {
          return StudentProfileScreen.route(routeSettings);
        }
      case aboutUs:
        {
          return AboutUsScreen.route(routeSettings);
        }
      case privacyPolicy:
        {
          return PrivacyPolicyScreen.route(routeSettings);
        }
      case userManual:
        {
          return UserManualScreen.route(routeSettings);
        }
      case faqs:
        {
          return CupertinoPageRoute(builder: (_) => const FaqsScreen());
        }
      case result:
        {
          return ResultScreen.route(routeSettings);
        }
      case selectSubjects:
        {
          return SelectSubjectsScreen.route(routeSettings);
        }
      case studentDetails:
        {
          return ChildDetailsScreen.route(routeSettings);
        }
      case topicDetails:
        {
          return TopicDetailsScreen.route(routeSettings);
        }
      case playVideo:
        {
          return PlayVideoScreen.route(routeSettings);
        }
      case childAssignments:
        {
          return ChildAssignmentsScreen.route(routeSettings);
        }
      case childAttendance:
        {
          return ChildAttendanceScreen.route(routeSettings);
        }

      case childTimeTable:
        {
          return ChildTimeTableScreen.route(routeSettings);
        }

      case childResults:
        {
          return ChildResultsScreen.route(routeSettings);
        }

      case childTeachers:
        {
          return ChildTeachersScreen.route(routeSettings);
        }
      case settings:
        {
          return CupertinoPageRoute(builder: (_) => const SettingsScreen());
        }
      case parentProfile:
        {
          return CupertinoPageRoute(
            builder: (_) => const ParentProfileScreen(),
          );
        }

      case noticeBoard:
        {
          return NoticeBoardScreen.route(routeSettings);
        }

      case contactUs:
        {
          return ContactUsScreen.route(routeSettings);
        }
      case termsAndCondition:
        {
          return TermsAndConditionScreen.route(routeSettings);
        }
      case holidays:
        {
          return HolidaysScreen.route(routeSettings);
        }
      case childFees:
        {
          return FeesStatusScreen.route(routeSettings);
        }
      case feesDetails:
        {
          return FeesDetailsScreen.route(routeSettings);
        }
      case notifications:
        return NotificationScreen.route(routeSettings);
      case pdfFileView:
        return PdfFileScreen.route(routeSettings);
      case imageFileView:
        return ImageFileScreen.route(routeSettings);
      case paymentVerify:
        return FeesPaymentVerification.route(routeSettings);

      case subjectWiseReport:
        return ReportSubjectsContainer.route(routeSettings);

      case subjectWiseDetailedReport:
        return SubjectWiseDetailedReport.route(routeSettings);

      case examOnline:
        return ExamOnlineScreen.route(routeSettings);

      case chatMessages:
        return ChatMessagesScreen.route(routeSettings);
      case chatUserProfile:
        return ChatUserProfileScreen.route(routeSettings);

      case resultOnline:
        {
          return ResultOnlineScreen.route(routeSettings);
        }

      case parentMenu:
        {
          return ChildDetailMenuScreen.route(routeSettings);
        }
      case feesTransaction:
        {
          return FeesTransactionScreen.route(routeSettings);
        }
      default:
        {
          return CupertinoPageRoute(builder: (context) => const Scaffold());
        }
    }
  }
}
