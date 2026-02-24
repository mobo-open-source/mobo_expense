class JournalPaymentModel {
  final int id;
  final String name;

  JournalPaymentModel({required this.id, required this.name});

  factory JournalPaymentModel.fromJson(Map<String, dynamic> json) {
    final company = json['company_id'];

    return JournalPaymentModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}
