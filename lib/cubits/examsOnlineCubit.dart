import 'package:eschool/data/models/examsOnline.dart';
import 'package:eschool/data/repositories/examRepository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ExamsOnlineState {}

class ExamsOnlineInitial extends ExamsOnlineState {}

class ExamsOnlineFetchInProgress extends ExamsOnlineState {}

class ExamsOnlineFetchSuccess extends ExamsOnlineState {
  final List<ExamsOnline> examList;
  final int totalPage;
  final int currentPage;
  final bool moreExamsFetchError;
  //if subjectId is null then fetch all exams else fetch exams based on subjectId
  final int? subjectId;
  final bool fetchMoreExamsInProgress;

  ExamsOnlineFetchSuccess({
    required this.examList,
    this.subjectId,
    required this.fetchMoreExamsInProgress,
    required this.moreExamsFetchError,
    required this.currentPage,
    required this.totalPage,
  });

  ExamsOnlineFetchSuccess copyWith({
    List<ExamsOnline>? newExamList,
    bool? newFetchMoreExamsInProgress,
    bool? newMoreExamsFetchError,
    int? newCurrentPage,
    int? newTotalPage,
  }) {
    return ExamsOnlineFetchSuccess(
      subjectId: subjectId,
      examList: newExamList ?? examList,
      fetchMoreExamsInProgress:
          newFetchMoreExamsInProgress ?? fetchMoreExamsInProgress,
      moreExamsFetchError: newMoreExamsFetchError ?? moreExamsFetchError,
      currentPage: newCurrentPage ?? currentPage,
      totalPage: newTotalPage ?? totalPage,
    );
  }
}

class ExamsOnlineFetchFailure extends ExamsOnlineState {
  final String errorMessage;
  final int? page;
  final int? subjectId;

  ExamsOnlineFetchFailure(this.errorMessage, this.page, this.subjectId);
}

class ExamsOnlineCubit extends Cubit<ExamsOnlineState> {
  final ExamOnlineRepository examRepository;

  ExamsOnlineCubit(this.examRepository) : super(ExamsOnlineInitial());

  Future<void> getExamsOnline({
    int? page,
    required int subjectId,
    required int childId,
    required bool useParentApi,
  }) async {
    emit(ExamsOnlineFetchInProgress());
    try {
      examRepository
          .getExamsOnline(
            subjectId: subjectId,
            page: page,
            childId: childId,
            useParentApi: useParentApi,
          )
          .then(
            (value) => emit(
              ExamsOnlineFetchSuccess(
                subjectId: subjectId,
                examList: value['examList'],
                currentPage: value['currentPage'],
                totalPage: value['totalPage'],
                fetchMoreExamsInProgress: false,
                moreExamsFetchError: false,
              ),
            ),
          )
          .catchError(
            (e) => emit(ExamsOnlineFetchFailure(e.toString(), page, subjectId)),
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(ExamsOnlineFetchFailure(e.toString(), page, subjectId));
    }
  }

  Future<void> getMoreExamsOnline({
    required int childId,
    required bool useParentApi,
  }) async {
    if (state is ExamsOnlineFetchSuccess) {
      if ((state as ExamsOnlineFetchSuccess).fetchMoreExamsInProgress) {
        return;
      }
      try {
        emit(
          (state as ExamsOnlineFetchSuccess)
              .copyWith(newFetchMoreExamsInProgress: true),
        );

        final moreAssignmentsResult = await examRepository.getExamsOnline(
          page: (state as ExamsOnlineFetchSuccess).currentPage + 1,
          subjectId: (state as ExamsOnlineFetchSuccess).subjectId!,
          childId: childId,
          useParentApi: useParentApi,
        );

        final currentState = state as ExamsOnlineFetchSuccess;
        List<ExamsOnline> exams = currentState.examList;

        exams.addAll(moreAssignmentsResult['examList']);

        emit(
          ExamsOnlineFetchSuccess(
            fetchMoreExamsInProgress: false,
            subjectId: currentState.subjectId,
            examList: exams,
            moreExamsFetchError: false,
            currentPage: moreAssignmentsResult['currentPage'],
            totalPage: moreAssignmentsResult['totalPage'],
          ),
        );
      } catch (e) {
        emit(
          (state as ExamsOnlineFetchSuccess).copyWith(
            newFetchMoreExamsInProgress: false,
            newMoreExamsFetchError: true,
          ),
        );
      }
    }
  }

  bool hasMore() {
    if (state is ExamsOnlineFetchSuccess) {
      return (state as ExamsOnlineFetchSuccess).currentPage <
          (state as ExamsOnlineFetchSuccess).totalPage;
    }
    return false;
  }
}
