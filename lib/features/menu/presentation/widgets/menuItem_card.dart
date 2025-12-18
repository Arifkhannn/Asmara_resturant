import 'package:flutter/material.dart';

class MenuItemCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MenuItemCard({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: isTablet ? 10 : 6,
        horizontal: isTablet ? 16 : 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: isTablet ? 90 : 60,
                height: isTablet ? 90 : 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                  maxLines: 3,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 18 : 16)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isTablet ? 14 : 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "€${price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (quantity > 0)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: onRemove,
                      ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: onAdd,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
