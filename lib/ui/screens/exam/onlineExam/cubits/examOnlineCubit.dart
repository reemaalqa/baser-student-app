import 'package:eschool/data/models/examsOnline.dart';
import 'package:eschool/data/repositories/examRepository.dart';
import 'package:eschool/ui/screens/exam/onlineExam/models/question.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ExamOnlineState {}

class ExamOnlineInitial extends ExamOnlineState {}

class ExamOnlineFetchInProgress extends ExamOnlineState {}

class ExamOnlineFetchFailure extends ExamOnlineState {
  final String errorMessage;

  ExamOnlineFetchFailure(this.errorMessage);
}

class ExamOnlineFetchSuccess extends ExamOnlineState {
  final List<Question> questions;
  final int? totalQues;
  final int? totalMarks;

  ExamOnlineFetchSuccess({
    required this.totalQues,
    required this.totalMarks,
    required this.questions,
  });
}

class ExamOnlineAnswerSubmitted extends ExamOnlineState {
  final String responseMessage;

  ExamOnlineAnswerSubmitted(this.responseMessage);
}

class ExamOnlineAnswerSubmissionFail extends ExamOnlineState {
  final String responseMessage;

  ExamOnlineAnswerSubmissionFail(this.responseMessage);
}

class ExamOnlineCubit extends Cubit<ExamOnlineState> {
  final ExamOnlineRepository _examRepository;

  ExamOnlineCubit(this._examRepository) : super(ExamOnlineInitial());

  Future<void> startExam({required ExamsOnline exam}) async {
    emit(ExamOnlineFetchInProgress());
    try {
      final onlineExamDetailed = await _examRepository.getOnlineExamDetails(
        examId: exam.id,
        examKey: exam.examKey,
      );

      final int noOfQue = onlineExamDetailed['totalQuestions'];
      final int totalMarks = onlineExamDetailed['totalMarks'];
      List<Question> questions = onlineExamDetailed['question'];
      emit(
        ExamOnlineFetchSuccess(
          totalMarks: totalMarks,
          totalQues: noOfQue,
          questions: arrangeQuestions(questions),
        ),
      );
    } catch (e) {
      emit(ExamOnlineFetchFailure(e.toString()));
    }
  }

  List<Question> arrangeQuestions(List<Question> questions) {
    List<Question> arrangedQuestions = [];

    List<String> marks =
        questions.map((question) => question.marks!).toSet().toList();
    //sort marks
    marks.sort((first, second) => first.compareTo(second));

    //arrange questions from low to high mark
    marks.forEach((questionMark) {
      arrangedQuestions.addAll(
        questions.where((element) => element.marks == questionMark).toList(),
      );
    });

    return arrangedQuestions;
  }

  int getQuetionIndexById(int questionId) {
    if (state is ExamOnlineFetchSuccess) {
      return (state as ExamOnlineFetchSuccess)
          .questions
          .indexWhere((element) => element.id == questionId);
    }
    return 0;
  }

  void updateQuestionWithAnswer(int questionId, List<int> submittedAnswerId) {
    if (state is ExamOnlineFetchSuccess) {
      final List<Question> updatedQuestions =
          (state as ExamOnlineFetchSuccess).questions;
      final int questionIndex =
          updatedQuestions.indexWhere((element) => element.id == questionId);
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex]
          .updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId);
      emit(
        ExamOnlineFetchSuccess(
          totalMarks: (state as ExamOnlineFetchSuccess).totalMarks,
          totalQues: (state as ExamOnlineFetchSuccess).totalQues,
          questions: updatedQuestions,
        ),
      );
    }
  }

  void setExamOnlineAnswers({
    required int examId,
    required Map<int, List<int>> selectedAnswersWithQuestionId,
  }) {
    emit(ExamOnlineFetchInProgress());

    _examRepository
        .setExamOnlineAnswers(
          examId: examId,
          answerData: selectedAnswersWithQuestionId,
        )
        .then((value) => emit(ExamOnlineAnswerSubmitted(value)))
        .catchError((e) => emit(ExamOnlineAnswerSubmissionFail(e.toString())));
  }

  List<Question> getQuestions() {
    if (state is ExamOnlineFetchSuccess) {
      return (state as ExamOnlineFetchSuccess).questions;
    }
    return [];
  }

  int? getTotalMarks() {
    if (state is ExamOnlineFetchSuccess) {
      return (state as ExamOnlineFetchSuccess).totalMarks;
    }
    return 0;
  }

  int? getTotalQuestions() {
    if (state is ExamOnlineFetchSuccess) {
      return (state as ExamOnlineFetchSuccess).totalQues;
    }
    return 0;
  }

  List<Question> getQuestionsByMark(String questionMark) {
    if (state is ExamOnlineFetchSuccess) {
      return (state as ExamOnlineFetchSuccess)
          .questions
          .where((question) => question.marks == questionMark)
          .toList();
    }
    return [];
  }

  List<String> getUniqueQuestionMark() {
    if (state is ExamOnlineFetchSuccess) {
      return (state as ExamOnlineFetchSuccess)
          .questions
          .map((question) => question.marks!)
          .toSet()
          .toList();
    }
    return [];
  }
}
