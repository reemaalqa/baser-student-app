import 'package:equatable/equatable.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SelectElectiveSubjectsState extends Equatable {}

class SelectElectiveSubjectsInitial extends SelectElectiveSubjectsState {
  @override
  List<Object?> get props => [];
}

class SelectElectiveSubjectsInProgress extends SelectElectiveSubjectsState {
  @override
  List<Object?> get props => [];
}

class SelectElectiveSubjectsSuccess extends SelectElectiveSubjectsState {
  final List<int> electedSubjectIds;

  SelectElectiveSubjectsSuccess(this.electedSubjectIds);

  @override
  List<Object?> get props => [electedSubjectIds];
}

class SelectElectiveSubjectsFailure extends SelectElectiveSubjectsState {
  final String errorMessage;

  SelectElectiveSubjectsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class SelectElectiveSubjectsCubit extends Cubit<SelectElectiveSubjectsState> {
  final StudentRepository _studentRepository;

  SelectElectiveSubjectsCubit(this._studentRepository)
      : super(SelectElectiveSubjectsInitial());

  List<int> _getElectedSubjectIds(Map<int, List<int>> electedSubjectGroups) {
    List<int> subjectIds = [];

    for (var key in electedSubjectGroups.keys) {
      subjectIds.addAll(electedSubjectGroups[key]!.toList());
    }

    return subjectIds;
  }

  void selectElectiveSubjects({
    required Map<int, List<int>> electedSubjectGroups,
  }) {
    emit(SelectElectiveSubjectsInProgress());
    _studentRepository
        .selectElectiveSubjects(electedSubjectGroups: electedSubjectGroups)
        .then(
      (value) {
        return emit(
          SelectElectiveSubjectsSuccess(
            _getElectedSubjectIds(electedSubjectGroups),
          ),
        );
      },
    ).catchError((e) => emit(SelectElectiveSubjectsFailure(e.toString())));
  }
}
