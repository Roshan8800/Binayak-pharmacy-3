class Sale {
  final int? id;
  final int medicineId;
  final int quantity;
  final double totalPrice;
  final DateTime date;

  Sale({
    this.id,
    required this.medicineId,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'date': date.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      medicineId: map['medicineId'],
      quantity: map['quantity'],
      totalPrice: map['totalPrice'],
      date: DateTime.parse(map['date']),
    );
  }
}
