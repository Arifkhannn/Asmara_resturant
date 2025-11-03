class Order {
  final int tableId; // representative (first id in tableIds)
  final List<int> tableIds; // full list used for backend
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double grandTotal;
  final int orderId; // optional unique id per batch
  final DateTime createdAt; // timestamp

  Order({
    required this.tableId,
    required this.tableIds,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
    this.orderId = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Order copyWith({
    int? tableId,
    List<int>? tableIds,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? grandTotal,
    int? orderId,
    DateTime? createdAt,
  }) {
    return Order(
      tableId: tableId ?? this.tableId,
      tableIds: tableIds ?? this.tableIds,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      grandTotal: grandTotal ?? this.grandTotal,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<int> tidList;
    if (json['tableIds'] != null) {
      tidList = (json['tableIds'] as List).map((e) => (e as num).toInt()).toList();
    } else if (json['tableId'] != null) {
      tidList = [(json['tableId'] as num).toInt()];
    } else {
      tidList = [];
    }

    return Order(
      tableId: tidList.isNotEmpty ? tidList.first : 0,
      tableIds: tidList,
      items: (json['items'] as List? ?? []).map((e) => OrderItem.fromJson(e)).toList(),
      subtotal: (json['subtotal'] as num? ?? 0).toDouble(),
      tax: (json['tax'] as num? ?? 0).toDouble(),
      grandTotal: (json['grandTotal'] as num? ?? 0).toDouble(),
      orderId: json['orderId'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'tableIds': tableIds,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'grandTotal': grandTotal,
      'orderId': orderId,
      'createdAt': createdAt.toIso8601String(),
    };
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
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
