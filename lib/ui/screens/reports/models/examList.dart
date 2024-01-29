class ExamList {
  late final int? currentPage;
  late final List<Data>? data;
  late final int? from;
  late final int? lastPage;
  late final int? perPage;
  late final int? to;
  late final int? total;

  ExamList({
    this.currentPage,
    this.data,
    this.from,
    this.lastPage,
    this.perPage,
    this.to,
    this.total,
  });

  ExamList.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] ?? 0;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    from = json['from'] ?? 0;
    lastPage = json['last_page'] ?? 0;
    perPage = json['per_page'] ?? 0;
    to = json['to'] ?? 0;
    total = json['total'] ?? 0;
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

class Data {
  int? onlineExamId;
  String? title;
  String? obtainedMarks;
  String? totalMarks;

  Data({this.onlineExamId, this.title, this.obtainedMarks, this.totalMarks});

  Data.fromJson(Map<String, dynamic> json) {
    onlineExamId = json['online_exam_id'] ?? 0;
    title = json['title'] ?? '';
    obtainedMarks = json['obtained_marks'] ?? '0';
    totalMarks = json['total_marks'] ?? '0';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['online_exam_id'] = onlineExamId;
    data['title'] = title;
    data['obtained_marks'] = obtainedMarks;
    data['total_marks'] = totalMarks;
    return data;
  }
}
