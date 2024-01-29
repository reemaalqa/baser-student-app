import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/noticeBoardCubit.dart';
import 'package:eschool/cubits/slidersCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/settingsRepository.dart';
import 'package:eschool/data/repositories/systemInfoRepository.dart';
import 'package:eschool/ui/screens/home/homeScreen.dart';
import 'package:eschool/ui/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/latestNoticesContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/slidersContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/notificationUtils/generalNotificationUtility.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({Key? key}) : super(key: key);

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<SlidersCubit>(
        create: (context) => SlidersCubit(SystemRepository()),
        child: const ParentHomeScreen(),
      ),
    );
  }
}

class _ParentHomeScreenState extends State<ParentHomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      context.read<SlidersCubit>().fetchSliders();
      NotificationUtility.setUpNotificationService(context);
      context
          .read<NoticeBoardCubit>()
          .fetchNoticeBoardDetails(useParentApi: true);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    //Refereshing the shared preferences to get the latest notification count, it there were any notifications in the background
    if (state == AppLifecycleState.resumed) {
      notificationCountValueNotifier.value =
          await SettingsRepository().getNotificationCount();
    }
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: ScreenTopBackgroundContainer(
        padding: EdgeInsets.zero,
        heightPercentage: UiUtils.appBarMediumtHeightPercentage,
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Stack(
              children: [
                //Bordered circles
                PositionedDirectional(
                  top: MediaQuery.of(context).size.width * (-0.2),
                  start: MediaQuery.of(context).size.width * (-0.225),
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(
                        end: 20.0, bottom: 20.0),
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
                      end: boxConstraints.maxWidth * (0.02),
                      start: boxConstraints.maxWidth * (0.075),
                      bottom: boxConstraints.maxHeight * (0.21),
                    ),
                    child: Row(
                      children: [
                        BorderedProfilePictureContainer(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(Routes.parentProfile);
                          },
                          boxConstraints: boxConstraints,
                          imageUrl: context
                              .read<AuthCubit>()
                              .getParentDetails()
                              .image,
                        ),
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.04),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context
                                        .read<AuthCubit>()
                                        .getParentDetails()
                                        .getFullName(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  ),
                                  Text(
                                    context
                                        .read<AuthCubit>()
                                        .getParentDetails()
                                        .email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          iconSize: 20,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          onPressed: () {
                            Navigator.of(context).pushNamed(Routes.settings);
                            // context.read<AuthCubit>().signOut();
                            // Navigator.of(context)
                            //     .pushReplacementNamed(Routes.auth);
                          },
                          icon: const Icon(Icons.settings),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChildDetailsContainer({
    required double width,
    required Student student,
  }) {
    return Animate(
      effects: customItemZoomAppearanceEffects(),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.studentDetails, arguments: student);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          width: width,
          height: 150,
          child: LayoutBuilder(
            builder: (context, boxConstraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: boxConstraints.maxHeight * (0.125),
                          ),
                          BorderedProfilePictureContainer(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Routes.studentDetails,
                                arguments: student,
                              );
                            },
                            heightAndWidthPercentage: 0.3,
                            boxConstraints: boxConstraints,
                            imageUrl: student.image,
                          ),
                          SizedBox(
                            height: boxConstraints.maxHeight * (0.075),
                          ),
                          Text(
                            student.getFullName(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                            ),
                          ),
                          SizedBox(
                            height: boxConstraints.maxHeight * (0.025),
                          ),
                          Text(
                            "${UiUtils.getTranslatedLabel(context, classKey)} - ${student.classSectionName}",
                            style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: -15,
                    start: (boxConstraints.maxWidth * 0.5) - 15,
                    child: Container(
                      alignment: Alignment.center,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                            offset: const Offset(0, 5),
                            blurRadius: 20,
                          )
                        ],
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChildDetailsShimmerLoadingContainer({
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 150,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.125),
                    ),
                    ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        height: boxConstraints.maxHeight * (0.3),
                        width: boxConstraints.maxHeight * (0.3),
                        borderRadius: boxConstraints.maxHeight * (0.15),
                      ),
                    ),
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.075),
                    ),
                    ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        width: boxConstraints.maxWidth * (0.6),
                        height:
                            UiUtils.shimmerLoadingContainerDefaultHeight - 1,
                      ),
                    ),
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.05),
                    ),
                    ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        width: boxConstraints.maxWidth * (0.4),
                        height:
                            UiUtils.shimmerLoadingContainerDefaultHeight - 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChildrenContainer() {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * (0.075),
        right: MediaQuery.of(context).size.width * (0.075),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              UiUtils.getTranslatedLabel(context, myChildrenKey),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          LayoutBuilder(
            builder: (context, boxConstraints) {
              return Wrap(
                spacing: boxConstraints.maxWidth * (0.1),
                runSpacing: 32.5,
                children: context
                    .read<AuthCubit>()
                    .getParentDetails()
                    .children
                    .map(
                      (student) => _buildChildDetailsContainer(
                        width: boxConstraints.maxWidth * (0.45),
                        student: student,
                      ),
                    )
                    .toList(),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildChildrenShimmerLoadingContainer() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Wrap(
          spacing: boxConstraints.maxWidth * (0.1),
          runSpacing: 32.5,
          children: context
              .read<AuthCubit>()
              .getParentDetails()
              .children
              .map(
                (student) => _buildChildDetailsShimmerLoadingContainer(
                  width: boxConstraints.maxWidth * (0.45),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.read<AppConfigurationCubit>().appUnderMaintenance()
          ? const AppUnderMaintenanceContainer()
          : Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: UiUtils.getScrollViewTopPadding(
                        context: context,
                        appBarHeightPercentage:
                            UiUtils.appBarMediumtHeightPercentage,
                      ),
                    ),
                    child: BlocBuilder<SlidersCubit, SlidersState>(
                      builder: (context, state) {
                        if (state is SlidersFetchSuccess) {
                          return Column(
                            children: [
                              SlidersContainer(sliders: state.sliders),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    (0.025),
                              ),
                              _buildChildrenContainer(),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * (0.05),
                              ),
                              const LatestNoticiesContainer()
                            ],
                          );
                        }
                        if (state is SlidersFetchFailure) {
                          return Center(
                            child: ErrorContainer(
                              errorMessageCode: state.errorMessage,
                              onTapRetry: () {
                                context.read<SlidersCubit>().fetchSliders();
                              },
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoadingContainer(
                              child: CustomShimmerContainer(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          (0.075),
                                ),
                                width: MediaQuery.of(context).size.width,
                                borderRadius: 25,
                                height: MediaQuery.of(context).size.height *
                                    UiUtils.appBarBiggerHeightPercentage,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * (0.075),
                            ),
                            _buildChildrenShimmerLoadingContainer(),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * (0.025),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * (0.075),
                              ),
                              child: Column(
                                children: List.generate(3, (index) => index)
                                    .map(
                                      (e) =>
                                          const AnnouncementShimmerLoadingContainer(),
                                    )
                                    .toList(),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                _buildAppBar(),
              ],
            ),
    );
  }
}
