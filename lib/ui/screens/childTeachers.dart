import 'package:eschool/cubits/childTeachersCubit.dart';
import 'package:eschool/data/models/teacher.dart';
import 'package:eschool/data/repositories/parentRepository.dart';
import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChildTeachersScreen extends StatefulWidget {
  final int childId;
  const ChildTeachersScreen({Key? key, required this.childId})
      : super(key: key);

  @override
  State<ChildTeachersScreen> createState() => _ChildTeachersScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<ChildTeachersCubit>(
        create: (context) => ChildTeachersCubit(ParentRepository()),
        child: ChildTeachersScreen(childId: routeSettings.arguments as int),
      ),
    );
  }
}

class _ChildTeachersScreenState extends State<ChildTeachersScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context
          .read<ChildTeachersCubit>()
          .fetchChildTeachers(childId: widget.childId);
    });
    super.initState();
  }

  Widget _buildTeacherDetailsContainer(Teacher teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 80,
      width: MediaQuery.of(context).size.width * (0.85),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(2.5, 2.5),
            blurRadius: 10,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
          )
        ],
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary,
                ),
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: boxConstraints.maxWidth * (0.25),
                height: double.maxFinite,
                child: CustomUserProfileImageWidget(
                  profileUrl: teacher.profileUrl,
                  radius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(
                width: boxConstraints.maxWidth * (0.05),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${teacher.firstName} ${teacher.lastName}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      teacher.subjectName,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.025),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.call,
                            size: 12,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.025),
                        ),
                        Text(
                          teacher.mobile,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeacherDetailsShimmerLoadingContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 80,
      width: MediaQuery.of(context).size.width * (0.85),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Row(
            children: [
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  margin: const EdgeInsets.symmetric(vertical: 7.5),
                  width: boxConstraints.maxWidth * (0.25),
                  height: 70,
                ),
              ),
              SizedBox(
                width: boxConstraints.maxWidth * (0.05),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                      margin: const EdgeInsets.only(bottom: 5.0),
                      width: boxConstraints.maxWidth * (0.55),
                    ),
                  ),
                  ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      width: boxConstraints.maxWidth * (0.45),
                    ),
                  ),
                  ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.35),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeachers() {
    return BlocBuilder<ChildTeachersCubit, ChildTeachersState>(
      builder: (context, state) {
        if (state is ChildTeachersFetchSuccess) {
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: UiUtils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
                ),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: state.teachers.isEmpty
                      ? [const NoDataContainer(titleKey: noTeachersFoundKey)]
                      : List.generate(
                          state.teachers.length,
                          (index) => Animate(
                            effects: listItemAppearanceEffects(
                              itemIndex: index,
                              totalLoadedItems: state.teachers.length,
                            ),
                            child: _buildTeacherDetailsContainer(
                              state.teachers[index],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          );
        }
        if (state is ChildTeachersFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: () {
                context
                    .read<ChildTeachersCubit>()
                    .fetchChildTeachers(childId: widget.childId);
              },
            ),
          );
        }
        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: UiUtils.getScrollViewTopPadding(
                context: context,
                appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
              ),
            ),
            child: Column(
              children: List.generate(
                UiUtils.defaultShimmerLoadingContentCount,
                (index) => index,
              )
                  .map((e) => _buildTeacherDetailsShimmerLoadingContainer())
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildTeachers(),
          Align(
            alignment: Alignment.topCenter,
            child: CustomAppBar(
              title: UiUtils.getTranslatedLabel(context, teachersKey),
            ),
          ),
        ],
      ),
    );
  }
}
