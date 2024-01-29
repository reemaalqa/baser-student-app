import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/classElectiveSubjectsCubit.dart';
import 'package:eschool/cubits/selectElectiveSubjectsCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';

import 'package:eschool/data/models/electiveSubject.dart';
import 'package:eschool/data/models/electiveSubjectGroup.dart';
import 'package:eschool/data/repositories/classRepository.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/subjectImageContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectSubjectsScreen extends StatefulWidget {
  const SelectSubjectsScreen({Key? key}) : super(key: key);

  @override
  State<SelectSubjectsScreen> createState() => _SelectSubjectsScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<SelectElectiveSubjectsCubit>(
            create: (_) => SelectElectiveSubjectsCubit(StudentRepository()),
          ),
          BlocProvider<ClassElectiveSubjectsCubit>(
            create: (_) => ClassElectiveSubjectsCubit(ClassRepository()),
          )
        ],
        child: const SelectSubjectsScreen(),
      ),
    );
  }
}

class _SelectSubjectsScreenState extends State<SelectSubjectsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () => context.read<ClassElectiveSubjectsCubit>().fetchElectiveSubjects(),
    );
  }

  Map<int, List<int>> selectedElectiveSubjects = {};

  bool hasAllSubjectElected() {
    bool subjectElected = true;
    for (var key in selectedElectiveSubjects.keys) {
      if (selectedElectiveSubjects[key]!.isEmpty) {
        subjectElected = false;
        break;
      }
    }
    return subjectElected;
  }

  bool isSubjectElected({required int groupId, required int subjectId}) {
    final subjectGroup = context
        .read<ClassElectiveSubjectsCubit>()
        .getElectiveSubjectGroups()
        .where((element) => element.id == groupId)
        .first;
    final selectedElectiveSubjectsOfGroup =
        selectedElectiveSubjects[subjectGroup.id];

    return selectedElectiveSubjectsOfGroup!.contains(subjectId);
  }

  void removeElectedSubject({required int groupId, required int subjectId}) {
    //get the subject group
    final subjectGroup = context
        .read<ClassElectiveSubjectsCubit>()
        .getElectiveSubjectGroups()
        .where((element) => element.id == groupId)
        .first;
    //get the selected subject list for that group
    final selectedElectiveSubjectsOfGroup =
        selectedElectiveSubjects[subjectGroup.id];

    //remove the subject
    selectedElectiveSubjectsOfGroup!.remove(subjectId);
    selectedElectiveSubjects[subjectGroup.id] = selectedElectiveSubjectsOfGroup;

    setState(() {});
  }

  void selectElectiveSubject({required int groupId, required int subjectId}) {
    //get the subject group
    final subjectGroup = context
        .read<ClassElectiveSubjectsCubit>()
        .getElectiveSubjectGroups()
        .where((element) => element.id == groupId)
        .first;
    //get the selected subject list for that group
    final selectedElectiveSubjectsOfGroup =
        selectedElectiveSubjects[subjectGroup.id];

    if (selectedElectiveSubjectsOfGroup!.length ==
        subjectGroup.totalSelectableSubjects) {
      //Show can not select more subject
      UiUtils.showCustomSnackBar(
        context: context,
        errorMessage:
            UiUtils.getTranslatedLabel(context, canNotSelectMoreSubjectsKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } else {
      //add subject
      selectedElectiveSubjectsOfGroup.add(subjectId);
      selectedElectiveSubjects[subjectGroup.id] =
          selectedElectiveSubjectsOfGroup;

      setState(() {});
    }
  }

  Widget _buildAppBar() {
    final currentClass =
        context.read<AuthCubit>().getStudentDetails().classSectionName;
    return Align(
      alignment: Alignment.topCenter,
      child: CustomAppBar(
        showBackButton: false,
        subTitle:
            "${UiUtils.getTranslatedLabel(context, classKey)} $currentClass",
        title: UiUtils.getTranslatedLabel(context, selectSubjectsKey),
      ),
    );
  }

  Widget _buildElectiveSubjectContainer({
    required ElectiveSubject subject,
    required int groupId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            offset: const Offset(3.5, 3.5),
            blurRadius: 10,
          )
        ],
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10.0),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Row(
            children: [
              SubjectImageContainer(
                showShadow: false,
                height: 60,
                radius: 7.5,
                subject: subject,
                width: boxConstraints.maxWidth * (0.2),
              ),
              SizedBox(
                width: boxConstraints.maxWidth * (0.05),
              ),
              SizedBox(
                width: boxConstraints.maxWidth * (0.6),
                child: Text(
                  subject.showType ? subject.subjectNameWithType : subject.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
              ),
              SizedBox(
                width: boxConstraints.maxWidth * (0.075),
              ),
              InkWell(
                onTap: () {
                  if (isSubjectElected(
                    groupId: groupId,
                    subjectId: subject.id,
                  )) {
                    removeElectedSubject(
                      groupId: groupId,
                      subjectId: subject.id,
                    );
                  } else {
                    selectElectiveSubject(
                      groupId: groupId,
                      subjectId: subject.id,
                    );
                  }
                },
                child: Container(
                  width: boxConstraints.maxWidth * (0.075),
                  height: boxConstraints.maxWidth * (0.075),
                  color: Theme.of(context).colorScheme.primary,
                  child:
                      isSubjectElected(groupId: groupId, subjectId: subject.id)
                          ? Icon(
                              Icons.check,
                              size: 17,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            )
                          : const SizedBox(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildElectiveSubjectGroup({
    required ElectiveSubjectGroup electiveSubjectGroup,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${UiUtils.getTranslatedLabel(context, selectAnyKey)} ${electiveSubjectGroup.totalSelectableSubjects}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          ...electiveSubjectGroup.subjects
              .map(
                (subject) => _buildElectiveSubjectContainer(
                  subject: subject,
                  groupId: electiveSubjectGroup.id,
                ),
              )
              .toList()
        ],
      ),
    );
  }

  Widget _buildElectiveSubjectsContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UiUtils.getTranslatedLabel(context, electiveSubjectsKey),
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        ...context
            .read<ClassElectiveSubjectsCubit>()
            .getElectiveSubjectGroups()
            .map((e) => _buildElectiveSubjectGroup(electiveSubjectGroup: e))
            .toList(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Transform.translate(
      offset: const Offset(0.0, -15),
      child: BlocConsumer<SelectElectiveSubjectsCubit,
          SelectElectiveSubjectsState>(
        listener: (context, state) {
          if (state is SelectElectiveSubjectsFailure) {
            UiUtils.showCustomSnackBar(
              context: context,
              errorMessage: UiUtils.getErrorMessageFromErrorCode(
                  context, state.errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            );
          } else if (state is SelectElectiveSubjectsSuccess) {
            //Need to update the elective subjects in studentSubjects cubit
            List<ElectiveSubject> electiveSubjects = [];
            final electiveSubjectGroups = context
                .read<ClassElectiveSubjectsCubit>()
                .getElectiveSubjectGroups();

            //Filtering out all the selected elective subject
            for (var electiveSubjectGroup in electiveSubjectGroups) {
              final subjects = electiveSubjectGroup.subjects.where(
                (element) => state.electedSubjectIds.contains(element.id),
              );
              electiveSubjects.addAll(subjects);
            }

            //update elective subjects in student subject cubit
            context
                .read<StudentSubjectsAndSlidersCubit>()
                .updateElectiveSubjects(electiveSubjects);
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return CustomRoundedButton(
            onTap: () {
              if (state is SelectElectiveSubjectsInProgress) {
                return;
              }
              if (hasAllSubjectElected()) {
                context
                    .read<SelectElectiveSubjectsCubit>()
                    .selectElectiveSubjects(
                      electedSubjectGroups: selectedElectiveSubjects,
                    );
              } else {
                UiUtils.showCustomSnackBar(
                  context: context,
                  errorMessage: UiUtils.getTranslatedLabel(
                    context,
                    pleaseSelectAllElectiveSubjectsKey,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                );
              }
            },
            widthPercentage: 0.4,
            height: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            buttonTitle: UiUtils.getTranslatedLabel(context, submitKey),
            showBorder: false,
            child: state is SelectElectiveSubjectsInProgress
                ? CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                    strokeWidth: 2,
                    widthAndHeight: 18,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildSelectSubjectsShimmerLoadingContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * (0.075),
        right: MediaQuery.of(context).size.width * (0.075),
        top: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  width: boxConstraints.maxWidth * (0.25),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  width: boxConstraints.maxWidth * (0.35),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  height: 80,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  height: 80,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            BlocConsumer<ClassElectiveSubjectsCubit,
                ClassElectiveSubjectsState>(
              listener: (context, state) {
                if (state is ClassElectiveSubjectsFetchSuccess) {
                  //
                  for (var electiveSubjectGroup
                      in state.electiveSubjectGroups) {
                    selectedElectiveSubjects
                        .addAll({electiveSubjectGroup.id: []});
                  }
                  setState(() {});
                }
              },
              builder: (context, state) {
                if (state is ClassElectiveSubjectsFetchSuccess) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * (0.075),
                        right: MediaQuery.of(context).size.width * (0.075),
                        top: UiUtils.getScrollViewTopPadding(
                          context: context,
                          appBarHeightPercentage:
                              UiUtils.appBarSmallerHeightPercentage,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          _buildElectiveSubjectsContainer(),
                          Center(child: _buildSubmitButton()),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ClassElectiveSubjectsFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: () {
                        context
                            .read<ClassElectiveSubjectsCubit>()
                            .fetchElectiveSubjects();
                      },
                    ),
                  );
                }

                return _buildSelectSubjectsShimmerLoadingContainer();
              },
            ),
            _buildAppBar(),
          ],
        ),
      ),
    );
  }
}
