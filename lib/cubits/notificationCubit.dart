import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/data/repositories/parentRepository.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/customNotification.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationFetchInProgress extends NotificationState {}

class NotificationFetchFailure extends NotificationState {
  final String errorMessage;
  final int? page;

  NotificationFetchFailure({required this.errorMessage, this.page});
}

class NotificationFetchSuccess extends NotificationState {
  final List<CustomNotification> notifications;
  final int totalPage;
  final int currentPage;
  final bool moreNotificationsFetchError;
  final bool moreNotificationsFetchInProgress;

  NotificationFetchSuccess({
    required this.notifications,
    required this.totalPage,
    required this.currentPage,
    required this.moreNotificationsFetchError,
    required this.moreNotificationsFetchInProgress,
  });

  NotificationFetchSuccess copyWith({
    List<CustomNotification>? newnotifications,
    int? newTotalPage,
    int? newCurrentPage,
    bool? newFetchMorenotificationsInProgress,
    bool? newFetchMorenotificationsError,
  }) {
    return NotificationFetchSuccess(
        notifications: newnotifications ?? notifications,
        totalPage: newTotalPage ?? totalPage,
        currentPage: newCurrentPage ?? currentPage,
        moreNotificationsFetchInProgress: newFetchMorenotificationsInProgress ??
            moreNotificationsFetchInProgress,
        moreNotificationsFetchError:
            newFetchMorenotificationsError ?? moreNotificationsFetchError);
  }
}

class NotificationsCubit extends Cubit<NotificationState> {
  final StudentRepository _studentRepository;
  final ParentRepository _parentRepository;

  NotificationsCubit(this._studentRepository, this._parentRepository)
      : super(NotificationInitial());

  bool isLoading() {
    if (state is NotificationFetchInProgress) {
      return true;
    }
    return false;
  }

  Future<void> fetchNotifications({
    required int page,
  }) async {
    emit(NotificationFetchInProgress());
    try {
      var value = {};
      if (AuthRepository().getIsStudentLogIn()) {
        value = await _studentRepository.fetchNotifications(
          page: page,
        );
      } else {
        value = await _parentRepository.fetchNotifications(
          page: page,
        );
      }
      emit(
        NotificationFetchSuccess(
          notifications: value['notifications'],
          totalPage: value['totalPage'],
          currentPage: value['currentPage'],
          moreNotificationsFetchError: false,
          moreNotificationsFetchInProgress: false,
        ),
      );
    } catch (e) {
      emit(NotificationFetchFailure(
        errorMessage: e.toString(),
        page: page,
      ));
    }
  }

  Future<void> fetchMoreNotifications() async {
    if (state is NotificationFetchSuccess) {
      final stateAs = state as NotificationFetchSuccess;
      if (stateAs.moreNotificationsFetchInProgress) {
        return;
      }
      try {
        emit(stateAs.copyWith(newFetchMorenotificationsInProgress: true));

        var moreTransactionResult = {};
        if (AuthRepository().getIsStudentLogIn()) {
          moreTransactionResult = await _studentRepository.fetchNotifications(
            page: stateAs.currentPage + 1,
          );
        } else {
          moreTransactionResult = await _parentRepository.fetchNotifications(
            page: stateAs.currentPage + 1,
          );
        }

        List<CustomNotification> notifications = stateAs.notifications;

        notifications.addAll(moreTransactionResult['notifications']);

        emit(
          NotificationFetchSuccess(
            notifications: notifications,
            totalPage: moreTransactionResult['totalPage'],
            currentPage: moreTransactionResult['currentPage'],
            moreNotificationsFetchError: false,
            moreNotificationsFetchInProgress: false,
          ),
        );
      } catch (e) {
        emit(
          (state as NotificationFetchSuccess).copyWith(
            newFetchMorenotificationsInProgress: false,
            newFetchMorenotificationsError: true,
          ),
        );
      }
    }
  }

  bool hasMore() {
    if (state is NotificationFetchSuccess) {
      return (state as NotificationFetchSuccess).currentPage <
          (state as NotificationFetchSuccess).totalPage;
    }
    return false;
  }
}
