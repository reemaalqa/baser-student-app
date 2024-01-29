import '../../../../utils/constants.dart';

class AssignmentList {
  late final int? currentPage;
  late final List<assignmentData>? data;
  late final int? from;
  late final int? lastPage;
  late final int? perPage;
  late final int? to;
  late final int? total;

  AssignmentList({
    required this.currentPage,
    required this.data,
    required this.from,
    required this.lastPage,
    required this.perPage,
    required this.to,
    required this.total,
  });

  AssignmentList.fromJson(Map<String, dynamic> json) {
    logger.i(json);
    currentPage = int.parse((json['current_page']??0).toString());
    if (json['data'] != null) {
      data = <assignmentData>[];
      json['data'].forEach((v) {
        data!.add(assignmentData.fromJson(v));
      });
    }
    from = int.parse((json['from']??0).toString());
    lastPage = int.parse((json['last_page']??0).toString());
    perPage = int.parse((json['per_page']??0).toString());
    to = int.parse((json['to']??0).toString());
    total = int.parse((json['total']??0).toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['from'] = from;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class assignmentData {
  late final int? assignmentId;
  late final String? assignmentName;
  late final int? obtainedPoints;
  late final int? totalPoints;

  assignmentData({
    required this.assignmentId,
    required this.assignmentName,
    required this.obtainedPoints,
    required this.totalPoints,
  });

  assignmentData.fromJson(Map<String, dynamic> json) {
    assignmentId = int.parse((json['assignment_id']??0).toString());
    assignmentName = json['assignment_name'];
    obtainedPoints = int.parse((json['obtained_points']??0).toString());
    totalPoints = int.parse((json['total_points']??0).toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['assignment_id'] = assignmentId;
    data['assignment_name'] = assignmentName;
    data['obtained_points'] = obtainedPoints;
    data['total_points'] = totalPoints;
    return data;
  }
}
