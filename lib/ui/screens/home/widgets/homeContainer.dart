import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/noticeBoardCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/data/repositories/settingsRepository.dart';
import 'package:eschool/ui/screens/home/homeScreen.dart';
import 'package:eschool/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/customShowCaseWidget.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/latestNoticesContainer.dart';
import 'package:eschool/ui/widgets/notificationIconWidget.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/subjectsShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/slidersContainer.dart';
import 'package:eschool/ui/widgets/studentSubjectsContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeContainer extends StatefulWidget {
  //Need this flag in order to show the homeContainer
  //in background when bottom menu is open

  //If it is just for background showing purpose then it will not reactive or not making any api call
  final bool isForBottomMenuBackground;
  const HomeContainer({Key? key, required this.isForBottomMenuBackground})
      : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  final GlobalKey _profilePictureNavigationShowCaseGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (!widget.isForBottomMenuBackground) {
      Future.delayed(Duration.zero, () async {
        context
            .read<StudentSubjectsAndSlidersCubit>()
            .fetchSubjectsAndSliders();
        context
            .read<NoticeBoardCubit>()
            .fetchNoticeBoardDetails(useParentApi: false);
        final count = await SettingsRepository().getNotificationCount();
        //if there were any notifications while app was closed, the hive box will have it's accurate value
        notificationCountValueNotifier.value = count;
      });
    }
  }

  Widget _buildTopProfileContainer(BuildContext context) {
    return ScreenTopBackgroundContainer(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              //Bordered circles
              PositionedDirectional(
                top: MediaQuery.of(context).size.width * (-0.15),
                start: MediaQuery.of(context).size.width * (-0.225),
                child: Container(
                  padding:
                      const EdgeInsetsDirectional.only(end: 20.0, bottom: 20.0),
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

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsetsDirectional.only(
                    start: boxConstraints.maxWidth * (0.05),
                    bottom: boxConstraints.maxHeight * (0.2),
                    end: boxConstraints.maxWidth * (0.05),
                  ),
                  child: Row(
                    children: [
                      widget.isForBottomMenuBackground
                          ? BorderedProfilePictureContainer(
                              boxConstraints: boxConstraints,
                              imageUrl: context
                                  .read<AuthCubit>()
                                  .getStudentDetails()
                                  .image,
                            )
                          : CustomShowCaseWidget(
                              shapeBorder: const CircleBorder(),
                              globalKey:
                                  _profilePictureNavigationShowCaseGlobalKey,
                              description: "Tap to view profile",
                              child: BorderedProfilePictureContainer(
                                boxConstraints: boxConstraints,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    Routes.studentProfile,
                                    arguments: context
                                        .read<AuthCubit>()
                                        .getStudentDetails(),
                                  );
                                },
                                imageUrl: context
                                    .read<AuthCubit>()
                                    .getStudentDetails()
                                    .image,
                              ),
                            ),
                      SizedBox(
                        width: boxConstraints.maxWidth * (0.05),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context
                                  .read<AuthCubit>()
                                  .getStudentDetails()
                                  .getFullName(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "${UiUtils.getTranslatedLabel(context, classKey)} : ${context.read<AuthCubit>().getStudentDetails().classSectionName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Container(
                                  width: 1.5,
                                  height: 12.0,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Flexible(
                                  child: Text(
                                    "${UiUtils.getTranslatedLabel(context, rollNoKey)} : ${context.read<AuthCubit>().getStudentDetails().rollNumber}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const NotificationIconWidget(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdvertisemntSliders() {
    //
    final sliders = context.read<StudentSubjectsAndSlidersCubit>().getSliders();
    return SlidersContainer(sliders: sliders);
  }

  Widget _buildSlidersSubjectsAndLatestNotcies() {
    return BlocConsumer<StudentSubjectsAndSlidersCubit,
        StudentSubjectsAndSlidersState>(
      listener: (context, state) {
        if (state is StudentSubjectsAndSlidersFetchSuccess) {
          if (state.electiveSubjects.isEmpty &&
              state.doesClassHaveElectiveSubjects) {
            Navigator.of(context).pushNamed(Routes.selectSubjects);
          }
        }
      },
      builder: (context, state) {
        if (state is StudentSubjectsAndSlidersFetchSuccess) {
          return RefreshIndicator(
            displacement: UiUtils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
            ),
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              context
                  .read<StudentSubjectsAndSlidersCubit>()
                  .fetchSubjectsAndSliders();
              context
                  .read<NoticeBoardCubit>()
                  .fetchNoticeBoardDetails(useParentApi: false);
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: UiUtils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
                ),
                bottom: UiUtils.getScrollViewBottomPadding(context),
              ),
              child: Column(
                children: [
                  _buildAdvertisemntSliders(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.025),
                  ),
                  StudentSubjectsContainer(
                    subjects: context
                        .read<StudentSubjectsAndSlidersCubit>()
                        .getSubjects(),
                    subjectsTitleKey: mySubjectsKey,
                    animate: !widget.isForBottomMenuBackground,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.025),
                  ),
                  LatestNoticiesContainer(
                    animate: !widget.isForBottomMenuBackground,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is StudentSubjectsAndSlidersFetchFailure) {
          return Center(
            child: ErrorContainer(
              onTapRetry: () {
                context
                    .read<StudentSubjectsAndSlidersCubit>()
                    .fetchSubjectsAndSliders();
              },
              errorMessageCode: state.errorMessage,
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.only(
            top: UiUtils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
            ),
          ),
          children: [
            ShimmerLoadingContainer(
              child: CustomShimmerContainer(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * (0.075),
                ),
                width: MediaQuery.of(context).size.width,
                borderRadius: 25,
                height: MediaQuery.of(context).size.height *
                    UiUtils.appBarBiggerHeightPercentage,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
            const SubjectsShimmerLoadingContainer(),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
            Column(
              children: List.generate(3, (index) => index)
                  .map((notice) => const AnnouncementShimmerLoadingContainer())
                  .toList(),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _buildSlidersSubjectsAndLatestNotcies(),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _buildTopProfileContainer(context),
        ),
      ],
    );
  }
}
