import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool/cubits/examTabSelectionCubit.dart';
import 'package:eschool/cubits/examsOnlineCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';

import 'package:eschool/data/models/examsOnline.dart';
import 'package:eschool/data/models/subject.dart';

import 'package:eschool/ui/widgets/assignmentsSubjectsContainer.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/examOnlineKeyBottomsheetContainer.dart';
import 'package:eschool/ui/widgets/listItemForOnlineExamAndOnlineResult.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';

import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';

class ExamOnlineListContainer extends StatefulWidget {
  final int? childId;
  final List<Subject>? subjects;

  const ExamOnlineListContainer({Key? key, this.childId, this.subjects})
      : super(key: key);

  @override
  State<ExamOnlineListContainer> createState() =>
      _ExamOnlineListContainerState();
}

class _ExamOnlineListContainerState extends State<ExamOnlineListContainer> {
  late ExamsOnline examSelected;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_examOnlinesScrollListener);

  void _examOnlinesScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<ExamsOnlineCubit>().hasMore()) {
        context.read<ExamsOnlineCubit>().getMoreExamsOnline(
              childId: widget.childId ?? 0,
              useParentApi: context.read<AuthCubit>().isParent(),
            );
      }
    }
  }

  void fetchExamsList() {
    Future.delayed(Duration.zero, () {
      context.read<ExamsOnlineCubit>().getExamsOnline(
            subjectId: context
                .read<ExamTabSelectionCubit>()
                .state
                .examFilterBySubjectId,
            childId: widget.childId ?? 0,
            useParentApi: context.read<AuthCubit>().isParent(),
          );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchExamsList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_examOnlinesScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> navigateToExamScreen() async {
    Navigator.of(context).pop();

    Navigator.of(context).pushNamed(
      Routes.examOnline,
      arguments: {
        "exam": examSelected,
      },
    );
  }

  void onTapOnlineExam(ExamsOnline exam) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      elevation: 5.0,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return ExamOnlineKeyBottomsheetContainer(
          navigateToExamScreen: navigateToExamScreen,
          exam: exam,
        );
      },
    );
  }

  Widget _buildExamOnlineList(List<ExamsOnline> examList) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            examList.length,
            (index) => ListItemForOnlineExamAndOnlineResult(
              examStartingDate: examList[index].startDate,
              examEndingDate: examList[index].endDate,
              examName: examList[index].title,
              subjectName: examList[index].subject.showType
                  ? examList[index].subject.subjectNameWithType
                  : examList[index].subject.name,
              totalMarks: examList[index].totalMarks,
              isSubjectSelected: context
                      .read<ExamTabSelectionCubit>()
                      .state
                      .examFilterBySubjectId !=
                  0,
              marks: '',
              onItemTap: () {
                if (context.read<AuthCubit>().isParent()) {
                  //do not allow parent to attend exam
                } else {
                  setState(() {
                    examSelected = examList[index];
                    //to be passed to Main Exam screen
                  });
                  if (DateTime.now()
                          .difference(
                            DateTime.parse(examList[index].endDate),
                          )
                          .inDays >
                      0) {
                    UiUtils.showCustomSnackBar(
                      context: context,
                      errorMessage: UiUtils.getTranslatedLabel(
                        context,
                        noExamTodayKey,
                      ),
                      backgroundColor: UiUtils.getColorScheme(context).error,
                    );
                    return;
                  }
                  //if exam is today & before exam end time, then only student can attend Exam
                  if (DateTime.now().isBefore(
                    DateTime.parse(examList[index].endDate),
                  )) {
                    onTapOnlineExam(examList[index]);
                  } else {
                    UiUtils.showCustomSnackBar(
                      context: context,
                      errorMessage: UiUtils.getTranslatedLabel(
                        context,
                        noExamNowKey,
                      ),
                      backgroundColor: UiUtils.getColorScheme(context).error,
                    );
                    return;
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamShimmerLoadingContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        horizontal: UiUtils.screenContentHorizontalPaddingInPercentage *
            MediaQuery.of(context).size.width,
      ),
      child: ShimmerLoadingContainer(
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.035),
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 9,
                    width: boxConstraints.maxWidth * (0.3),
                  ),
                ),
                SizedBox(
                  height: boxConstraints.maxWidth * (0.02),
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 10,
                    width: boxConstraints.maxWidth * (0.8),
                  ),
                ),
                SizedBox(
                  height: boxConstraints.maxWidth * (0.1),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExamLoading() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              UiUtils.defaultShimmerLoadingContentCount,
              (index) => _buildExamShimmerLoadingContainer(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMySubjectsListContainer() {
    return BlocBuilder<StudentSubjectsAndSlidersCubit,
        StudentSubjectsAndSlidersState>(
      builder: (context, state) {
        return BlocBuilder<ExamTabSelectionCubit, ExamTabSelectionState>(
          bloc: context.read<ExamTabSelectionCubit>(),
          builder: (context, state) {
            return AssignmentsSubjectContainer(
              cubitAndState: "onlineExam",
              subjects: (widget.subjects != null)
                  ? widget.subjects! //from parent
                  : context
                      .read<StudentSubjectsAndSlidersCubit>()
                      .getSubjectsForAssignmentContainer(),
              onTapSubject: (subjectId) {
                context
                    .read<ExamTabSelectionCubit>()
                    .changeExamFilterBySubjectId(
                      subjectId,
                    );
                fetchExamsList();
              },
              selectedSubjectId: state.examFilterBySubjectId,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      displacment: UiUtils.getScrollViewTopPadding(
        context: context,
        appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
      ),
      onRefreshCallback: () {
        if (kDebugMode) {
          print("refresh - fetch exams list");
        }
        fetchExamsList();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: UiUtils.getScrollViewBottomPadding(context),
          top: UiUtils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
          ),
        ),
        child: Column(
          children: [
            buildMySubjectsListContainer(),
            BlocBuilder<ExamsOnlineCubit, ExamsOnlineState>(
              builder: (context, state) {
                if (state is ExamsOnlineFetchSuccess) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: state.examList.isEmpty
                        ? const NoDataContainer(titleKey: noExamsFoundKey)
                        : Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    (0.035),
                              ),
                              _buildExamOnlineList(state.examList),
                            ],
                          ),
                  );
                }
                if (state is ExamsOnlineFetchFailure) {
                  return ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: () {
                      if (kDebugMode) {
                        print("Retry - fetch exams list");
                      }
                      fetchExamsList();
                    },
                  );
                }
                return _buildExamLoading();
              },
            ),
          ],
        ),
      ),
    );
  }
}
