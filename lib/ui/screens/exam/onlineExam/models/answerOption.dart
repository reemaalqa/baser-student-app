class AnswerOption {
  late final int? id;
  late final String? option;

  AnswerOption({this.id, this.option});
  AnswerOption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    option = json['option'];
  }
} 
