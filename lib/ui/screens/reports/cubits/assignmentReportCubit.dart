import 'package:eschool/ui/screens/reports/models/assignmentList.dart';
import 'package:eschool/ui/screens/reports/repositories/reportRepository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AssignmentReportState {}

class AssignmentReportInitial extends AssignmentReportState {}

class AssignmentReportFetchInProgress extends AssignmentReportState {}

class AssignmentReportFetchFailure extends AssignmentReportState {
  final String errorMessage;

  AssignmentReportFetchFailure(this.errorMessage);
}

class AssignmentReportFetchSuccess extends AssignmentReportState {
  final int? assignments;
  final int? submittedAssignments;
  final int? unsubmittedAssignments;
  final String? totalPoints;
  final String? totalObtainedPoints;
  final String? percentage;
  final AssignmentList submittedAssignmentWithPointsData;
  final int? subjectId;
  final bool fetchMoreAssignmentReportInProgress;
  final bool moreAssignmentReportFetchError;
  final int currentPage;
  final int totalPage;

  AssignmentReportFetchSuccess({
    required this.assignments,
    required this.submittedAssignments,
    required this.unsubmittedAssignments,
    required this.totalPoints,
    required this.totalObtainedPoints,
    required this.percentage,
    required this.submittedAssignmentWithPointsData,
    required this.subjectId,
    required this.fetchMoreAssignmentReportInProgress,
    required this.moreAssignmentReportFetchError,
    required this.currentPage,
    required this.totalPage,
  });

  AssignmentReportFetchSuccess copyWith({
    AssignmentList? newAssignmentList,
    bool? newFetchMoreAssignmentReportInProgress,
    bool? newMoreFetchError,
    int? newCurrentPage,
    int? newTotalPage,
  }) {
    return AssignmentReportFetchSuccess(
      subjectId: subjectId,
      assignments: assignments,
      currentPage: newCurrentPage ?? currentPage,
      fetchMoreAssignmentReportInProgress: false,
      moreAssignmentReportFetchError: false,
      totalPage: newTotalPage ?? totalPage,
      percentage: percentage,
      totalPoints: totalPoints,
      submittedAssignments: submittedAssignments,
      unsubmittedAssignments: unsubmittedAssignments,
      totalObtainedPoints: totalObtainedPoints,
      submittedAssignmentWithPointsData:
          newAssignmentList ?? submittedAssignmentWithPointsData,
    );
  }
}

class AssignmentReportCubit extends Cubit<AssignmentReportState> {
  final ReportRepository _reportRepository;

  AssignmentReportCubit(this._reportRepository)
      : super(AssignmentReportInitial());

  Future<void> getAssignmentReport({
    required int subjectId,
    required int childId,
    required bool useParentApi,
  }) async {
    emit(AssignmentReportFetchInProgress());
    try {
      final assignmentDetailed = await _reportRepository.getAssignmentReport(
        subjectId: subjectId,
        childId: childId,
        useParentApi: useParentApi,
      );

      AssignmentList assignmentList = assignmentDetailed['assignmentList'];

      emit(
        AssignmentReportFetchSuccess(
          assignments: assignmentDetailed['assignments'],
          percentage: assignmentDetailed['percentage'],
          submittedAssignments: assignmentDetailed['submittedAssignments'],
          unsubmittedAssignments: assignmentDetailed['unsubmittedAssignments'],
          submittedAssignmentWithPointsData: assignmentList,
          totalObtainedPoints: assignmentDetailed['totalObtainedPoints'],
          totalPoints: assignmentDetailed['totalPoints'],
          fetchMoreAssignmentReportInProgress: false,
          moreAssignmentReportFetchError: false,
          currentPage: assignmentList.currentPage!,
          totalPage: assignmentList.lastPage!,
          subjectId: subjectId,
        ),
      );
    } catch (e) {
      emit(AssignmentReportFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is AssignmentReportFetchSuccess) {
      return (state as AssignmentReportFetchSuccess).currentPage <
          (state as AssignmentReportFetchSuccess).totalPage;
    }
    return false;
  }

  Future<void> getMoreAssignmentReport({
    required int childId,
    required bool useParentApi,
  }) async {
    if (state is AssignmentReportFetchSuccess) {
      if ((state as AssignmentReportFetchSuccess)
          .fetchMoreAssignmentReportInProgress) {
        return;
      }
    }
    try {
      emit(
        (state as AssignmentReportFetchSuccess)
            .copyWith(newFetchMoreAssignmentReportInProgress: true),
      );

      final moreOnlineExamReport = await _reportRepository.getExamOnlineReport(
        childId: childId,
        useParentApi: useParentApi,
        page: (state as AssignmentReportFetchSuccess)
                .submittedAssignmentWithPointsData
                .currentPage! +
            1,
        subjectId: (state as AssignmentReportFetchSuccess).subjectId!,
      );

      final currentState = state as AssignmentReportFetchSuccess;
      AssignmentList assignmentList =
          currentState.submittedAssignmentWithPointsData;

      //add more assignmentList into existing assignmentList
      assignmentList.data!.addAll([assignmentList].first.data!);
      emit(
        AssignmentReportFetchSuccess(
          fetchMoreAssignmentReportInProgress: false,
          subjectId: currentState.subjectId,
          moreAssignmentReportFetchError: false,
          currentPage: assignmentList.currentPage!,
          totalPage: assignmentList.lastPage!,
          percentage: moreOnlineExamReport['percentage'],
          assignments: moreOnlineExamReport['assignments'],
          submittedAssignments: moreOnlineExamReport['submittedAssignments'],
          unsubmittedAssignments:
              moreOnlineExamReport['unsubmittedAssignments'],
          submittedAssignmentWithPointsData: assignmentList,
          totalObtainedPoints: moreOnlineExamReport['totalObtainedPoints'],
          totalPoints: moreOnlineExamReport['totalPoints'],
        ),
      );
    } catch (e) {
      emit(
        (state as AssignmentReportFetchSuccess).copyWith(
          newFetchMoreAssignmentReportInProgress: false,
          newMoreFetchError: true,
        ),
      );
    }
  }
}
