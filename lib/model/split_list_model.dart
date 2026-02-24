import 'package:flutter/material.dart';

class SplitExpense {
  final int id;
  final String name;

  int? employeeId;
  String? employeeName;

  ///  remove final (editable)

  double totalAmountCurrency;

  ///  remove final (editable)

  /// wizard
  final int? wizardId;
  final String? wizardModel;

  ///  UI controllers
  late TextEditingController nameController;
  late TextEditingController amountController;

  SplitExpense({
    required this.id,
    required this.name,
    this.employeeId,
    this.employeeName,
    required this.totalAmountCurrency,
    this.wizardId,
    this.wizardModel,
  }) {
    nameController = TextEditingController(text: employeeName ?? '');
    amountController = TextEditingController(
      text: totalAmountCurrency.toString(),
    );

    nameController.addListener(() {
      if (nameController.text != employeeName) {
        employeeId = null;
      }
    });
  }

  factory SplitExpense.fromJson(Map<String, dynamic> json) {
    return SplitExpense(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      employeeId: json['employee_id'] != null ? json['employee_id'][0] : null,
      employeeName: json['employee_id'] != null ? json['employee_id'][1] : null,
      totalAmountCurrency: (json['total_amount_currency'] ?? 0).toDouble(),
      wizardId: json['wizard_id'] != null ? json['wizard_id'][0] : null,
      wizardModel: json['wizard_id'] != null ? json['wizard_id'][1] : null,
    );
  }

  ///  sync edited UI values back to model
  void syncFromControllers() {
    employeeName = nameController.text;
    totalAmountCurrency = double.tryParse(amountController.text) ?? 0.0;
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}
