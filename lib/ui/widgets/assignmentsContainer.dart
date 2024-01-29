import 'package:eschool/cubits/assignmentsCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/screens/home/cubits/assignmentsTabSelectionCubit.dart';
import 'package:eschool/ui/widgets/assignmentFilterBottomsheetContainer.dart';
import 'package:eschool/ui/widgets/assignmentListContainer.dart';
import 'package:eschool/ui/widgets/assignmentsSubjectsContainer.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/svgButton.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AssignmentFilters {
  assignedDateLatest,
  assignedDateOldest,
  dueDateLatest,
  dueDateOldest
}

class AssignmentsContainer extends StatefulWidget {
  //Need this flag in order to show the assignments container
  //in background when bottm menu is open

  //If it is just for background showing purpose then it will not reactive or not making any api call
  final bool isForBottomMenuBackground;
  const AssignmentsContainer({
    Key? key,
    required this.isForBottomMenuBackground,
  }) : super(key: key);

  @override
  State<AssignmentsContainer> createState() => _AssignmentsContainerState();
}

class _AssignmentsContainerState extends State<AssignmentsContainer> {
  late AssignmentFilters selectedAssignmentFilter =
      AssignmentFilters.assignedDateLatest;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_assignmentsScrollListener);

  void _assignmentsScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<AssignmentsCubit>().hasMore()) {
        context.read<AssignmentsCubit>().fetchMoreAssignments(
              childId: 0,
              isSubmitted: 0,
              useParentApi: context.read<AuthCubit>().isParent(),
            );
        //to scroll to last in order for users to see the progress
        Future.delayed(const Duration(milliseconds: 10), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        });
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (!widget.isForBottomMenuBackground) {
        fetchAssignments();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_assignmentsScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchAssignments() {
    context.read<AssignmentsCubit>().fetchAssignments(
          childId: 0,
          isSubmitted: context
              .read<AssignmentsTabSelectionCubit>()
              .isAssignmentSubmitted(),
          subjectId: context
              .read<AssignmentsTabSelectionCubit>()
              .state
              .assignmentFilterBySubjectId,
          useParentApi: context.read<AuthCubit>().isParent(),
        );
  }

  void changeAssignmentFilter(AssignmentFilters assignmentFilter) {
    setState(() {
      selectedAssignmentFilter = assignmentFilter;
    });
  }

  void onTapFilterButton() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
          topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
        ),
      ),
      context: context,
      builder: (_) => AssignmentFilterBottomsheetContainer(
        changeAssignmentFilter: changeAssignmentFilter,
        initialAssignmentFilterValue: selectedAssignmentFilter,
      ),
    );
  }

  Widget _buildMySubjectsListContainer() {
    return BlocBuilder<StudentSubjectsAndSlidersCubit,
        StudentSubjectsAndSlidersState>(
      builder: (context, state) {
        //
        List<Subject> subjects = context
            .read<StudentSubjectsAndSlidersCubit>()
            .getSubjectsForAssignmentContainer();

        return BlocBuilder<AssignmentsTabSelectionCubit,
            AssignmentsTabSelectionState>(
          bloc: context.read<AssignmentsTabSelectionCubit>(),
          builder: (context, state) {
            return AssignmentsSubjectContainer(
              cubitAndState: "assignment",
              subjects: subjects,
              onTapSubject: (int subjectId) {
                context
                    .read<AssignmentsTabSelectionCubit>()
                    .changeAssignmentFilterBySubjectId(
                      subjectId,
                    );
                fetchAssignments();
              },
              selectedSubjectId: state.assignmentFilterBySubjectId,
            );
          },
        );
      },
    );
  }

  Widget _buildAppBarContainer() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              BlocBuilder<AssignmentsTabSelectionCubit,
                  AssignmentsTabSelectionState>(
                builder: (context, state) {
                  return state.assignmentFilterTabTitle == submittedKey
                      ? const SizedBox()
                      : Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: UiUtils.screenContentHorizontalPadding,
                            ),
                            child: SvgButton(
                              onTap: () {
                                onTapFilterButton();
                              },
                              svgIconUrl:
                                  UiUtils.getImagePath("filter_icon.svg"),
                            ),
                          ),
                        );
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  UiUtils.getTranslatedLabel(context, assignmentsKey),
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: UiUtils.screenTitleFontSize,
                  ),
                ),
              ),
              BlocBuilder<AssignmentsTabSelectionCubit,
                  AssignmentsTabSelectionState>(
                bloc: context.read<AssignmentsTabSelectionCubit>(),
                builder: (context, state) {
                  return AnimatedAlign(
                    curve: UiUtils.tabBackgroundContainerAnimationCurve,
                    duration: UiUtils.tabBackgroundContainerAnimationDuration,
                    alignment: state.assignmentFilterTabTitle == assignedKey
                        ? AlignmentDirectional.centerStart
                        : AlignmentDirectional.centerEnd,
                    child: TabBarBackgroundContainer(
                      boxConstraints: boxConstraints,
                    ),
                  );
                },
              ),
              BlocBuilder<AssignmentsTabSelectionCubit,
                  AssignmentsTabSelectionState>(
                bloc: context.read<AssignmentsTabSelectionCubit>(),
                builder: (context, state) {
                  return CustomTabBarContainer(
                    boxConstraints: boxConstraints,
                    alignment: AlignmentDirectional.centerStart,
                    isSelected: state.assignmentFilterTabTitle == assignedKey,
                    onTap: () {
                      context
                          .read<AssignmentsTabSelectionCubit>()
                          .changeAssignmentFilterTabTitle(assignedKey);
                      fetchAssignments();
                    },
                    titleKey: assignedKey,
                  );
                },
              ),
              BlocBuilder<AssignmentsTabSelectionCubit,
                  AssignmentsTabSelectionState>(
                bloc: context.read<AssignmentsTabSelectionCubit>(),
                builder: (context, state) {
                  return CustomTabBarContainer(
                    boxConstraints: boxConstraints,
                    alignment: AlignmentDirectional.centerEnd,
                    isSelected: state.assignmentFilterTabTitle == submittedKey,
                    onTap: () {
                      context
                          .read<AssignmentsTabSelectionCubit>()
                          .changeAssignmentFilterTabTitle(submittedKey);
                      fetchAssignments();
                    },
                    titleKey: submittedKey,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomRefreshIndicator(
          displacment: UiUtils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
          ),
          onRefreshCallback: () {
            fetchAssignments();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: UiUtils.getScrollViewTopPadding(
                context: context,
                appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
              ),
              bottom: UiUtils.getScrollViewBottomPadding(context),
            ),
            child: Column(
              children: [
                _buildMySubjectsListContainer(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.035),
                ),
                BlocBuilder<AssignmentsTabSelectionCubit,
                    AssignmentsTabSelectionState>(
                  builder: (context, state) {
                    return AssignmentListContainer(
                      animateItems: !widget
                          .isForBottomMenuBackground, //if it's just for background don't animate items
                      assignmentTabTitle: state.assignmentFilterTabTitle,
                      currentSelectedSubjectId:
                          state.assignmentFilterBySubjectId,
                      selectedAssignmentFilter: selectedAssignmentFilter,
                      isAssignmentSubmitted: context
                          .read<AssignmentsTabSelectionCubit>()
                          .isAssignmentSubmitted(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _buildAppBarContainer(),
        )
      ],
    );
  }
}
