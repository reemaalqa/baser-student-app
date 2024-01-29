import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/utils/errorMessageKeysAndCodes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool/cubits/reportTabSelectionCubit.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/screens/reports/cubits/assignmentReportCubit.dart';
import 'package:eschool/ui/screens/reports/cubits/onlineExamReportCubit.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';

class SubjectWiseDetailedReport extends StatefulWidget {
  final Subject subject;
  final int? childId;
  const SubjectWiseDetailedReport({
    Key? key,
    required this.subject,
    this.childId,
  }) : super(key: key);

  @override
  SubjectWiseDetailedReportState createState() =>
      SubjectWiseDetailedReportState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => SubjectWiseDetailedReport(
        subject: arguments['subject'],
        childId: arguments['childId'] ?? 0,
      ),
    );
  }
}

class SubjectWiseDetailedReportState extends State<SubjectWiseDetailedReport> {
  late final ScrollController _reportOnlineExamController = ScrollController()
    ..addListener(_reportOnlineExamScrollListener);
  late final ScrollController _reportAssignmentController = ScrollController()
    ..addListener(_reportAssignmentScrollListener);
  @override
  void initState() {
    //call API according to tab selection
    if (context.read<ReportTabSelectionCubit>().isReportAssignment()) {
      getAssignmentReport();
    } else {
      getExamOnlineReport();
    }
    super.initState();
  }

  @override
  void dispose() {
    _reportOnlineExamController.removeListener(_reportOnlineExamScrollListener);
    _reportAssignmentController.removeListener(_reportAssignmentScrollListener);
    super.dispose();
  }

  void getAssignmentReport() {
    context.read<AssignmentReportCubit>().getAssignmentReport(
          subjectId: widget.subject.id,
          childId: widget.childId ?? 0,
          useParentApi: context.read<AuthCubit>().isParent(),
        );
  }

  void getExamOnlineReport() {
    context.read<OnlineExamReportCubit>().getExamOnlineReport(
          subjectId: widget.subject.id,
          childId: widget.childId ?? 0,
          useParentApi: context.read<AuthCubit>().isParent(),
        );
  }

  void _reportAssignmentScrollListener() {
    if (_reportAssignmentController.offset ==
        _reportAssignmentController.position.maxScrollExtent) {
      if (context.read<AssignmentReportCubit>().hasMore()) {
        context.read<AssignmentReportCubit>().getMoreAssignmentReport(
              childId: widget.childId ?? 0,
              useParentApi: context.read<AuthCubit>().isParent(),
            );
      }
    }
  }

  void _reportOnlineExamScrollListener() {
    if (_reportOnlineExamController.offset ==
        _reportOnlineExamController.position.maxScrollExtent) {
      if (context.read<OnlineExamReportCubit>().hasMore()) {
        context.read<OnlineExamReportCubit>().getMoreExamOnlineReport(
              childId: widget.childId ?? 0,
              useParentApi: context.read<AuthCubit>().isParent(),
            );
      }
    }
  }

