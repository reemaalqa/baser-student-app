import 'dart:math';

import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/chat/chatMessagesCubit.dart';
import 'package:eschool/cubits/chat/chatUsersCubit.dart';
import 'package:eschool/data/models/chatMessage.dart';
import 'package:eschool/data/models/chatUser.dart';
import 'package:eschool/data/repositories/chatRepository.dart';
import 'package:eschool/ui/screens/chat/widget/attachmentDialog.dart';
import 'package:eschool/ui/screens/chat/widget/messageSendingWidget.dart';
import 'package:eschool/ui/screens/chat/widget/singleMessageItem.dart';
import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/notificationUtils/chatNotificationsUtils.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';

class ChatMessagesScreen extends StatefulWidget {
  final ChatUser chatUser;
  const ChatMessagesScreen({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();

  static route(RouteSettings routeSettings) {
    final ChatUser user =
        (routeSettings.arguments as Map<String, dynamic>?)?["chatUser"] ??
            ChatUser.fromJsonAPI({});
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<ChatMessagesCubit>(
        create: (context) => ChatMessagesCubit(
            ChatRepository(), context.read<AuthCubit>().isParent()),
        child: ChatMessagesScreen(chatUser: user),
      ),
    );
  }
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final ValueNotifier<bool> _isAttachmentDialogOpen = ValueNotifier(false);
  final _chatMessageSendTextController = TextEditingController();

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_notificationsScrollListener);

  //to check sent or received messages
  int currentUserId = 0;

