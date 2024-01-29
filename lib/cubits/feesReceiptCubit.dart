// ignore: depend_on_referenced_packages
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool/data/models/paidFees.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:path_provider/path_provider.dart';

abstract class FeesReceiptState {}

class FeesReceiptInitial extends FeesReceiptState {}

class FeesReceiptDownloadSuccess extends FeesReceiptState {
  final String successMessageKey;
  final String filePath;
  final PaidFees fees;
  FeesReceiptDownloadSuccess({
    required this.successMessageKey,
    required this.filePath,
    required this.fees,
  });
}

class FeesReceiptDownloadFailure extends FeesReceiptState {
  final String errorMessage;

  FeesReceiptDownloadFailure(this.errorMessage);
}

class FeesReceiptDownloadInProgress extends FeesReceiptState {
  final PaidFees currentlyDownloading;
  FeesReceiptDownloadInProgress(this.currentlyDownloading);
}

class FeesReceiptCubit extends Cubit<FeesReceiptState> {
  final StudentRepository _studentRepository;

  FeesReceiptCubit(this._studentRepository) : super(FeesReceiptInitial());

  void downloadFeesReceipt({
    required int feesPaidId,
    required List<PaidFees> receiptList,
    required String fileNamePrefix,
  }) {
    final currentIndex = receiptList.indexWhere(
      (element) => element.id == feesPaidId,
    );
    emit(FeesReceiptDownloadInProgress(receiptList[currentIndex]));
    _studentRepository
        .downloadFeesReceipt(
      feesPaidId: feesPaidId,
    )
        .then((value) async {
      String filePath = "";
      final path = (await getApplicationDocumentsDirectory()).path;
      filePath =
          "$path/Fees Receipts/${fileNamePrefix}_fees_payment_receipt_on_${DateTime.now()}.pdf";

      final File file = File(filePath);
      if (!file.existsSync()) {
        await file.create(recursive: true);
      }
      await file.writeAsBytes(value);
      emit(
        FeesReceiptDownloadSuccess(
          successMessageKey: feesRecieptDownloadedKey,
          filePath: filePath,
          fees: receiptList[currentIndex],
        ),
      );
    }).catchError((e) {
      emit(FeesReceiptDownloadFailure(e.toString()));
    }).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        emit(FeesReceiptDownloadFailure(""));
      },
    );
  }
}
