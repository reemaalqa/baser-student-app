import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/noticeBoardCubit.dart';
import 'package:eschool/data/models/announcement.dart';
import 'package:eschool/ui/widgets/announcementDetailsContainer.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoticeBoardContainer extends StatefulWidget {
  final bool showBackButton;
  const NoticeBoardContainer({Key? key, required this.showBackButton})
      : super(key: key);

  @override
  State<NoticeBoardContainer> createState() => _NoticeBoardContainerState();
}

class _NoticeBoardContainerState extends State<NoticeBoardContainer> {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_noticeBoardScrollListener);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<NoticeBoardCubit>().fetchNoticeBoardDetails(
            useParentApi: context.read<AuthCubit>().isParent(),
          );
    });
  }

  void _noticeBoardScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<NoticeBoardCubit>().hasMore()) {
        context.read<NoticeBoardCubit>().fetchMoreAnnouncements(
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
  void dispose() {
    _scrollController.removeListener(_noticeBoardScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      padding: EdgeInsets.zero,
      heightPercentage: UiUtils.appBarSmallerHeightPercentage,
      child: Stack(
        children: [
          widget.showBackButton
              ? const CustomBackButton(
                  alignmentDirectional: AlignmentDirectional.centerStart,
                )
              : const SizedBox(),
          Align(
            child: Text(
              UiUtils.getTranslatedLabel(context, noticeBoardKey),
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: UiUtils.screenTitleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeContainer({
    required Announcement noticeBoardAnnouncement,
    required int index,
    required int totalAnnouncements,
    required bool hasMoreAnnouncements,
    required bool hasMoreAnnouncementsInProgress,
    required bool fetchMoreAnnouncementsFailure,
  }) {
    return Column(
      children: [
        Animate(
            effects: listItemAppearanceEffects(itemIndex: index),
            child: AnnouncementDetailsContainer(
                announcement: noticeBoardAnnouncement)),
        //show announcement loading container after last announcement container
        if (index == (totalAnnouncements - 1) &&
            hasMoreAnnouncements &&
            hasMoreAnnouncementsInProgress)
          const AnnouncementShimmerLoadingContainer(),

        if (index == (totalAnnouncements - 1) &&
            hasMoreAnnouncements &&
            fetchMoreAnnouncementsFailure)
          Center(
            child: CupertinoButton(
              child: Text(UiUtils.getTranslatedLabel(context, retryKey)),
              onPressed: () {
                context.read<NoticeBoardCubit>().fetchMoreAnnouncements(
                      useParentApi: context.read<AuthCubit>().isParent(),
                    );
              },
            ),
          )
      ],
    );
  }

  Widget _buildNoticeBoardContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomRefreshIndicator(
        onRefreshCallback: () {
          if (context.read<NoticeBoardCubit>().state
              is NoticeBoardFetchSuccess) {
            context.read<NoticeBoardCubit>().fetchNoticeBoardDetails(
                  useParentApi: context.read<AuthCubit>().isParent(),
                );
          }
        },
        displacment: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
        ),
        child: SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: widget.showBackButton
                  ? 0
                  : UiUtils.getScrollViewBottomPadding(context),
              top: UiUtils.getScrollViewTopPadding(
                context: context,
                appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
              ),
            ),
            child: BlocBuilder<NoticeBoardCubit, NoticeBoardState>(
              builder: (context, state) {
                if (state is NoticeBoardFetchSuccess) {
                  return state.announcements.isEmpty
                      ? const NoDataContainer(titleKey: noticeBoardEmptyKey)
                      : Column(
                          children: List.generate(
                            state.announcements.length,
                            (index) => index,
                          )
                              .map(
                                (index) => _buildNoticeContainer(
                                  noticeBoardAnnouncement:
                                      state.announcements[index],
                                  index: index,
                                  totalAnnouncements:
                                      state.announcements.length,
                                  hasMoreAnnouncements: context
                                      .read<NoticeBoardCubit>()
                                      .hasMore(),
                                  hasMoreAnnouncementsInProgress:
                                      state.fetchMoreAnnouncementsInProgress,
                                  fetchMoreAnnouncementsFailure:
                                      state.moreAnnouncementsFetchError,
                                ),
                              )
                              .toList(),
                        );
                }
                if (state is NoticeBoardFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: () {
                        context
                            .read<NoticeBoardCubit>()
                            .fetchNoticeBoardDetails(
                              useParentApi:
                                  context.read<AuthCubit>().isParent(),
                            );
                      },
                    ),
                  );
                }

                return Column(
                  children: List.generate(
                    UiUtils.defaultShimmerLoadingContentCount,
                    (index) => index,
                  )
                      .map((e) => const AnnouncementShimmerLoadingContainer())
                      .toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildNoticeBoardContainer(),
        Align(
          alignment: Alignment.topCenter,
          child: _buildAppBar(),
        ),
      ],
    );
  }
}
