import 'package:equatable/equatable.dart';
import 'package:eschool/data/models/parent.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SignInState extends Equatable {}

class SignInInitial extends SignInState {
  @override
  List<Object?> get props => [];
}

class SignInInProgress extends SignInState {
  @override
  List<Object?> get props => [];
}

class SignInSuccess extends SignInState {
  final String jwtToken;
  final bool isStudentLogIn;
  final Student student;

  final Parent parent;

  SignInSuccess({
    required this.jwtToken,
    required this.isStudentLogIn,
    required this.student,
    required this.parent,
  });
  @override
  List<Object?> get props => [jwtToken, isStudentLogIn, student];
}

class SignInFailure extends SignInState {
  final String errorMessage;

  SignInFailure(this.errorMessage);

  @override
  List<Object?> get props => [];
}

class SignInCubit extends Cubit<SignInState> {
  final AuthRepository _authRepository;

  SignInCubit(this._authRepository) : super(SignInInitial());

  Future<void> signInUser({
    required String userId,
    required String password,
    required bool isStudentLogin,
  }) async {
    emit(SignInInProgress());

    try {
      late Map<String, dynamic> result;

      if (isStudentLogin) {
        result = await _authRepository.signInStudent(
          grNumber: userId,
          password: password,
        );
      } else {

        result = await _authRepository.signInParent(
          email: userId,
          password: password,
        );
      }

      emit(
        SignInSuccess(
          jwtToken: result['jwtToken'],
          isStudentLogIn: isStudentLogin,
          student: isStudentLogin ? result['student'] : Student.fromJson({}),
          parent: isStudentLogin ? Parent.fromJson({}) : result['parent'],
        ),
      );
    } catch (e) {
      logger.e(e.toString());
      emit(SignInFailure(e.toString()));
    }
  }
}
