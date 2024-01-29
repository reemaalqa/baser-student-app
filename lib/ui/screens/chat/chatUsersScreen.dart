import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/chat/chatUsersCubit.dart';
import 'package:eschool/ui/screens/chat/widget/charUserItem.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/loadMoreErrorWidget.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatUsersScreen extends StatefulWidget {
  //Need this flag in order to show the assignments container
  //in background when bottm menu is open

  //If it is just for background showing purpose then it will not reactive or not making any api call
  final bool isForBottomMenuBackground;
  const ChatUsersScreen({super.key, required this.isForBottomMenuBackground});

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_notificationsScrollListener);

  void _notificationsScrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      if (context.read<ChatUsersCubit>().hasMore()) {
        context
            .read<ChatUsersCubit>()
            .fetchMoreChatUsers(isParent: context.read<AuthCubit>().isParent());
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      //don't fetch if it's just background or if it's parent, as parent's are fetched in home page itself
      if (!widget.isForBottomMenuBackground &&
          !context.read<AuthCubit>().isParent()) {
        fetchChatUsers();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_notificationsScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchChatUsers() {
    context
        .read<ChatUsersCubit>()
        .fetchChatUsers(isParent: context.read<AuthCubit>().isParent());
  }

  Widget _buildAppBar(BuildContext context) {
    return ScreenTopBackgroundContainer(
      heightPercentage: UiUtils.appBarSmallerHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (context.read<AuthCubit>().isParent()) const CustomBackButton(),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              UiUtils.getTranslatedLabel(context, chatKey),
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

  Widget _buildShimmerLoader() {
    return ShimmerLoadingContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return SizedBox(
            height: double.maxFinite,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: UiUtils.defaultShimmerLoadingContentCount,
              itemBuilder: (context, index) {
                return _buildOneChatUserShimmerLoader();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOneChatUserShimmerLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: const ShimmerLoadingContainer(
        child: CustomShimmerContainer(
          height: 80,
          borderRadius: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ChatUsersCubit, ChatUsersState>(
            builder: (context, state) {
              if (state is ChatUsersFetchSuccess) {
                return state.chatUsers.isEmpty
                    ? const NoDataContainer(
                        titleKey: noChatUsersKey,
                      )
                    : Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: UiUtils.getScrollViewTopPadding(
                            context: context,
                            keepExtraSpace: false,
                            appBarHeightPercentage:
                                UiUtils.appBarSmallerHeightPercentage,
                          ),
                        ),
                        child: SizedBox(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                ...List.generate(
                                  state.chatUsers.length,
                                  (index) {
                                    final currentChatUser =
                                        state.chatUsers[index];
                                    return Animate(
                                      effects: widget.isForBottomMenuBackground
                                          ? []
                                          : customItemFadeAppearanceEffects(),
                                      child: ChatUserItemWidget(
                                        chatUser: currentChatUser,
                                      ),
                                    );
                                  },
                                ),
                                if (state.moreChatUserFetchProgress)
                                  _buildOneChatUserShimmerLoader(),
                                if (state.moreChatUserFetchError &&
                                    !state.moreChatUserFetchProgress)
                                  LoadMoreErrorWidget(
                                    onTapRetry: () {
                                      context
                                          .read<ChatUsersCubit>()
                                          .fetchMoreChatUsers(
                                              isParent: context
                                                  .read<AuthCubit>()
                                                  .isParent());
                                    },
                                  ),
                                SizedBox(
                                  height: UiUtils.getScrollViewBottomPadding(
                                      context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
              }
              if (state is ChatUsersFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: () {
                      fetchChatUsers();
                    },
                  ),
                );
              }
              return Padding(
                padding: EdgeInsetsDirectional.only(
                  top: UiUtils.getScrollViewTopPadding(
                    context: context,
                    appBarHeightPercentage:
                        UiUtils.appBarSmallerHeightPercentage,
                  ),
                ),
                child: _buildShimmerLoader(),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(context),
          ),
        ],
      ),
    );
  }
}
