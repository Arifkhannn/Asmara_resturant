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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
  padding: const EdgeInsets.all(12),
  child: Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text("\€${price.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (quantity > 0)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onRemove,
                ),
              Text(quantity.toString()),
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
