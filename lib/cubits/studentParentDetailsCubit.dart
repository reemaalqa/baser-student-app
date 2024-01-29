import 'package:equatable/equatable.dart';
import 'package:eschool/data/models/parent.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentParentDetailsState extends Equatable {}

class StudentParentDetailsInitial extends StudentParentDetailsState {
  @override
  List<Object?> get props => [];
}

class StudentParentDetailsFetchInProgress extends StudentParentDetailsState {
  @override
  List<Object?> get props => [];
}

class StudentParentDetailsFetchSuccess extends StudentParentDetailsState {
  final Parent? mother;
  final Parent? father;
  final Parent? guardian;

  StudentParentDetailsFetchSuccess({
    required this.father,
    required this.guardian,
    required this.mother,
  });
  @override
  List<Object?> get props => [mother, father, guardian];
}

class StudentParentDetailsFetchFailure extends StudentParentDetailsState {
  final String errorMessage;

  StudentParentDetailsFetchFailure(this.errorMessage);

  @override
  List<Object?> get props => [];
}

class StudentParentDetailsCubit extends Cubit<StudentParentDetailsState> {
  final StudentRepository _studentRepository;

  StudentParentDetailsCubit(this._studentRepository)
      : super(StudentParentDetailsInitial());

  Future<void> getStudentParentDetails() async {
    try {
      final result = await _studentRepository.fetchParentDetails();
      emit(
        StudentParentDetailsFetchSuccess(
          father: result['father'],
          guardian: result['guardian'],
          mother: result['mother'],
        ),
      );
    } catch (e) {
      emit(StudentParentDetailsFetchFailure(e.toString()));
    }
  }
}
