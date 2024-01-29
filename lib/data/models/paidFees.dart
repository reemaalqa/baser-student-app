import 'package:eschool/data/models/sessionYear.dart';
import 'package:eschool/data/models/studentClass.dart';

class PaidFees {
  late final int id;
  late final int parentId;
  late final int studentId;
  late final int classId;
  late final int mode;
  late final String transactionId;
  late final String chequeNumber;
  late final double totalAmount;
  late final DateTime dateOfPayment;
  late final int sessionYearId;
  late final SessionYear sessionYear;
  late final StudentClass stClass;
  late final bool isFullyPaid;

  PaidFees({
    required this.id,
    required this.parentId,
    required this.studentId,
    required this.classId,
    required this.mode,
    required this.transactionId,
    required this.chequeNumber,
    required this.totalAmount,
    required this.dateOfPayment,
    required this.sessionYearId,
    required this.sessionYear,
    required this.stClass,
    this.isFullyPaid = false,
  });

  PaidFees.fromJson(Map<String, dynamic> json) {
    id = json["id"] ?? 0;
    parentId = int.parse((json["parent_id"] ?? 0).toString());
    studentId = int.parse((json["student_id"] ?? 0).toString());
    classId = int.parse((json["class_id"] ?? 0).toString());
    mode = int.parse((json["mode"] ?? 0).toString());
    isFullyPaid = json['is_fully_paid'].toString() == "1";
    transactionId = json["transaction_id"] ?? '';
    chequeNumber = json["cheque_no"] ?? '';
    totalAmount = double.parse(json["total_amount"].toString());
    dateOfPayment = json['date'] == null
        ? DateTime.now()
        : DateTime.parse(json['date'].toString());
    sessionYearId = int.parse((json["session_year_id"] ?? 0).toString());
    sessionYear = SessionYear.fromJson(json['session_year'] ?? {});
    stClass = StudentClass.fromJson(json["class"] ?? {});
  }
}
