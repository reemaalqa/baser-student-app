import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';

import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';

import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChildDetailMenuScreen extends StatefulWidget {
  final Student student;
  final List<Subject> subjectsForFilter;
  const ChildDetailMenuScreen({
    Key? key,
    required this.student,
    required this.subjectsForFilter,
  }) : super(key: key);

  @override
  ChildDetailMenuScreenState createState() => ChildDetailMenuScreenState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => ChildDetailMenuScreen(
        subjectsForFilter: arguments['subjectsForFilter'],
        student: arguments['student'],
      ),
    );
  }
}

class ChildDetailMenuScreenState extends State<ChildDetailMenuScreen> {
  late List<MenuContainerDetails> _menuItems;

  Widget _buildAppBar(BuildContext context) {
    return ScreenTopBackgroundContainer(
      heightPercentage: UiUtils.appBarSmallerHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          context.read<AuthCubit>().isParent()
              ? const CustomBackButton()
              : const SizedBox(),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              UiUtils.getTranslatedLabel(context, menuKey),
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: UiUtils.screenTitleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationAndMenu() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * (0.075),
        right: MediaQuery.of(context).size.width * (0.075),
        top: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarMediumtHeightPercentage,
        ),
      ),
      child: Column(
        children: List.generate(_menuItems.length,
            (index) => _buildMenuContainer(itemIndex: index)),
      ),
    );
  }

  Widget _buildMenuContainer({
    required itemIndex,
  }) {
    return Animate(
      effects: listItemAppearanceEffects(
          itemIndex: itemIndex, totalLoadedItems: _menuItems.length),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).pushNamed(_menuItems[itemIndex].route,
                arguments: _menuItems[itemIndex].arguments);
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.25),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.225),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      width: boxConstraints.maxWidth * (0.225),
                      child: SvgPicture.asset(_menuItems[itemIndex].iconPath),
                    ),
                    SizedBox(
                      width: boxConstraints.maxWidth * (0.025),
                    ),
                    SizedBox(
                      width: boxConstraints.maxWidth * (0.475),
                      child: Text(
                        _menuItems[itemIndex].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      radius: 17.5,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 22.5,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    SizedBox(
                      width: boxConstraints.maxWidth * (0.035),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _menuItems = [
      MenuContainerDetails(
        route: Routes.childAssignments,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter
        },
        iconPath: UiUtils.getImagePath("assignment_icon_parent.svg"),
        title: UiUtils.getTranslatedLabel(context, assignmentsKey),
      ),
      MenuContainerDetails(
        route: Routes.childTeachers,
        arguments: widget.student.id,
        iconPath: UiUtils.getImagePath("teachers_icon.svg"),
        title: UiUtils.getTranslatedLabel(context, teachersKey),
      ),
      MenuContainerDetails(
        route: Routes.childAttendance,
        arguments: widget.student.id,
        iconPath: UiUtils.getImagePath("attendance_icon.svg"),
        title: UiUtils.getTranslatedLabel(context, attendanceKey),
      ),
      MenuContainerDetails(
        route: Routes.childTimeTable,
        arguments: widget.student.id,
        iconPath: UiUtils.getImagePath("timetable_icon.svg"),
        title: UiUtils.getTranslatedLabel(context, timeTableKey),
      ),
      MenuContainerDetails(
        route: Routes.holidays,
        iconPath: UiUtils.getImagePath("holiday_icon.svg"),
        title: UiUtils.getTranslatedLabel(context, holidaysKey),
      ),
      MenuContainerDetails(
        route: Routes.exam,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter
        },
        iconPath: UiUtils.getImagePath("exam_icon.svg"),
        title: UiUtils.getTranslatedLabel(context, examsKey),
      ),
      MenuContainerDetails(
        route: Routes.childResults,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter
        },
        iconPath: UiUtils.getImagePath("result_icon.svg"),
        title: UiUtils.getTranslatedLabel(context, resultKey),
      ),
      MenuContainerDetails(
        route: Routes.subjectWiseReport,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter
        },
        iconPath: UiUtils.getImagePath("reports_icon.svg"),
        title: UiUtils.getTranslatedLabel(context, reportsKey),
      ),
      MenuContainerDetails(
        route: Routes.childFees,
        arguments: {
          "studentDetails": widget.student,
        },
        iconPath: UiUtils.getImagePath("fees_icon.svg"),
        title: UiUtils.getTranslatedLabel(context, feesKey),
      ),
    ];
    return Scaffold(
      body: Stack(
        children: [
          _buildInformationAndMenu(),
          _buildAppBar(context),
        ],
      ),
    );
  }
}

//class to maintain details required by each menu items
class MenuContainerDetails {
  String iconPath;
  String title;
  String route;
  Object? arguments;

  MenuContainerDetails({
    required this.iconPath,
    required this.title,
    required this.route,
    this.arguments,
  });
}
