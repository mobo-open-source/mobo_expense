class CompanyExpenseModel {
  final int id;
  final double totalAmount;
  final int departmentId;
  final String departmentName;
  final int companyId;
  final String companyName;
  final String state;

  CompanyExpenseModel({
    required this.id,
    required this.totalAmount,
    required this.departmentId,
    required this.departmentName,
    required this.companyId,
    required this.companyName,
    required this.state,
  });

  /// Safe extractor for many2one fields
  static int _m2oId(dynamic value) {
    if (value == null || value == false) return 0;
    if (value is List && value.isNotEmpty) return value[0] ?? 0;
    return 0;
  }

  static String _m2oName(dynamic value) {
    if (value == null || value == false) return '';
    if (value is List && value.length > 1) return value[1] ?? '';
    return '';
  }

  factory CompanyExpenseModel.fromJson(Map<String, dynamic> json) {
    return CompanyExpenseModel(
      id: json['id'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),

      ///  Odoo 19 → exists
      ///  Odoo 18 → false / missing → safely handled
      departmentId: _m2oId(json['department_id']),
      departmentName: _m2oName(json['department_id']),

      companyId: _m2oId(json['company_id']),
      companyName: _m2oName(json['company_id']),

      state: json['state'] ?? '',
    );
  }
}
