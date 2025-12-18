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
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$itemCount item(s) in order\n€${total.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onReviewTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 12,
                vertical: isTablet ? 14 : 10,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
            label: Text(
              "Review Order",
              style: TextStyle(
                  color: Colors.white, fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
