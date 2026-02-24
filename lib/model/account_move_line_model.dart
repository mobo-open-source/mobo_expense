class AccountMoveLine {
  final int id;
  final double quantity;
  final double priceUnit;
  final String name;
  final double priceSubtotal;

  AccountMoveLine({
    required this.id,
    required this.quantity,
    required this.priceUnit,
    required this.name,
    required this.priceSubtotal,
  });

  factory AccountMoveLine.fromJson(Map<String, dynamic> json) {
    return AccountMoveLine(
      id: json['id'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      priceUnit: (json['price_unit'] ?? 0).toDouble(),
      name: json['name'] ?? '',
      priceSubtotal: (json['price_subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price_unit': priceUnit,
      'name': name,
      'price_subtotal': priceSubtotal,
    };
  }
}