  Widget buildReportAppBar(ReportTabSelectionState currentState) {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              const CustomBackButton(),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  widget.subject.showType
                      ? widget.subject.subjectNameWithType
                      : widget.subject.name,
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: UiUtils.screenTitleFontSize,
                  ),
                ),
              ),
              AnimatedAlign(
                curve: UiUtils.tabBackgroundContainerAnimationCurve,
                duration: UiUtils.tabBackgroundContainerAnimationDuration,
                alignment: currentState.reportFilterTabTitle == assignmentKey
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child:
                    TabBarBackgroundContainer(boxConstraints: boxConstraints),
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerStart,
                isSelected: currentState.reportFilterTabTitle == assignmentKey,
                onTap: () {
                  context
                      .read<ReportTabSelectionCubit>()
                      .changeReportFilterTabTitle(assignmentKey);
                  getAssignmentReport();
                },
                titleKey: assignmentKey,
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerEnd,
                isSelected: currentState.reportFilterTabTitle == onlineExamKey,
                onTap: () {
                  context
                      .read<ReportTabSelectionCubit>()
                      .changeReportFilterTabTitle(onlineExamKey);
                  getExamOnlineReport();
                },
                titleKey: onlineExamKey,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget setSectionTitle({required String titleTxt, required int totalVal}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        (totalVal != 0) ? "$titleTxt -> $totalVal" : titleTxt,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: UiUtils.getColorScheme(context).secondary,
        ),
      ),
    );
  }

  Widget setProgressbar({
    required double val,
    required Color bgColor,
    required Color valueColor,
  }) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * (0.25),
      width: MediaQuery.of(context).size.width * (0.25),
      child: CircularProgressIndicator(
        strokeWidth: 8,
        value: val.isNaN ? 0 : val,
        backgroundColor: bgColor,
        valueColor: AlwaysStoppedAnimation<Color>(valueColor),
      ),
    );
  }

  Widget setStatsChart({
    required Color baseColor,
    required Color progressColor,
    required double progressValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: setProgressbar(
        val: progressValue,
        bgColor: baseColor,
        valueColor: progressColor,
      ),
    );
  }

  Widget setStatsText({
    Color? indicatorColor,
    required String titleTxt,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          if (indicatorColor != null)
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          10.sizedBoxWidth,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: UiUtils.getColorScheme(context)
                        .secondary
                        .withOpacity(0.75),
                  ),
                  text: "$titleTxt : ",
                ),
                TextSpan(
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: UiUtils.getColorScheme(context).secondary,
                  ),
                  text: value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget totalAssignmentAndPointsSection({
    required String titleTxt,
    required int titleValue,
    required String statsTitle1,
    required String statsTitle2,
    required String statsValue1,
    required String statsValue2,
    Color? baseColor,
    required Color progressColor,
    required double progressValue,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          setSectionTitle(titleTxt: titleTxt, totalVal: titleValue),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: 2,
                color: UiUtils.getColorScheme(context).background,
              ),
            ),
            child: Row(
              children: [
                if (baseColor != null)
                  setStatsChart(
                    progressValue: progressValue,
                    progressColor: progressColor,
                    baseColor: baseColor,
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (baseColor != null)
                        ? setStatsText(
                            indicatorColor: progressColor,
                            titleTxt: statsTitle1,
                            value: statsValue1,
                          )
                        : setStatsText(
                            titleTxt: statsTitle1,
                            value: statsValue1,
                          ),
                    setStatsText(
                      indicatorColor: baseColor,
                      titleTxt: statsTitle2,
                      value: statsValue2,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget assignmentPointsDetails(AssignmentReportFetchSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        setSectionTitle(
          titleTxt:
              "${UiUtils.getTranslatedLabel(context, assignmentKey)} ${UiUtils.getTranslatedLabel(context, pointsKey)}",
          totalVal: 0,
        ),
        distinctPointValue(state),
      ],
    );
  }

  Widget pointsBackgroundContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: MediaQuery.of(context).size.width * (0.90),
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: child,
    );
  }

  Widget distinctPointValue(AssignmentReportFetchSuccess state) {
    return Column(
      children: List.generate(
        state.submittedAssignmentWithPointsData.total!,
        (index) => pointsBackgroundContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${UiUtils.getTranslatedLabel(context, pointsKey)} : ${state.submittedAssignmentWithPointsData.data![index].obtainedPoints ?? 0} / ${state.submittedAssignmentWithPointsData.data![index].totalPoints ?? 0}",
                style: TextStyle(
                  color: UiUtils.getColorScheme(context).onBackground,
                  fontWeight: FontWeight.w600,
                  fontSize: UiUtils.screenTitleFontSize,
                ),
              ),
              Text(
                state.submittedAssignmentWithPointsData.data![index]
                    .assignmentName!,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget onlineExamPointsDetails(OnlineExamReportFetchSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        setSectionTitle(
          titleTxt:
              "${UiUtils.getTranslatedLabel(context, onlineExamKey)} ${UiUtils.getTranslatedLabel(context, pointsKey)}",
          totalVal: 0,
        ),
        distinctOnlineExamPointValue(state),
      ],
    );
  }

  Widget distinctOnlineExamPointValue(OnlineExamReportFetchSuccess state) {
    return Column(
      children: List.generate(
        state.examList.total!,
        (index) => pointsBackgroundContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${UiUtils.getTranslatedLabel(context, pointsKey)} : ${state.examList.data![index].obtainedMarks} / ${state.examList.data![index].totalMarks}",
                style: TextStyle(
                  color: UiUtils.getColorScheme(context).onBackground,
                  fontWeight: FontWeight.w600,
                  fontSize: UiUtils.screenTitleFontSize,
                ),
              ),
              Text(state.examList.data![index].title!)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStudentReport() {
    return BlocBuilder<ReportTabSelectionCubit, ReportTabSelectionState>(
      builder: (context, state) {
        if (state.reportFilterTabTitle == assignmentKey) {
          //Assignment
          return BlocBuilder<AssignmentReportCubit, AssignmentReportState>(
            builder: (context, state) {
              if (state is AssignmentReportFetchSuccess) {
                return SingleChildScrollView(
                  controller: _reportAssignmentController,
                  padding: EdgeInsets.only(
                    top: UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarBiggerHeightPercentage,
                    ),
                  ),
                  child: Column(
                    children: [
                      totalAssignmentAndPointsSection(
                        progressValue:
                            state.submittedAssignments! / state.assignments!,
                        progressColor: UiUtils.getColorScheme(context).error,
                        baseColor: UiUtils.getColorScheme(context).onPrimary,
                        statsTitle1:
                            UiUtils.getTranslatedLabel(context, submittedKey),
                        statsValue1: state.submittedAssignments.toString(),
                        statsTitle2:
                            UiUtils.getTranslatedLabel(context, pendingKey),
                        statsValue2: state.unsubmittedAssignments.toString(),
                        titleTxt:
                            "${UiUtils.getTranslatedLabel(context, totalKey)} ${UiUtils.getTranslatedLabel(context, assignmentsKey)}",
                        titleValue: state.assignments!,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "* ${UiUtils.getTranslatedLabel(context, reportNoteKey)}",
                        ),
                      ),
                      totalAssignmentAndPointsSection(
                        statsTitle1:
                            UiUtils.getTranslatedLabel(context, obtainedKey),
                        statsValue1: state.totalObtainedPoints!,
                        statsTitle2:
                            UiUtils.getTranslatedLabel(context, percentageKey),
                        statsValue2: '${state.percentage} %',
                        titleTxt:
                            "${UiUtils.getTranslatedLabel(context, totalKey)} ${UiUtils.getTranslatedLabel(context, pointsKey)}",
                        titleValue: int.parse(state.totalPoints!),
                        progressValue: int.parse(state.totalObtainedPoints!) /
                            int.parse(state.totalPoints!),
                        progressColor: UiUtils.getColorScheme(context).primary,
                      ),
                      assignmentPointsDetails(state)
                    ],
                  ),
                );
              }
              if (state is AssignmentReportFetchFailure) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarBiggerHeightPercentage,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: getAssignmentReport,
                    ),
                  ),
                );
              }
              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: UiUtils.getColorScheme(context).primary,
                ),
              );
            },
          );
        } else {
          //Online exam
          return BlocBuilder<OnlineExamReportCubit, OnlineExamReportState>(
            builder: (context, state) {
              if (state is OnlineExamReportFetchSuccess) {
                return SingleChildScrollView(
                  controller: _reportOnlineExamController,
                  padding: EdgeInsets.only(
                    top: UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarBiggerHeightPercentage,
                    ),
                  ),
                  child: Column(
                    children: [
                      totalAssignmentAndPointsSection(
                        progressValue: state.attempted! / state.totalExams!,
                        progressColor: UiUtils.getColorScheme(context).error,
                        baseColor: UiUtils.getColorScheme(context).onPrimary,
                        statsTitle1:
                            UiUtils.getTranslatedLabel(context, attemptedKey),
                        statsValue1: state.attempted.toString(),
                        statsTitle2:
                            UiUtils.getTranslatedLabel(context, missedKey),
                        statsValue2: state.missedExams.toString(),
                        titleTxt:
                            "${UiUtils.getTranslatedLabel(context, totalKey)} ${UiUtils.getTranslatedLabel(context, onlineExamKey)}",
                        titleValue: state.totalExams!,
                      ),
                      totalAssignmentAndPointsSection(
                        progressValue: int.parse(state.totalObtainedMarks!) /
                            int.parse(state.totalMarks!),
                        progressColor: UiUtils.getColorScheme(context).primary,
                        statsTitle1:
                            UiUtils.getTranslatedLabel(context, obtainedKey),
                        statsValue1: state.totalObtainedMarks!,
                        statsTitle2: UiUtils.getTranslatedLabel(
                          context,
                          percentageKey,
                        ),
                        statsValue2: "${state.percentage!} %",
                        titleTxt:
                            "${UiUtils.getTranslatedLabel(context, totalKey)} ${UiUtils.getTranslatedLabel(context, pointsKey)}",
                        titleValue: int.parse(state.totalMarks!),
                      ),
                      onlineExamPointsDetails(state)
                    ],
                  ),
                );
              }
              if (state is OnlineExamReportFetchFailure) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarBiggerHeightPercentage,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: state.errorMessage ==
                            ErrorMessageKeysAndCode.noOnlineExamReportFoundCode
                        ? NoDataContainer(
                            titleKey: ErrorMessageKeysAndCode
                                .getErrorMessageKeyFromCode(state.errorMessage),
                          )
                        : ErrorContainer(
                            errorMessageCode: state.errorMessage,
                            onTapRetry: getExamOnlineReport,
                          ),
                  ),
                );
              }
              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: UiUtils.getColorScheme(context).primary,
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ReportTabSelectionCubit, ReportTabSelectionState>(
        builder: (context, state) {
          return Stack(
            children: [
              buildStudentReport(),
              buildReportAppBar(state),
            ],
          );
        },
      ),
    );
  }
}
