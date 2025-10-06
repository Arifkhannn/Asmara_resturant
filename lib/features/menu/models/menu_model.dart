class MenuCategory {
  final int categoryId;
  final String categoryName;
  final List<MenuItem> items;

  MenuCategory({
    required this.categoryId,
    required this.categoryName,
    required this.items,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      categoryId: json['categoryId'] is String
          ? int.tryParse(json['categoryId']) ?? 0
          : json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      items: (json['items'] as List)
          .map((item) => MenuItem.fromJson(item))
          .toList(),
    );
  }
}

class MenuItem {
  final int itemId;
  final String name;
  final String description;
  final double price;
  final String image;
  final bool available;

  MenuItem({
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.available,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    double parsedPrice;

    // Handle both String ("17.00") and numeric (17.00) values safely
    if (json['price'] is String) {
      parsedPrice = double.tryParse(json['price']) ?? 0.0;
    } else if (json['price'] is num) {
      parsedPrice = (json['price'] as num).toDouble();
    } else {
      parsedPrice = 0.0; // fallback
    }

    return MenuItem(
      itemId: json['itemId'] is String
          ? int.tryParse(json['itemId']) ?? 0
          : json['itemId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsedPrice,
      image: json['image'] ?? '',
      available: json['available'] == true || json['available'] == 1,
    );
  }
}
