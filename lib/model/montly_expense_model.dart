class MonthlyAmountModel {
  final String month;
  final double amount;

  MonthlyAmountModel({required this.month, required this.amount});

  factory MonthlyAmountModel.fromJson(Map<String, dynamic> json) {
    return MonthlyAmountModel(
      month: json['date:month'] ?? '',
      amount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
