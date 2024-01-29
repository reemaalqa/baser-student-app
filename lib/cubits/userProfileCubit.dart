import 'package:equatable/equatable.dart';
import 'package:eschool/data/models/parent.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserProfileState extends Equatable {}

class UserProfileInitial extends UserProfileState {
  @override
  List<Object?> get props => [];
}

class UserProfileFetchInProgress extends UserProfileState {
  @override
  List<Object?> get props => [];
}

class UserProfileFetchSuccess extends UserProfileState {
  final bool wasUserLoggedIn;
  UserProfileFetchSuccess({required this.wasUserLoggedIn});
  @override
  List<Object?> get props => [];
}

class UserProfileFetchFailure extends UserProfileState {
  final String errorMessage;

  UserProfileFetchFailure(this.errorMessage);

  @override
  List<Object?> get props => [];
}

class UserProfileCubit extends Cubit<UserProfileState> {
  final AuthRepository _authRepository;

  UserProfileCubit(this._authRepository) : super(UserProfileInitial());

  Future<void> fetchAndSetUserProfile() async {
    emit(UserProfileFetchInProgress());
    if (_authRepository.getIsLogIn()) {
      try {
        if (_authRepository.getIsStudentLogIn()) {
          final Student? student = await _authRepository.fetchStudentProfile();
         // logger.i(student!.toJson());
          if (student == null) {
            _authRepository.signOutUser();
          } else {
            _authRepository.setStudentDetails(student);
          }
        } else {
          final Parent? parent = await _authRepository.fetchParentProfile();
          if (parent == null) {
            _authRepository.signOutUser();
          } else {
            _authRepository.setParentDetails(parent);
          }
        }
        emit(
          UserProfileFetchSuccess(wasUserLoggedIn: true),
        );
      } catch (e) {
        emit(UserProfileFetchFailure(e.toString()));
      }
    } else {
      emit(UserProfileFetchSuccess(wasUserLoggedIn: false));
    }
  }
}
