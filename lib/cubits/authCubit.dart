import 'package:equatable/equatable.dart';
import 'package:eschool/data/models/parent.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class Unauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

class Authenticated extends AuthState {
  final String jwtToken;
  final bool isStudent;
  final Student student;
  final Parent parent;
  Authenticated({
    required this.jwtToken,
    required this.isStudent,
    required this.student,
    required this.parent,
  });

  @override
  List<Object?> get props => [jwtToken, parent, student, isStudent];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial()) {
    _checkIsAuthenticated();
  }

  void _checkIsAuthenticated() {
    if (authRepository.getIsLogIn()) {
      emit(
        Authenticated(
          jwtToken: authRepository.getJwtToken(),
          isStudent: authRepository.getIsStudentLogIn(),
          parent: authRepository.getIsStudentLogIn()
              ? Parent.fromJson({})
              : authRepository.getParentDetails(),
          student: authRepository.getIsStudentLogIn()
              ? authRepository.getStudentDetails()
              : Student.fromJson({}),
        ),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  void authenticateUser({
    required String jwtToken,
    required bool isStudent,
    required Parent parent,
    required Student student,
  }) {
    //
    authRepository.setJwtToken(jwtToken);
    authRepository.setIsLogIn(true);
    authRepository.setIsStudentLogIn(isStudent);
    authRepository.setStudentDetails(student);
    authRepository.setParentDetails(parent);
    //emit new state
    emit(
      Authenticated(
        jwtToken: jwtToken,
        isStudent: isStudent,
        student: student,
        parent: parent,
      ),
    );
  }

  Student getStudentDetails() {
    if (state is Authenticated) {
      return (state as Authenticated).student;
    }
    return Student.fromJson({});
  }

  Parent getParentDetails() {
    if (state is Authenticated) {
      return (state as Authenticated).parent;
    }
    return Parent.fromJson({});
  }

  bool isParent() {
    if (state is Authenticated) {
      return !(state as Authenticated).isStudent;
    }
    return false;
  }

  void signOut() {
    authRepository.signOutUser();
    emit(Unauthenticated());
  }
}
