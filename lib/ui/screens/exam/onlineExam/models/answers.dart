class Answers {
  Answers(
    {required this.id, required this.optionId, required this.answer,});
  late final int id;
  late final int optionId;
  late final String answer;
  
  Answers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    optionId = json['option_id'];
    answer = json['answer'];
  }
}
