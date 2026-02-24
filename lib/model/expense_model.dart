import 'package:intl/intl.dart';

class Expense {
  final int id;
  final List<dynamic> employeeId;
  final List<dynamic> taxIds;
  final String name;
  final String date;
  final List<dynamic> productId;
  final String paymentMode;
  final List<dynamic> activityIds;
  final List<dynamic> companyId;
  final double totalAmount;
  final double taxAmount;
  final double untaxAmount;
  final String state;
  final String description;
  final List<dynamic> department;
  final List<dynamic> manager;
  final List<dynamic> attachment;
  final List<dynamic> splitExpense;

  Expense({
    required this.id,
    required this.employeeId,
    required this.taxIds,
    required this.name,
    required this.date,
    required this.productId,
    required this.paymentMode,
    required this.activityIds,
    required this.companyId,
    required this.totalAmount,
    required this.taxAmount,
    required this.untaxAmount,
    required this.state,
    required this.description,
    required this.department,
    required this.manager,
    required this.attachment,
    required this.splitExpense,
  });

  ///  SAFE LIST PARSER (IMPORTANT)
  static List<dynamic> _safeList(dynamic value) {
    if (value == null || value == false) return [];
    if (value is List) return value;
    return [];
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,

      employeeId: _safeList(json['employee_id']),
      taxIds: _safeList(json['tax_ids']),
      department: _safeList(json['department_id']),
      manager: _safeList(json['manager_id']),
      splitExpense: _safeList(json['split_expense_origin_id']),
      attachment: _safeList(json['message_main_attachment_id']),
      activityIds: _safeList(json['activity_ids']),
      companyId: _safeList(json['company_id']),
      productId: _safeList(json['product_id']),

      name: json['name'] ?? "",

      description: json['description'] == false
          ? ""
          : (json['description'] ?? ""),

      date: json['date'] == null || json['date'] == false
          ? ""
          : DateFormat('dd-MM-yyyy').format(DateTime.parse(json['date'])),

      paymentMode: json['payment_mode'] ?? "",

      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),

      /// Odoo sends this field
      untaxAmount: (json['untaxed_amount'] ?? 0).toDouble(),

      state: json['state'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "employee_id": employeeId,
      "tax_ids": taxIds,
      "name": name,
      "date": date,
      "product_id": productId,
      "payment_mode": paymentMode,
      "activity_ids": activityIds,
      "company_id": companyId,
      "total_amount": totalAmount,
      "tax_amount": taxAmount,
      "untaxed_amount_currency": untaxAmount,
      "state": state,
      "description": description,
      "message_main_attachment_id": attachment,
    };
  }

  Expense copyWith({
    int? id,
    List<dynamic>? employeeId,
    List<dynamic>? taxIds,
    String? name,
    String? date,
    List<dynamic>? productId,
    String? paymentMode,
    List<dynamic>? activityIds,
    List<dynamic>? companyId,
    double? totalAmount,
    double? taxAmount,
    double? untaxAmount,
    String? state,
    String? description,
    List<dynamic>? department,
    List<dynamic>? manager,
    List<dynamic>? attachment,
    List<dynamic>? splitExpense,
  }) {
    return Expense(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      taxIds: taxIds ?? this.taxIds,
      name: name ?? this.name,
      date: date ?? this.date,
      productId: productId ?? this.productId,
      paymentMode: paymentMode ?? this.paymentMode,
      activityIds: activityIds ?? this.activityIds,
      companyId: companyId ?? this.companyId,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      untaxAmount: untaxAmount ?? this.untaxAmount,
      state: state ?? this.state,
      description: description ?? this.description,
      department: department ?? this.department,
      manager: manager ?? this.manager,
      attachment: attachment ?? this.attachment,
      splitExpense: splitExpense ?? this.splitExpense,
    );
  }
}
