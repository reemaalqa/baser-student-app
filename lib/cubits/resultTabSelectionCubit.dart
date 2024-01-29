import 'package:eschool/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultTabSelectionState {
  //online or offline
  final String resultFilterTabTitle;
  final int resultFilterBySubjectId;

  ResultTabSelectionState({
    required this.resultFilterBySubjectId,
    required this.resultFilterTabTitle,
  });
}

class ResultTabSelectionCubit extends Cubit<ResultTabSelectionState> {
  ResultTabSelectionCubit()
      : super(
          ResultTabSelectionState(
            resultFilterBySubjectId: 0,
            resultFilterTabTitle: offlineKey,
          ),
        ); //offline bydefault

  void changeResultFilterTabTitle(String resultFilterTabTitle) {
    emit(
      ResultTabSelectionState(
        resultFilterBySubjectId: state.resultFilterBySubjectId,
        resultFilterTabTitle: resultFilterTabTitle,
      ),
    );
  }

  void changeResultFilterBySubjectId(int resultFilterBySubjectId) {
    emit(
      ResultTabSelectionState(
        resultFilterBySubjectId: resultFilterBySubjectId,
        resultFilterTabTitle: state.resultFilterTabTitle,
      ),
    );
  }

  bool isResultOnline() {
    //change bool to int If required to use further for API
    return state.resultFilterTabTitle == onlineKey;
  }
}
