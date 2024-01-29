import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/studentSubjectsCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/parentRepository.dart';
import 'package:eschool/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/subjectsShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/studentSubjectsContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChildDetailsScreen extends StatefulWidget {
  final Student student;
  const ChildDetailsScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<ChildSubjectsCubit>(
        create: (context) => ChildSubjectsCubit(ParentRepository()),
        child: ChildDetailsScreen(
          student: routeSettings.arguments as Student,
        ),
      ),
    );
  }
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<ChildSubjectsCubit>().fetchChildSubjects(widget.student.id);
    });
    super.initState();
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: ScreenTopBackgroundContainer(
        padding: EdgeInsets.zero,
        heightPercentage: UiUtils.appBarBiggerHeightPercentage,
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Stack(
              children: [
                //Bordered circles
                PositionedDirectional(
                  top: MediaQuery.of(context).size.width * (-0.15),
                  start: MediaQuery.of(context).size.width * (-0.225),
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(
                      end: 20.0,
                      bottom: 20.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.1),
                      ),
                      shape: BoxShape.circle,
                    ),
                    width: MediaQuery.of(context).size.width * (0.6),
                    height: MediaQuery.of(context).size.width * (0.6),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                //bottom fill circle
                PositionedDirectional(
                  bottom: MediaQuery.of(context).size.width * (-0.15),
                  end: MediaQuery.of(context).size.width * (-0.15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    width: MediaQuery.of(context).size.width * (0.4),
                    height: MediaQuery.of(context).size.width * (0.4),
                  ),
                ),
                CustomBackButton(
                  topPadding: MediaQuery.of(context).padding.top +
                      UiUtils.appBarContentTopPadding,
                ),
                Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top +
                          UiUtils.appBarContentTopPadding,
                      left: 10,
                      right: 10.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BorderedProfilePictureContainer(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.studentProfile,
                              arguments: widget.student,
                            );
                          },
                          heightAndWidthPercentage: 0.16,
                          boxConstraints: boxConstraints,
                          imageUrl: widget.student.image,
                        ),
                        SizedBox(
                          height: boxConstraints.maxHeight * (0.045),
                        ),
                        Text(
                          widget.student.getFullName(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: boxConstraints.maxHeight * (0.0125),
                        ),
                        Text(
                          "${UiUtils.getTranslatedLabel(context, classKey)} - ${widget.student.classSectionName}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                BlocBuilder<ChildSubjectsCubit, ChildSubjectsState>(
                  builder: (context, state) {
                    if (state is ChildSubjectsFetchSuccess) {
                      return Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: IconButton(
                          color: Theme.of(context).colorScheme.background,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                UiUtils.appBarContentTopPadding,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              Routes.parentMenu,
                              arguments: {
                                "student": widget.student,
                                "subjectsForFilter": context
                                    .read<ChildSubjectsCubit>()
                                    .getSubjectsForAssignmentContainer()
                              },
                            );
                          },
                          icon: const Icon(Icons.more_vert),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubjectsAndInformationsContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
        ),
      ),
      child: BlocBuilder<ChildSubjectsCubit, ChildSubjectsState>(
        builder: (context, state) {
          if (state is ChildSubjectsFetchSuccess) {
            return Column(
              children: [
                StudentSubjectsContainer(
                  subjects: context.read<ChildSubjectsCubit>().getSubjects(),
                  subjectsTitleKey: subjectsKey,
                  childId: widget.student.id,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
              ],
            );
          }
          if (state is ChildSubjectsFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessageCode: state.errorMessage,
                onTapRetry: () {
                  context
                      .read<ChildSubjectsCubit>()
                      .fetchChildSubjects(widget.student.id);
                },
              ),
            );
          }
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),
              const SubjectsShimmerLoadingContainer(),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildSubjectsAndInformationsContainer(),
          _buildAppBar(),
        ],
      ),
    );
  }
}
