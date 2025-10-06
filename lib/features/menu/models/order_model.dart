
class Order {
  final int tableId;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double grandTotal;

  Order({
    required this.tableId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      tableId: json['tableId'],
      items: (json['items'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
    );
  }
}

class OrderItem {
  final int itemId;
  final String name;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'],
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