  void _notificationsScrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      if (context.read<ChatMessagesCubit>().hasMore()) {
        context.read<ChatMessagesCubit>().fetchMoreChatMessages(
            chatUserId: widget.chatUser.userId.toString());
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchChatMessages();
      currentUserId = context.read<AuthCubit>().isParent()
          ? context.read<AuthCubit>().getParentDetails().userId
          : context.read<AuthCubit>().getStudentDetails().userId;
    });
    //registring user id with which the current user is talking with
    ChatNotificationsUtils.currentChattingUserId = widget.chatUser.userId;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_notificationsScrollListener);
    _scrollController.dispose();
    _isAttachmentDialogOpen.dispose();
    _chatMessageSendTextController.dispose();
    //removing currently talking user's id
    ChatNotificationsUtils.currentChattingUserId = null;
    //clearing current route when going back to make the onTap of notification routing properly work
    Routes.currentRoute = "";
    super.dispose();
  }

  void fetchChatMessages() {
    context.read<ChatMessagesCubit>().fetchChatMessages(
          chatUserId: widget.chatUser.userId.toString(),
          chatUsersCubitArgument: context.read<ChatUsersCubit>(),
        );
  }

  _navigateToProfilePage() {
    Navigator.pushNamed(context, Routes.chatUserProfile, arguments: {
      "chatUser": widget.chatUser,
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return ScreenTopBackgroundContainer(
      heightPercentage: UiUtils.appBarSmallerHeightPercentage,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomBackButton(),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _navigateToProfilePage();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.chatUser.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: UiUtils.screenTitleFontSize,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.chatUser.isClassTeacher
                        ? UiUtils.getTranslatedLabel(context, classTeacherKey)
                        : "${UiUtils.getTranslatedLabel(context, subjectTeacherKey)} | ${widget.chatUser.subjects}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _navigateToProfilePage();
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              width: 50,
              height: 50,
              margin: const EdgeInsetsDirectional.only(end: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: CustomUserProfileImageWidget(
                profileUrl: widget.chatUser.profileUrl,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return SizedBox(
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                UiUtils.defaultChatShimmerLoaders,
                (index) => _buildOneChatShimmerLoader(boxConstraints),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOneChatShimmerLoader(BoxConstraints boxConstraints) {
    final bool isStart = Random().nextBool();
    return Align(
      alignment: isStart
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: ShimmerLoadingContainer(
          child: CustomShimmerContainer(
            height: 30,
            width: boxConstraints.maxWidth * 0.8,
            customBorderRadius: BorderRadiusDirectional.only(
              topStart: isStart ? Radius.zero : const Radius.circular(12),
              topEnd: isStart ? const Radius.circular(12) : Radius.zero,
              bottomEnd: const Radius.circular(12),
              bottomStart: const Radius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateLabel({required DateTime date}) {
    return Text(
      date.isToday()
          ? UiUtils.getTranslatedLabel(context, todayKey)
          : date.isYesterday()
              ? UiUtils.getTranslatedLabel(context, yesterdayKey)
              : date.isCurrentYear()
                  ? DateFormat("dd MMMM").format(date)
                  : DateFormat("dd MMM yyyy").format(date),
      style: TextStyle(
        color: secondaryColor.withOpacity(0.6),
        fontSize: 12,
      ),
    );
  }

  Widget _loadingMoreChatsWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: secondaryColor.withOpacity(0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CustomCircularProgressIndicator(
              indicatorColor: primaryColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Text(
              UiUtils.getTranslatedLabel(context, loadingMoreChatsKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingMoreErrorWidget({required Function() onTapRetry}) {
    return GestureDetector(
      onTap: onTapRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: secondaryColor.withOpacity(0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.refresh,
              size: 16,
              color: primaryColor,
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: Text(
                UiUtils.getTranslatedLabel(
                    context, errorLoadingMoreChatsRertyKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_isAttachmentDialogOpen.value) {
          _isAttachmentDialogOpen.value = false;
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: 10.0,
                top: UiUtils.getScrollViewTopPadding(
                  context: context,
                  keepExtraSpace: false,
                  appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
                ),
                start: 15,
                end: 15,
              ),
              child: BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
                builder: (context, state) {
                  if (state is ChatMessagesFetchSuccess) {
                    return Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: state.chatMessages.isEmpty
                                  ? KeyboardVisibilityBuilder(
                                      //if the keyboard is visible, hide the no data container
                                      builder: (p0, isKeyboardVisible) =>
                                          isKeyboardVisible
                                              ? const SizedBox.shrink()
                                              : const NoDataContainer(
                                                  titleKey: noChatsWithUserKey,
                                                ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      reverse: true,
                                      padding: EdgeInsets.only(
                                        top: UiUtils.getScrollViewTopPadding(
                                          context: context,
                                          appBarHeightPercentage: UiUtils
                                              .appBarSmallerHeightPercentage,
                                        ),
                                      ),
                                      itemCount: state.chatMessages.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            //if it's 1st item - reverse scroll so last then show date label
                                            //or if an item's date is not the same as next item, show date label
                                            if (index ==
                                                    (state.chatMessages.length -
                                                        1) ||
                                                (!(state.chatMessages[index]
                                                    .sendOrReceiveDateTime
                                                    .isSameAs(state
                                                        .chatMessages[index ==
                                                                (state.chatMessages
                                                                        .length -
                                                                    1)
                                                            ? (state.chatMessages
                                                                    .length -
                                                                1)
                                                            : index + 1]
                                                        .sendOrReceiveDateTime))))
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: _buildDateLabel(
                                                      date: state
                                                          .chatMessages[index]
                                                          .sendOrReceiveDateTime),
                                                ),
                                              ),
                                            SingleChatMessageItem(
                                              key: ValueKey(
                                                  state.chatMessages[index].id),
                                              currentUserId: currentUserId,
                                              //if it's 1st item, show time by default, if sender id and time is not same show time, otherwise don't show time
                                              showTime: index ==
                                                      (state.chatMessages
                                                              .length -
                                                          1)
                                                  ? true
                                                  : !(UiUtils
                                                              .formatTimeWithDateTime(
                                                            state
                                                                .chatMessages[
                                                                    index]
                                                                .sendOrReceiveDateTime,
                                                            is24: false,
                                                          ) ==
                                                          UiUtils
                                                              .formatTimeWithDateTime(
                                                            state
                                                                .chatMessages[
                                                                    index + 1]
                                                                .sendOrReceiveDateTime,
                                                            is24: false,
                                                          ) &&
                                                      state.chatMessages[index]
                                                              .senderId ==
                                                          state
                                                              .chatMessages[
                                                                  index + 1]
                                                              .senderId),
                                              chatMessage:
                                                  state.chatMessages[index],
                                              isLoading: state.loadingIds
                                                  .contains(state
                                                      .chatMessages[index].id),
                                              isError: state.errorIds.contains(
                                                  state.chatMessages[index].id),
                                              onRetry:
                                                  (ChatMessage chatMessage) {
                                                context
                                                    .read<ChatMessagesCubit>()
                                                    .sendChatMessage(
                                                        chatMessage:
                                                            chatMessage,
                                                        receiverId: widget
                                                            .chatUser.userId,
                                                        chatUserCubit:
                                                            context.read<
                                                                ChatUsersCubit>(),
                                                        chattingWith:
                                                            widget.chatUser,
                                                        isRetry: true);
                                              },
                                            ),
                                            if (index ==
                                                0) //padding to latest message
                                              const SizedBox(
                                                height: 10,
                                              ),
                                          ],
                                        );
                                      }),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ValueListenableBuilder<bool>(
                                  valueListenable: _isAttachmentDialogOpen,
                                  builder: (context, value, child) => value
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 15),
                                          child: Animate(
                                            effects:
                                                customItemFadeAppearanceEffects(),
                                            child: AttachmentDialogWidget(
                                              onCancel: () {
                                                _isAttachmentDialogOpen.value =
                                                    false;
                                              },
                                              onItemSelected:
                                                  (selectedFilePaths, isImage) {
                                                if (UiUtils
                                                    .isDemoVersionEnable()) {
                                                  UiUtils
                                                      .showFeatureDisableInDemoVersion(
                                                          context);
                                                  return;
                                                }
                                                _isAttachmentDialogOpen.value =
                                                    false;
                                                context
                                                    .read<ChatMessagesCubit>()
                                                    .sendChatMessage(
                                                      chatMessage: ChatMessage(
                                                          messageType: isImage
                                                              ? ChatMessageType
                                                                  .imageMessage
                                                              : ChatMessageType
                                                                  .fileMessage,
                                                          message: "",
                                                          files:
                                                              selectedFilePaths,
                                                          isLocallyStored: true,
                                                          id: DateTime.now()
                                                              .microsecondsSinceEpoch,
                                                          sendOrReceiveDateTime:
                                                              DateTime.now(),
                                                          senderId:
                                                              currentUserId),
                                                      receiverId: widget
                                                          .chatUser.userId,
                                                      chatUserCubit:
                                                          context.read<
                                                              ChatUsersCubit>(),
                                                      chattingWith:
                                                          widget.chatUser,
                                                    );
                                              },
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                ChatMessageSendingWidget(
                                  backgroundColor:
                                      primaryColor.withOpacity(0.25),
                                  onMessageSend: () {
                                    if (_chatMessageSendTextController.text
                                        .trim()
                                        .isNotEmpty) {
                                      if (UiUtils.isDemoVersionEnable()) {
                                        UiUtils.showFeatureDisableInDemoVersion(
                                            context);
                                        return;
                                      }
                                      context
                                          .read<ChatMessagesCubit>()
                                          .sendChatMessage(
                                            chatMessage: ChatMessage(
                                              messageType:
                                                  ChatMessageType.textMessage,
                                              files: [],
                                              message:
                                                  _chatMessageSendTextController
                                                      .text,
                                              isLocallyStored: true,
                                              id: DateTime.now()
                                                  .microsecondsSinceEpoch,
                                              sendOrReceiveDateTime:
                                                  DateTime.now(),
                                              senderId: currentUserId,
                                            ),
                                            receiverId: widget.chatUser.userId,
                                            chatUserCubit:
                                                context.read<ChatUsersCubit>(),
                                            chattingWith: widget.chatUser,
                                          );
                                      _chatMessageSendTextController.clear();
                                    }
                                  },
                                  onAttachmentTap: () {
                                    _isAttachmentDialogOpen.value =
                                        !_isAttachmentDialogOpen.value;
                                    //if attachment adding is being shown, hide the keyboard
                                    if (_isAttachmentDialogOpen.value) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    }
                                  },
                                  textController:
                                      _chatMessageSendTextController,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 25,
                            ),
                            child: state.moreChatMessageFetchProgress
                                ? _loadingMoreChatsWidget()
                                : state.moreChatMessageFetchError
                                    ? _loadingMoreErrorWidget(onTapRetry: () {
                                        context
                                            .read<ChatMessagesCubit>()
                                            .fetchMoreChatMessages(
                                                chatUserId: widget
                                                    .chatUser.userId
                                                    .toString());
                                      })
                                    : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    );
                  }
                  if (state is ChatMessagesFetchFailure) {
                    return Center(
                      child: ErrorContainer(
                        errorMessageCode: state.errorMessage,
                        onTapRetry: () {
                          fetchChatMessages();
                        },
                      ),
                    );
                  }
                  return _buildShimmerLoader();
                },
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _buildAppBar(context),
            ),
          ],
        ),
      ),
    );
  }
}
