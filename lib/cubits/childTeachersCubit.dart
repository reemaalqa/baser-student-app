import 'package:eschool/data/models/teacher.dart';
import 'package:eschool/data/repositories/parentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChildTeachersState {}

class ChildTeachersInitial extends ChildTeachersState {}

class ChildTeachersFetchInProgress extends ChildTeachersState {}

class ChildTeachersFetchSuccess extends ChildTeachersState {
  final List<Teacher> teachers;

  ChildTeachersFetchSuccess({required this.teachers});
}

class ChildTeachersFetchFailure extends ChildTeachersState {
  final String errorMessage;

  ChildTeachersFetchFailure(this.errorMessage);
}

class ChildTeachersCubit extends Cubit<ChildTeachersState> {
  final ParentRepository _parentRepository;

  ChildTeachersCubit(this._parentRepository) : super(ChildTeachersInitial());

  Future<void> fetchChildTeachers({required int childId}) async {
    emit(ChildTeachersFetchInProgress());
    try {
      final teachers =
          await _parentRepository.fetchChildTeachers(childId: childId);
      emit(ChildTeachersFetchSuccess(teachers: teachers));
    } catch (e) {
      emit(ChildTeachersFetchFailure(e.toString()));
    }
  }
}
