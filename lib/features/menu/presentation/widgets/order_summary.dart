import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onReviewTap;

  const OrderSummary({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$itemCount item(s) in order\n\€${total.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          ElevatedButton.icon(
            onPressed: onReviewTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
            label: const Text(
              "Review Order",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
