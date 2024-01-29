// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool/data/models/fees.dart';
import 'package:eschool/data/repositories/studentRepository.dart';

abstract class FeesPaymentState {}

class FeesPaymentInitial extends FeesPaymentState {}

class FeesPaymentFetchSuccess extends FeesPaymentState {
  final Map paymentGatewayDetails;
  FeesPaymentFetchSuccess(this.paymentGatewayDetails);
}

class FeesPaymentFetchFailure extends FeesPaymentState {
  final String errorMessage;

  FeesPaymentFetchFailure(this.errorMessage);
}

class FeesPaymentFetchInProgress extends FeesPaymentState {}

class FeesPaymentCubit extends Cubit<FeesPaymentState> {
  final StudentRepository _studentRepository;

  FeesPaymentCubit(this._studentRepository) : super(FeesPaymentInitial());

  void addFeesTransaction({
    required int childId,
    required double transactionAmount,
    required int typeOfFee,
    required bool isFullyPaid,
    required double? paidDueCharges,
    double? compulsoryAmountPaid,
    double? dueChargesPaid,
    required int feesType, //0 = compulsory, 1 = installments, 2 = optional
    required List<FeesData> selectedFees,
  }) {
    emit(FeesPaymentFetchInProgress());
    _studentRepository
        .addFeesTransaction(
          transactionAmount: transactionAmount,
          childId: childId,
          typeOfFee: typeOfFee,
          isFullyPaid: isFullyPaid,
          paidDueCharges: paidDueCharges,
          compulsoryAmountPaid: compulsoryAmountPaid,
          dueChargesPaid: dueChargesPaid,
          feesType: feesType,
          selectedFees: selectedFees,
        )
        .then((value) => emit(FeesPaymentFetchSuccess(value)))
        .catchError((e) => emit(FeesPaymentFetchFailure(e.toString())));
  }
}
