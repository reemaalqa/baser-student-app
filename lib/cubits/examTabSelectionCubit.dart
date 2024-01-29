import 'package:eschool/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamTabSelectionState {
  //online or offline
  final String examFilterTabTitle;
  final int examFilterBySubjectId;

  ExamTabSelectionState({
    required this.examFilterBySubjectId,
    required this.examFilterTabTitle,
  });
}

class ExamTabSelectionCubit extends Cubit<ExamTabSelectionState> {
  ExamTabSelectionCubit()
      : super(
          ExamTabSelectionState(
            examFilterBySubjectId: 0,
            examFilterTabTitle: offlineKey,
          ),
        ); //offline bydefault

  void changeExamFilterTabTitle(String examFilterTabTitle) {
    emit(
      ExamTabSelectionState(
        examFilterBySubjectId: state.examFilterBySubjectId,
        examFilterTabTitle: examFilterTabTitle,
      ),
    );
  }

  void changeExamFilterBySubjectId(int examFilterBySubjectId) {
    emit(
      ExamTabSelectionState(
        examFilterBySubjectId: examFilterBySubjectId,
        examFilterTabTitle: state.examFilterTabTitle,
      ),
    );
  }

  bool isExamOnline() {
    //change bool to int If required to use further for API
    return state.examFilterTabTitle == onlineKey;
  }
}
