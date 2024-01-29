import 'package:eschool/data/models/feesTransaction.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FeesTransactionState {}

class FeesTransactionInitial extends FeesTransactionState {}

class FeesTransactionFetchInProgress extends FeesTransactionState {}

class FeesTransactionFetchFailure extends FeesTransactionState {
  final String errorMessage;
  final int? page;

  FeesTransactionFetchFailure({required this.errorMessage, this.page});
}

class FeesTransactionFetchSuccess extends FeesTransactionState {
  final List<FeesTransaction> feesTransactions;
  final int totalPage;
  final int currentPage;
  final bool moreTransactionsFetchError;
  final bool moreTransactionsFetchInProgress;

  FeesTransactionFetchSuccess({
    required this.feesTransactions,
    required this.totalPage,
    required this.currentPage,
    required this.moreTransactionsFetchError,
    required this.moreTransactionsFetchInProgress,
  });

  FeesTransactionFetchSuccess copyWith({
    List<FeesTransaction>? newTransactions,
    int? newTotalPage,
    int? newCurrentPage,
    bool? newFetchMoreTransactionsInProgress,
    bool? newFetchMoreTransactionsError,
  }) {
    return FeesTransactionFetchSuccess(
        feesTransactions: newTransactions ?? feesTransactions,
        totalPage: newTotalPage ?? totalPage,
        currentPage: newCurrentPage ?? currentPage,
        moreTransactionsFetchInProgress: newFetchMoreTransactionsInProgress ??
            moreTransactionsFetchInProgress,
        moreTransactionsFetchError:
            newFetchMoreTransactionsError ?? moreTransactionsFetchError);
  }
}

class FeesTransactionsCubit extends Cubit<FeesTransactionState> {
  final StudentRepository _studentRepository;

  FeesTransactionsCubit(this._studentRepository)
      : super(FeesTransactionInitial());

  bool isLoading() {
    if (state is FeesTransactionFetchInProgress) {
      return true;
    }
    return false;
  }

  void fetchFeesTransactions({
    required int page,
  }) {
    emit(FeesTransactionFetchInProgress());
    _studentRepository
        .fetchFeesTransactions(
          page: page,
        )
        .then(
          (value) => emit(
            FeesTransactionFetchSuccess(
              feesTransactions: value['feesTransactions'],
              totalPage: value['totalPage'],
              currentPage: value['currentPage'],
              moreTransactionsFetchError: false,
              moreTransactionsFetchInProgress: false,
            ),
          ),
        )
        .catchError(
          (e) => emit(
            FeesTransactionFetchFailure(
              errorMessage: e.toString(),
              page: page,
            ),
          ),
        );
  }

  Future<void> fetchMoreFeesTransactions() async {
    if (state is FeesTransactionFetchSuccess) {
      final stateAs = state as FeesTransactionFetchSuccess;
      if (stateAs.moreTransactionsFetchInProgress) {
        return;
      }
      try {
        emit(stateAs.copyWith(newFetchMoreTransactionsInProgress: true));

        final moreTransactionResult =
            await _studentRepository.fetchFeesTransactions(
          page: stateAs.currentPage + 1,
        );

        List<FeesTransaction> transactions = stateAs.feesTransactions;

        transactions.addAll(moreTransactionResult['feesTransactions']);

        emit(
          FeesTransactionFetchSuccess(
            feesTransactions: transactions,
            totalPage: moreTransactionResult['totalPage'],
            currentPage: moreTransactionResult['currentPage'],
            moreTransactionsFetchError: false,
            moreTransactionsFetchInProgress: false,
          ),
        );
      } catch (e) {
        emit(
          (state as FeesTransactionFetchSuccess).copyWith(
            newFetchMoreTransactionsInProgress: false,
            newFetchMoreTransactionsError: true,
          ),
        );
      }
    }
  }

  bool hasMore() {
    if (state is FeesTransactionFetchSuccess) {
      return (state as FeesTransactionFetchSuccess).currentPage <
          (state as FeesTransactionFetchSuccess).totalPage;
    }
    return false;
  }
}
