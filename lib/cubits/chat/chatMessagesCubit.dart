import 'dart:async';

import 'package:eschool/cubits/chat/chatUsersCubit.dart';
import 'package:eschool/data/models/chatMessage.dart';
import 'package:eschool/data/models/chatNotificationData.dart';
import 'package:eschool/data/models/chatUser.dart';
import 'package:eschool/data/repositories/chatRepository.dart';
import 'package:eschool/utils/notificationUtils/chatNotificationsUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/*
This cubit will handle chat messages, 
it'll fetch messages either from server or add from notifications
*/

abstract class ChatMessagesState {}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesFetchInProgress extends ChatMessagesState {}

class ChatMessagesFetchFailure extends ChatMessagesState {
  final String errorMessage;

  ChatMessagesFetchFailure({required this.errorMessage});
}

class ChatMessagesFetchSuccess extends ChatMessagesState {
  final List<ChatMessage> chatMessages;
  final int totalOffset;
  final bool moreChatMessageFetchError;
  final bool moreChatMessageFetchProgress;
  final List<int> loadingIds;
  final List<int> errorIds;

  ChatMessagesFetchSuccess({
    required this.chatMessages,
    required this.totalOffset,
    required this.moreChatMessageFetchError,
    required this.moreChatMessageFetchProgress,
    required this.loadingIds,
    required this.errorIds,
  });

