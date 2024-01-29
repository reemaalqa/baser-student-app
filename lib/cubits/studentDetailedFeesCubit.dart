// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool/data/models/fees.dart';
import 'package:eschool/data/repositories/studentRepository.dart';

abstract class StudentDetailedFeesState {}

class StudentDetailedFeesInitial extends StudentDetailedFeesState {}

class StudentDetailedFeesFetchSuccess extends StudentDetailedFeesState {
  final ChildFees childFees;

  StudentDetailedFeesFetchSuccess({required this.childFees});
}

class StudentDetailedFeesFetchFailure extends StudentDetailedFeesState {
  final String errorMessage;

  StudentDetailedFeesFetchFailure(this.errorMessage);
}

class StudentDetailedFeesFetchInProgress extends StudentDetailedFeesState {}

class StudentDetailedFeesCubit extends Cubit<StudentDetailedFeesState> {
  final StudentRepository _studentRepository;

  StudentDetailedFeesCubit(this._studentRepository)
      : super(StudentDetailedFeesInitial());

  void fetchDetailedFees({int? classSectionId, int? childId}) {
    emit(StudentDetailedFeesFetchInProgress());
    _studentRepository
        .fetchDetailedFees(childId: childId ?? 0)
        .then(
          (value) => emit(StudentDetailedFeesFetchSuccess(childFees: value)),
        )
        .catchError((e) => emit(StudentDetailedFeesFetchFailure(e.toString())));
  }

  bool isTransactionPending() {
    if (state is StudentDetailedFeesFetchSuccess) {
      return (state as StudentDetailedFeesFetchSuccess)
          .childFees
          .isAnotherFeeTransactionPending;
    }
    return false;
  }
}
