import 'package:eschool/data/models/assignment.dart';
import 'package:eschool/data/repositories/assignmentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AssignmentsState {}

class AssignmentsInitial extends AssignmentsState {}

class AssignmentsFetchInProgress extends AssignmentsState {}

class AssignmentsFetchSuccess extends AssignmentsState {
  final List<Assignment> assignments;
  final int totalPage; //total page of assignments
  final int currentPage; //current assignments page
  final bool moreAssignmentsFetchError;
  //if subjectId is null then fetch all assignments else fetch assignments based on subjectId
  final int? subjectId;
  final bool fetchMoreAssignmentsInProgress;

  AssignmentsFetchSuccess({
    required this.assignments,
    this.subjectId,
    required this.fetchMoreAssignmentsInProgress,
    required this.moreAssignmentsFetchError,
    required this.currentPage,
    required this.totalPage,
  });

  AssignmentsFetchSuccess copyWith({
    List<Assignment>? newAssignments,
    bool? newFetchMoreAssignmentsInProgress,
    bool? newMoreAssignmentsFetchError,
    int? newCurrentPage,
    int? newTotalPage,
  }) {
    return AssignmentsFetchSuccess(
      subjectId: subjectId,
      assignments: newAssignments ?? assignments,
      fetchMoreAssignmentsInProgress:
          newFetchMoreAssignmentsInProgress ?? fetchMoreAssignmentsInProgress,
      moreAssignmentsFetchError:
          newMoreAssignmentsFetchError ?? moreAssignmentsFetchError,
      currentPage: newCurrentPage ?? currentPage,
      totalPage: newTotalPage ?? totalPage,
    );
  }
}

class AssignmentsFetchFailure extends AssignmentsState {
  final String errorMessage;
  final int? page;
  final int? subjectId;

  AssignmentsFetchFailure({
    required this.errorMessage,
    required this.page,
    required this.subjectId,
  });
}

class AssignmentsCubit extends Cubit<AssignmentsState> {
  final AssignmentRepository _assignmentRepository;

  AssignmentsCubit(this._assignmentRepository) : super(AssignmentsInitial());

  void fetchAssignments({
    int? page,
    int? assignmentId,
    int? subjectId,
    required int isSubmitted,
    required int childId,
    required bool useParentApi,
  }) {
    emit(AssignmentsFetchInProgress());
    _assignmentRepository
        .fetchAssignments(
          childId: childId,
          useParentApi: useParentApi,
          assignmentId: assignmentId,
          page: page,
          subjectId: subjectId,
          isSubmitted: isSubmitted,
        )
        .then(
          (value) => emit(
            AssignmentsFetchSuccess(
              fetchMoreAssignmentsInProgress: false,
              subjectId: subjectId,
              moreAssignmentsFetchError: false,
              assignments: value['assignments'],
              currentPage: value['currentPage'],
              totalPage: value['totalPage'],
            ),
          ),
        )
        .catchError(
          (e) => emit(
            AssignmentsFetchFailure(
              errorMessage: e.toString(),
              page: page,
              subjectId: subjectId,
            ),
          ),
        );
  }

  List<Assignment> getAssignedAssignments() {
    if (state is AssignmentsFetchSuccess) {
      return (state as AssignmentsFetchSuccess)
          .assignments
          .where((element) => element.assignmentSubmission.id == 0)
          .toList();
    }
    return [];
  }

  List<Assignment> getSubmittedAssignments() {
    if (state is AssignmentsFetchSuccess) {
      return (state as AssignmentsFetchSuccess)
          .assignments
          .where((element) => element.assignmentSubmission.id != 0)
          .toList();
    }
    return [];
  }

  bool hasMore() {
    if (state is AssignmentsFetchSuccess) {
      return (state as AssignmentsFetchSuccess).currentPage <
          (state as AssignmentsFetchSuccess).totalPage;
    }
    return false;
  }

  Future<void> fetchMoreAssignments({
    required int childId,
    required bool useParentApi,
    required int isSubmitted,
  }) async {
    if (state is AssignmentsFetchSuccess) {
      if ((state as AssignmentsFetchSuccess).fetchMoreAssignmentsInProgress) {
        return;
      }
      try {
        emit(
          (state as AssignmentsFetchSuccess)
              .copyWith(newFetchMoreAssignmentsInProgress: true),
        );
        //fetch more assignemnts
        //more assignment result
        final moreAssignmentsResult =
            await _assignmentRepository.fetchAssignments(
          childId: childId,
          useParentApi: useParentApi,
          isSubmitted: isSubmitted,
          page: (state as AssignmentsFetchSuccess).currentPage + 1,
          subjectId: (state as AssignmentsFetchSuccess).subjectId,
        );

        final currentState = state as AssignmentsFetchSuccess;
        // ignore: prefer_final_locals
        List<Assignment> assignments = currentState.assignments;

        //add more assignments into original assignments list
        assignments.addAll(moreAssignmentsResult['assignments']);

        emit(
          AssignmentsFetchSuccess(
            fetchMoreAssignmentsInProgress: false,
            subjectId: currentState.subjectId,
            assignments: assignments,
            moreAssignmentsFetchError: false,
            currentPage: moreAssignmentsResult['currentPage'],
            totalPage: moreAssignmentsResult['totalPage'],
          ),
        );
      } catch (e) {
        emit(
          (state as AssignmentsFetchSuccess).copyWith(
            newFetchMoreAssignmentsInProgress: false,
            newMoreAssignmentsFetchError: true,
          ),
        );
      }
    }
  }

  void updateAssignments(Assignment assignment) {
    if (state is AssignmentsFetchSuccess) {
      List<Assignment> updatedAssignments =
          (state as AssignmentsFetchSuccess).assignments;
      final assignmentIndex = updatedAssignments
          .indexWhere((element) => element.id == assignment.id);
      if (assignmentIndex != -1) {
        updatedAssignments[assignmentIndex] = assignment;
        emit(
          (state as AssignmentsFetchSuccess)
              .copyWith(newAssignments: updatedAssignments),
        );
      }
    }
  }

  /* Assignment? getSubmittedAssignmentFromReport(int assignmentId) {
    if (state is AssignmentsFetchSuccess) {
      return (state as AssignmentsFetchSuccess).assignments.firstWhere(
          (element) =>
              element.assignmentSubmission.id != 0 &&
              element.id == assignmentId);
    }
    return null;
  } */
}