  ChatMessagesFetchSuccess copyWith({
    List<ChatMessage>? newChatMessages,
    int? newTotalOffset,
    bool? newFetchMoreTransactionsInProgress,
    bool? newFetchMoreTransactionsError,
    List<int>? loadingIds,
    List<int>? errorIds,
  }) {
    return ChatMessagesFetchSuccess(
      chatMessages: newChatMessages ?? chatMessages,
      totalOffset: newTotalOffset ?? totalOffset,
      moreChatMessageFetchProgress:
          newFetchMoreTransactionsInProgress ?? moreChatMessageFetchProgress,
      moreChatMessageFetchError:
          newFetchMoreTransactionsError ?? moreChatMessageFetchError,
      loadingIds: loadingIds ?? this.loadingIds,
      errorIds: errorIds ?? this.errorIds,
    );
  }
}

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepository _chatRepository;
  final bool _isParent;
  String?
      chatUserId; //to store when chatting starts and to be used to mark as read at the end
  ChatUsersCubit? chatUserCubit; //to remove the count for this user

  ChatMessagesCubit(this._chatRepository, this._isParent)
      : super(ChatMessagesInitial());

  StreamSubscription<ChatNotificationData>? _streamSubscription;

  registerNotificationListener() {
    _streamSubscription = ChatNotificationsUtils
        .notificationStreamController.stream
        .listen((event) {
      if (state is ChatMessagesFetchSuccess) {
        final stateAs = state as ChatMessagesFetchSuccess;
        if (ChatNotificationsUtils.currentChattingUserId ==
            event.fromUser.userId) {
          if (!(stateAs.chatMessages
              .any((element) => element.id == event.receivedMessage.id))) {
            var tempList = stateAs.chatMessages;
            tempList.insert(0, event.receivedMessage);
            emit(stateAs.copyWith(newChatMessages: tempList));
          }
        }
      }
    });
  }

  markAsReadAll({bool changeCountForTotalUnreadUsers = true}) {
    if (chatUserId != null) {
      _chatRepository.readAllMessages(userId: chatUserId!, isParent: _isParent);

      //also remove count from our side
      int? userId = int.tryParse(chatUserId ?? "");
      if (userId != null && chatUserCubit != null) {
        chatUserCubit!.makeUserUnreadCountZero(
            chatUserId: userId,
            changeCountForTotalUnreadUsers: changeCountForTotalUnreadUsers);
      }
    }
  }

  bool isLoading() {
    if (state is ChatMessagesFetchInProgress) {
      return true;
    }
    return false;
  }

  void fetchChatMessages({
    required String chatUserId,
    required ChatUsersCubit chatUsersCubitArgument,
  }) async {
    emit(ChatMessagesFetchInProgress());
    try {
      Map<String, dynamic> data = await _chatRepository.fetchChatMessages(
          offset: 0, chatUserId: chatUserId, isParent: _isParent);

      //registration of notification listener if the chat messages were fetched successfully
      registerNotificationListener();
      //storing and calling unread when first time messages are fetched
      this.chatUserId = chatUserId;
      chatUserCubit = chatUsersCubitArgument;
      markAsReadAll();
      return emit(
        ChatMessagesFetchSuccess(
          chatMessages: data['chatMessages'],
          totalOffset: data['totalItems'],
          moreChatMessageFetchError: false,
          moreChatMessageFetchProgress: false,
          loadingIds: [],
          errorIds: [],
        ),
      );
    } catch (e) {
      emit(
        ChatMessagesFetchFailure(
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> fetchMoreChatMessages({
    required String chatUserId,
  }) async {
    if (state is ChatMessagesFetchSuccess) {
      final stateAs = state as ChatMessagesFetchSuccess;
      if (stateAs.moreChatMessageFetchProgress) {
        return;
      }
      try {
        emit(stateAs.copyWith(newFetchMoreTransactionsInProgress: true));

        final Map moreTransactionResult =
            await _chatRepository.fetchChatMessages(
          offset: stateAs.chatMessages
              .where((element) => !element.isLocallyStored)
              .length,
          chatUserId: chatUserId,
          isParent: _isParent,
        );

        List<ChatMessage> transactions = stateAs.chatMessages;

        transactions.addAll(moreTransactionResult['chatMessages']);

        emit(
          ChatMessagesFetchSuccess(
            chatMessages: transactions,
            totalOffset: moreTransactionResult['totalItems'],
            moreChatMessageFetchError: false,
            moreChatMessageFetchProgress: false,
            loadingIds: stateAs.loadingIds,
            errorIds: stateAs.errorIds,
          ),
        );
      } catch (e) {
        emit(
          (state as ChatMessagesFetchSuccess).copyWith(
            newFetchMoreTransactionsInProgress: false,
            newFetchMoreTransactionsError: true,
          ),
        );
      }
    }
  }

  sendChatMessage(
      {required ChatUsersCubit chatUserCubit,
      required ChatUser chattingWith,
      required ChatMessage chatMessage,
      required int receiverId,
      bool isRetry = false}) async {
    //this function will add the ChatMessage in screen only
    //it'll not send it, but the UI itself will send it
    if (state is ChatMessagesFetchSuccess) {
      final thisState = (state as ChatMessagesFetchSuccess);
      List<ChatMessage> allMessages = thisState.chatMessages;
      List<int> loadingIds = thisState.loadingIds;
      List<int> errorIds = thisState.errorIds;
      if (!isRetry) {
        allMessages.insert(0, chatMessage);
      }
      if (!loadingIds.contains(chatMessage.id)) {
        loadingIds.add(chatMessage.id);
      }
      errorIds.remove(chatMessage.id);
      emit(thisState.copyWith(
        newChatMessages: allMessages,
        loadingIds: loadingIds,
        errorIds: errorIds,
      ));
      ChatMessage? newMessageNetwork;
      try {
        newMessageNetwork = await _chatRepository.sendChatMessage(
            message: chatMessage.messageType == ChatMessageType.textMessage
                ? chatMessage.message
                : "",
            receiverId: receiverId,
            filePaths: chatMessage.messageType != ChatMessageType.textMessage
                ? chatMessage.files
                : [],
            isParent: _isParent);
      } catch (_) {
        if (state is ChatMessagesFetchSuccess) {
          errorIds = (state as ChatMessagesFetchSuccess).errorIds;
          if (!errorIds.contains(chatMessage.id)) {
            errorIds.add(chatMessage.id);
          }
        }
      }
      if (state is ChatMessagesFetchSuccess) {
        loadingIds = (state as ChatMessagesFetchSuccess).loadingIds;
        loadingIds.remove(chatMessage.id);
        allMessages = (state as ChatMessagesFetchSuccess).chatMessages;

        //store new message data instead of local one
        int indexToBeChanged =
            allMessages.indexWhere((e) => e.id == chatMessage.id);
        if (newMessageNetwork != null) {
          allMessages.removeAt(indexToBeChanged);
          allMessages.insert(indexToBeChanged, newMessageNetwork);
        }
        emit(thisState.copyWith(
          newChatMessages: allMessages,
          loadingIds: loadingIds,
          errorIds: errorIds,
        ));

        //if a message is sent successfully, make the user first in user-list as well
        chatUserCubit.makeUserFirstOrAddFirst(
            chattingWith.copyWith(lastMessage: newMessageNetwork));
      }
    }
  }

  bool hasMore() {
    if (state is ChatMessagesFetchSuccess) {
      return (state as ChatMessagesFetchSuccess)
              .chatMessages
              .where((element) => !element.isLocallyStored)
              .length <
          (state as ChatMessagesFetchSuccess).totalOffset;
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
    //calling unread when closing as well as when opening
    markAsReadAll(
        changeCountForTotalUnreadUsers:
            false); //don't change total count in dispose, done it in init
    super.close();
  }
}
