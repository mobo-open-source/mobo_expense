class TaxModel {
  final int id;
  final String? name;
  TaxModel({required this.id, this.name});

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(id: json['id'], name: json['display_name'] ?? '');
  }
}
