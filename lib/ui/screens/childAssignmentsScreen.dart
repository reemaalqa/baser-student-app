import 'package:eschool/cubits/assignmentsCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/data/repositories/assignmentRepository.dart';
import 'package:eschool/ui/widgets/assignmentFilterBottomsheetContainer.dart';
import 'package:eschool/ui/widgets/assignmentsContainer.dart';
import 'package:eschool/ui/widgets/assignmentListContainer.dart';
import 'package:eschool/ui/widgets/assignmentsSubjectsContainer.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/svgButton.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChildAssignmentsScreen extends StatefulWidget {
  final int childId;
  final List<Subject> subjects;
  const ChildAssignmentsScreen({
    Key? key,
    required this.childId,
    required this.subjects,
  }) : super(key: key);

  @override
  State<ChildAssignmentsScreen> createState() => _ChildAssignmentsScreenState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<AssignmentsCubit>(
        create: (context) => AssignmentsCubit(AssignmentRepository()),
        child: ChildAssignmentsScreen(
          childId: arguments['childId'],
          subjects: arguments['subjects'],
        ),
      ),
    );
  }
}

class _ChildAssignmentsScreenState extends State<ChildAssignmentsScreen> {
  String _assignmentStatusTabTitle = assignedKey;

  int _currentlySelectedSubjectId = 0;

  late AssignmentFilters selectedAssignmentFilter =
      AssignmentFilters.assignedDateLatest;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_assignmentsScrollListener);

  int isAssignmentSubmitted() {
    return _assignmentStatusTabTitle == assignedKey ? 0 : 1;
  }

  void _assignmentsScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<AssignmentsCubit>().hasMore()) {
        context.read<AssignmentsCubit>().fetchMoreAssignments(
              childId: widget.childId,
              isSubmitted: isAssignmentSubmitted(),
              useParentApi: context.read<AuthCubit>().isParent(),
            );
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchAssignments();
    });
    super.initState();
  }

  void fetchAssignments() {
    context.read<AssignmentsCubit>().fetchAssignments(
          useParentApi: context.read<AuthCubit>().isParent(),
          childId: widget.childId,
          isSubmitted: isAssignmentSubmitted(),
          subjectId: _currentlySelectedSubjectId,
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

  @override
  void dispose() {
    _scrollController.removeListener(_assignmentsScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAppBarContainer() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              const CustomBackButton(),
              _assignmentStatusTabTitle == submittedKey
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
                          svgIconUrl: UiUtils.getImagePath("filter_icon.svg"),
                        ),
                      ),
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
              AnimatedAlign(
                curve: UiUtils.tabBackgroundContainerAnimationCurve,
                duration: UiUtils.tabBackgroundContainerAnimationDuration,
                alignment: _assignmentStatusTabTitle == assignedKey
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child:
                    TabBarBackgroundContainer(boxConstraints: boxConstraints),
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerStart,
                isSelected: _assignmentStatusTabTitle == assignedKey,
                onTap: () {
                  setState(() {
                    _assignmentStatusTabTitle = assignedKey;
                  });
                  fetchAssignments();
                },
                titleKey: assignedKey,
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerEnd,
                isSelected: _assignmentStatusTabTitle == submittedKey,
                onTap: () {
                  //
                  setState(() {
                    _assignmentStatusTabTitle = submittedKey;
                  });
                  fetchAssignments();
                },
                titleKey: submittedKey,
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildAssignments() {
    return CustomRefreshIndicator(
      displacment: UiUtils.getScrollViewTopPadding(
        context: context,
        appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
      ),
      onRefreshCallback: () {
        fetchAssignments();
      },
      child: SizedBox(
        height: double.maxFinite,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: UiUtils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
            ),
          ),
          child: Column(
            children: [
              //
              AssignmentsSubjectContainer(
                cubitAndState: "assignment",
                subjects: widget.subjects,
                onTapSubject: (int subjectId) {
                  setState(() {
                    _currentlySelectedSubjectId = subjectId;
                  });

                  fetchAssignments();
                },
                selectedSubjectId: _currentlySelectedSubjectId,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.035),
              ),
              AssignmentListContainer(
                assignmentTabTitle: _assignmentStatusTabTitle,
                currentSelectedSubjectId: _currentlySelectedSubjectId,
                selectedAssignmentFilter: selectedAssignmentFilter,
                isAssignmentSubmitted: isAssignmentSubmitted(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAssignments(),
          _buildAppBarContainer(),
        ],
      ),
    );
  }
}
