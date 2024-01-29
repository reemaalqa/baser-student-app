import 'package:eschool/data/models/feesSettings.dart';
import 'package:eschool/data/models/sessionYear.dart';

import '../../utils/constants.dart';

class AppConfiguration {
  AppConfiguration({
    required this.appLink,
    required this.iosAppLink,
    required this.appVersion,
    required this.iosAppVersion,
    required this.forceAppUpdate,
    required this.appMaintenance,
  });
  late final String appLink;
  late final String iosAppLink;
  late final String appVersion;
  late final String iosAppVersion;
  late final String forceAppUpdate;
  late final String appMaintenance;
  late final SessionYear sessionYear;
  late final String schoolName;
  late final String schoolTagline;
  late final FeesSettings feesSettings;
  late final String onlineExamRules;
  late final String isOnlineFeesPaymentEnabled;

  AppConfiguration.fromJson(Map<String, dynamic> json) {
    //logger.i(json);
    appLink = json['app_link'] ?? "";
    iosAppLink = json['ios_app_link'] ?? "";
    appVersion = json['app_version'] ?? "";
    iosAppVersion = json['ios_app_version'] ?? "";
    forceAppUpdate = json['force_app_update'] ?? "0";
    appMaintenance = json['app_maintenance'] ?? "0";
    schoolName = json['school_name'] ?? "";
    schoolTagline = json['school_tagline'] ?? "";
    sessionYear = SessionYear.fromJson(json['session_year'] ?? {});
    feesSettings = FeesSettings.fromJson(json['fees_settings'] ?? {});
    onlineExamRules = json['online_exam_terms_condition'] ?? "";
    isOnlineFeesPaymentEnabled = json['online_payment'] ?? "false";
  }
}
