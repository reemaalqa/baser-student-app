import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/examDetailsCubit.dart';
import 'package:eschool/data/models/exam.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/examsFilterContainer.dart';
import 'package:eschool/ui/widgets/listItemForExamAndResult.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamOfflineListContainer extends StatefulWidget {
  final int? childId;

  const ExamOfflineListContainer({Key? key, this.childId}) : super(key: key);

  @override
  State<ExamOfflineListContainer> createState() =>
      _ExamOfflineListContainerState();
}

class _ExamOfflineListContainerState extends State<ExamOfflineListContainer> {
  String _currentlySelectedExamFilter = allExamsKey;

  @override
  void initState() {
    super.initState();
    fetchExamsList();
  }

  void fetchExamsList() {
    Future.delayed(Duration.zero, () {
      //
      //Exam status: 0- All exam, 1-Upcoming, 2-Ongoing, 3-Completed
      context.read<ExamDetailsCubit>().fetchStudentExamsList(
            useParentApi: context.read<AuthCubit>().isParent(),
            childId: widget.childId,
            examStatus: 0,
          );
    });
  }

  Widget _buildExamList(List<Exam> examList) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            examList.length,
            (index) => ListItemForExamAndResult(
              index: index,
              examStartingDate: examList[index].examStartingDate!,
              examName: examList[index].examName!,
              resultPercentage: 0,
              resultGrade: '',
              onItemTap: () {
                //if examStartingDate is empty then there is no exam timetable
                if (examList[index].examStartingDate! == '') {
                  UiUtils.showCustomSnackBar(
                    context: context,
                    errorMessage: UiUtils.getTranslatedLabel(
                      context,
                      noExamTimeTableFoundKey,
                    ),
                    backgroundColor: UiUtils.getColorScheme(context).error,
                  );
                  return;
                }
                Navigator.of(context).pushNamed(
                  Routes.examTimeTable,
                  arguments: {
                    'examID': examList[index].examID,
                    'examName': examList[index].examName.toString(),
                    'childID': widget.childId
                  },
                );
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

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      displacment: UiUtils.getScrollViewTopPadding(
        context: context,
        appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
      ),
      onRefreshCallback: () {
        //
        //Exam status: 0- All exam, 1-Upcoming, 2-Ongoing, 3-Completed
        final int examStatus =
            examFilters.indexOf(_currentlySelectedExamFilter);
        context.read<ExamDetailsCubit>().fetchStudentExamsList(
              examStatus: examStatus,
              useParentApi: context.read<AuthCubit>().isParent(),
              childId: widget.childId,
            );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: UiUtils.getScrollViewBottomPadding(context),
          top: UiUtils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
          ),
        ),
        child: Column(
          children: [
            //Filter
            ExamFiltersContainer(
              onTapSubject: (examFilterIndex) {
                //
                //Exam status: 0-All exam, 1-Upcoming, 2-Ongoing, 3-Completed
                context.read<ExamDetailsCubit>().fetchStudentExamsList(
                      useParentApi: context.read<AuthCubit>().isParent(),
                      childId: widget.childId,
                      examStatus:
                          examFilters.indexOf(examFilters[examFilterIndex]),
                    );

                setState(() {
                  _currentlySelectedExamFilter = examFilters[examFilterIndex];
                });
              },
              selectedExamFilterIndex:
                  examFilters.indexOf(_currentlySelectedExamFilter),
            ),

            BlocBuilder<ExamDetailsCubit, ExamDetailsState>(
              builder: (context, state) {
                if (state is ExamDetailsFetchSuccess) {
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
                              _buildExamList(state.examList),
                            ],
                          ),
                  );
                }
                if (state is ExamDetailsFetchFailure) {
                  return ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: () {
                      context.read<ExamDetailsCubit>().fetchStudentExamsList(
                            useParentApi: context.read<AuthCubit>().isParent(),
                            childId: widget.childId,
                            examStatus: examFilters
                                .indexOf(_currentlySelectedExamFilter),
                          );
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
