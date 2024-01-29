import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';

class Menu {
  final String title;
  final String iconUrl;

  Menu({required this.iconUrl, required this.title});
}

//To add all more menu here

final List<Menu> homeBottomSheetMenu = [
  Menu(
      iconUrl: UiUtils.getImagePath("attendance_icon.svg"),
      title: attendanceKey,),
  Menu(
      iconUrl: UiUtils.getImagePath("timetable_icon.svg"), title: timeTableKey,),
  Menu(
      iconUrl: UiUtils.getImagePath("noticeboard_icon.svg"),
      title: noticeBoardKey,),
  Menu(iconUrl: UiUtils.getImagePath("exam_icon.svg"), title: examsKey),
  Menu(iconUrl: UiUtils.getImagePath("result_icon.svg"), title: resultKey),
  Menu(iconUrl: UiUtils.getImagePath("reports_icon.svg"), title: reportsKey),
  Menu(
      iconUrl: UiUtils.getImagePath("parent_icon.svg"),
      title: parentProfileKey,),
  Menu(iconUrl: UiUtils.getImagePath("holiday_icon.svg"), title: holidaysKey),
  Menu(iconUrl: UiUtils.getImagePath("setting_icon.svg"), title: settingsKey),
];
