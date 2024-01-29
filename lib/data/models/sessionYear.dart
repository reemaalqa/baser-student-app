class SessionYear {
  SessionYear({
    required this.id,
    required this.name,
    required this.defaultValue,
    required this.startDate,
    required this.endDate,
    required this.feesDueCharges,
    required this.feesDueDate,
  });
  late final int id;
  late final String name;
  late final String defaultValue;
  late final DateTime startDate;
  late final DateTime endDate;
  late final String feesDueCharges;
  late final DateTime? feesDueDate;

  SessionYear.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    defaultValue = json['default'] ?? -1;
    startDate = json['start_date'] == null
        ? DateTime.now()
        : DateTime.parse(json['start_date'].toString());
    endDate = json['end_date'] == null
        ? DateTime.now()
        : DateTime.parse(json['end_date'].toString());
    feesDueCharges = json['fee_due_charges'].toString();
    feesDueDate = DateTime.tryParse(json['fee_due_date'].toString());
  }
}
