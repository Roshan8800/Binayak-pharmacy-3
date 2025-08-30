class Medicine {
  final int? id;
  final String name;
  final String? description;
  final int quantity;
  final double price;
  final DateTime expiryDate;

  Medicine({
    this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.price,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      price: map['price'],
      expiryDate: DateTime.parse(map['expiryDate']),
    );
  }
}
