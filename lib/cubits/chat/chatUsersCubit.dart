import 'dart:async';

import 'package:eschool/data/models/chatNotificationData.dart';
import 'package:eschool/data/models/chatUser.dart';
import 'package:eschool/data/repositories/chatRepository.dart';
import 'package:eschool/utils/notificationUtils/chatNotificationsUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/constants.dart';

/*
This cubit will handle child's chat users, 
where a chat user can be a single person(teacher) or group(not yet added) in which a child can send message
*/

abstract class ChatUsersState {}

class ChatUsersInitial extends ChatUsersState {}

class ChatUsersFetchInProgress extends ChatUsersState {}

class ChatUsersFetchFailure extends ChatUsersState {
  final String errorMessage;

  ChatUsersFetchFailure({required this.errorMessage});
}

class ChatUsersFetchSuccess extends ChatUsersState {
  final List<ChatUser> chatUsers;
  final int totalOffset;
  final bool moreChatUserFetchError;
  final bool moreChatUserFetchProgress;
  final int totalUnreadUsers;

  ChatUsersFetchSuccess({
    required this.chatUsers,
    required this.totalOffset,
    required this.moreChatUserFetchError,
    required this.moreChatUserFetchProgress,
    required this.totalUnreadUsers,
  });

  ChatUsersFetchSuccess copyWith({
    List<ChatUser>? newChatUsers,
    int? newTotalOffset,
    bool? newFetchMorechatUsersInProgress,
    bool? newFetchMorechatUsersError,
    int? newTotalUnreadUsers,
  }) {
    return ChatUsersFetchSuccess(
        chatUsers: newChatUsers ?? chatUsers,
        totalOffset: newTotalOffset ?? totalOffset,
        moreChatUserFetchProgress:
            newFetchMorechatUsersInProgress ?? moreChatUserFetchProgress,
        moreChatUserFetchError:
            newFetchMorechatUsersError ?? moreChatUserFetchError,
        totalUnreadUsers: newTotalUnreadUsers ?? totalUnreadUsers);
  }
}

class ChatUsersCubit extends Cubit<ChatUsersState> {
  final ChatRepository _chatRepository;

  ChatUsersCubit(this._chatRepository) : super(ChatUsersInitial());
  StreamSubscription<ChatNotificationData>? _streamSubscription;

  registerNotificationListener() {
    _streamSubscription = ChatNotificationsUtils
        .notificationStreamController.stream
        .listen((event) {
      makeUserFirstOrAddFirst(event.fromUser);
    });
  }

  makeUserFirstOrAddFirst(ChatUser chatUser) {
    if (state is ChatUsersFetchSuccess) {
      final stateAs = state as ChatUsersFetchSuccess;
      int? index;
      try {
        index = stateAs.chatUsers
            .indexWhere((element) => element.id == chatUser.id);
      } catch (_) {}
      //if already has that user, replace it and make it first as the latest message is from them
      if (index != null && index >= 0) {
        var tempList = stateAs.chatUsers;
        //if we have 0 count, but a new message came, increase count by 1
        bool increaseUserCount = tempList[index].unreadCount == 0;
        tempList.removeAt(index);
        tempList.insert(0, chatUser);
        emit(stateAs.copyWith(
            newChatUsers: tempList,
            newTotalUnreadUsers: increaseUserCount &&
                    chatUser.userId !=
                        ChatNotificationsUtils.currentChattingUserId
                ? stateAs.totalUnreadUsers + 1
                : null));
      } else {
        //if not already there, add it first and increase the total unread notification count
        var tempList = stateAs.chatUsers;
        tempList.insert(0, chatUser);
        emit(stateAs.copyWith(
            newChatUsers: tempList,
            newTotalUnreadUsers: chatUser.unreadCount == 1 &&
                    chatUser.userId !=
                        ChatNotificationsUtils.currentChattingUserId
                ? stateAs.totalUnreadUsers + 1
                : null)); //if it's more then 1, it's already counted in the API, also if they're talking don't increase it
      }
    }
  }

  makeUserUnreadCountZero(
      {required int chatUserId, required bool changeCountForTotalUnreadUsers}) {
    if (state is ChatUsersFetchSuccess) {
      List<ChatUser> oldChatUsers = (state as ChatUsersFetchSuccess).chatUsers;
      bool didWeChangeIt =
          false; //if we remove count, decrease the unread count as well
      for (int i = 0; i < oldChatUsers.length; i++) {
        if (oldChatUsers[i].userId == chatUserId) {
          if (oldChatUsers[i].unreadCount != 0) {
            oldChatUsers.insert(i, oldChatUsers[i].copyWith(unreadCount: 0));
            oldChatUsers.removeAt(i + 1);
            didWeChangeIt = true;
          }
        }
      }
      if (didWeChangeIt) {
        emit((state as ChatUsersFetchSuccess).copyWith(
            newChatUsers: oldChatUsers,
            newTotalUnreadUsers: changeCountForTotalUnreadUsers &&
                    (state as ChatUsersFetchSuccess).totalUnreadUsers != 0
                ? (state as ChatUsersFetchSuccess).totalUnreadUsers - 1
                : null));
      }
    }
  }

  bool isLoading() {
    if (state is ChatUsersFetchInProgress) {
      return true;
    }
    return false;
  }

  void fetchChatUsers({required bool isParent}) async {
    emit(ChatUsersFetchInProgress());
    try {
      Map<String, dynamic> data = await _chatRepository.fetchChatUsers(
        offset: 0,
        isParent: isParent,
      );

      //registration of notification listener if the chat messages were fetched successfully
      registerNotificationListener();
      return emit(
        ChatUsersFetchSuccess(
          chatUsers: data['chatUsers'],
          totalOffset: data['totalItems'],
          totalUnreadUsers: data['totalUnreadUsers'],
          moreChatUserFetchError: false,
          moreChatUserFetchProgress: false,
        ),
      );
    } catch (e) {
      emit(
        ChatUsersFetchFailure(
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> fetchMoreChatUsers({required bool isParent}) async {
    if (state is ChatUsersFetchSuccess) {
      final stateAs = state as ChatUsersFetchSuccess;
      if (stateAs.moreChatUserFetchProgress) {
        return;
      }
      try {
        emit(stateAs.copyWith(newFetchMorechatUsersInProgress: true));

        final Map moreTransactionResult = await _chatRepository.fetchChatUsers(
          offset: stateAs.chatUsers.length,
          isParent: isParent,
        );

        List<ChatUser> chatUsers = stateAs.chatUsers;

        chatUsers.addAll(moreTransactionResult['chatUsers']);

        emit(
          ChatUsersFetchSuccess(
            chatUsers: chatUsers,
            totalOffset: moreTransactionResult['totalItems'],
            totalUnreadUsers: moreTransactionResult['totalUnreadUsers'],
            moreChatUserFetchError: false,
            moreChatUserFetchProgress: false,
          ),
        );
      } catch (e) {
        logger.e(e);
        emit(
          (state as ChatUsersFetchSuccess).copyWith(
            newFetchMorechatUsersInProgress: false,
            newFetchMorechatUsersError: true,
          ),
        );
      }
    }
  }

  bool hasMore() {
    if (state is ChatUsersFetchSuccess) {
      return (state as ChatUsersFetchSuccess).chatUsers.length <
          (state as ChatUsersFetchSuccess).totalOffset;
    }
    return false;
  }

  disposeNotificationListener() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
    }
  }

  @override
  Future<void> close() async {
    disposeNotificationListener();
    super.close();
  }
}
