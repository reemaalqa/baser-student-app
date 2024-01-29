import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/topicStudyMaterialCubit.dart';
import 'package:eschool/data/models/studyMaterial.dart';
import 'package:eschool/data/models/topic.dart';
import 'package:eschool/data/repositories/subjectRepository.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/filesContainer.dart';

import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/svgButton.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool/ui/widgets/videosContainer.dart';

import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicDetailsScreen extends StatefulWidget {
  final Topic topic;
  final int? childId;
  const TopicDetailsScreen({Key? key, required this.topic, this.childId})
      : super(key: key);

  @override
  State<TopicDetailsScreen> createState() => _TopicDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<TopicStudyMaterialCubit>(
        create: (context) => TopicStudyMaterialCubit(SubjectRepository()),
        child: TopicDetailsScreen(
          topic: arguments['topic'],
          childId: arguments['childId'],
        ),
      ),
    );
  }
}

class _TopicDetailsScreenState extends State<TopicDetailsScreen> {
  late String _selectedTabTitleKey = filesKey;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchStudyMaterials();
    });
  }

  void fetchStudyMaterials() {
    context.read<TopicStudyMaterialCubit>().fetchStudyMaterials(
          childId: widget.childId,
          userParentApi: context.read<AuthCubit>().isParent(),
          lessonId: widget.topic.lessonId,
          topicId: widget.topic.id,
        );
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: UiUtils.screenContentHorizontalPadding,
                  ),
                  child: SvgButton(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    svgIconUrl: UiUtils.getBackButtonPath(context),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: boxConstraints.maxWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: boxConstraints.maxWidth * (0.2),
                  ),
                  child: Text(
                    widget.topic.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: UiUtils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
              AnimatedAlign(
                alignment: _selectedTabTitleKey == filesKey
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                curve: UiUtils.tabBackgroundContainerAnimationCurve,
                duration: UiUtils.tabBackgroundContainerAnimationDuration,
                child:
                    TabBarBackgroundContainer(boxConstraints: boxConstraints),
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerStart,
                isSelected: _selectedTabTitleKey == filesKey,
                onTap: () {
                  setState(() {
                    _selectedTabTitleKey = filesKey;
                  });
                },
                titleKey: filesKey,
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerEnd,
                isSelected: _selectedTabTitleKey == videosKey,
                onTap: () {
                  setState(() {
                    _selectedTabTitleKey = videosKey;
                  });
                },
                titleKey: videosKey,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoadingFileContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return ShimmerLoadingContainer(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.6),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.4),
                    ),
                  ],
                ),
                const Spacer(),
                CustomShimmerContainer(
                  height: boxConstraints.maxWidth * (0.075),
                  width: boxConstraints.maxWidth * (0.075),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoadingVideoContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return ShimmerLoadingContainer(
            child: Row(
              children: [
                CustomShimmerContainer(
                  height: 65,
                  width: boxConstraints.maxWidth * (0.35),
                ),
                SizedBox(
                  width: boxConstraints.maxWidth * (0.05),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.5),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    CustomShimmerContainer(
                      width: boxConstraints.maxWidth * (0.35),
                    ),
                  ],
                )
              ],
            ),
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
          Align(
            alignment: Alignment.topCenter,
            child:
                BlocBuilder<TopicStudyMaterialCubit, TopicStudyMaterialState>(
              builder: (context, state) {
                if (state is TopicStudyMaterialFetchSuccess) {
                  return CustomRefreshIndicator(
                    onRefreshCallback: () {
                      fetchStudyMaterials();
                    },
                    displacment: UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarBiggerHeightPercentage,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: UiUtils.getScrollViewTopPadding(
                          context: context,
                          appBarHeightPercentage:
                              UiUtils.appBarBiggerHeightPercentage,
                        ),
                      ),
                      child: _selectedTabTitleKey == filesKey
                          ? FilesContainer(
                              files: state.studyMaterials
                                  .where(
                                    (element) =>
                                        element.studyMaterialType ==
                                        StudyMaterialType.file,
                                  )
                                  .toList(),
                            )
                          : VideosContainer(
                              studyMaterials: state.studyMaterials
                                  .where(
                                    (element) =>
                                        element.studyMaterialType ==
                                            StudyMaterialType.youtubeVideo ||
                                        element.studyMaterialType ==
                                            StudyMaterialType.uploadedVideoUrl,
                                  )
                                  .toList(),
                            ),
                    ),
                  );
                }
                if (state is TopicStudyMaterialFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      onTapRetry: () {
                        fetchStudyMaterials();
                      },
                      errorMessageCode: state.errorMessage,
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarBiggerHeightPercentage,
                    ),
                  ),
                  child: Column(
                    children: List.generate(
                      UiUtils.defaultShimmerLoadingContentCount,
                      (index) => index,
                    )
                        .map(
                          (e) => _selectedTabTitleKey == filesKey
                              ? _buildShimmerLoadingFileContainer()
                              : _buildShimmerLoadingVideoContainer(),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
          Align(alignment: Alignment.topCenter, child: _buildAppBar()),
        ],
      ),
    );
  }
}
