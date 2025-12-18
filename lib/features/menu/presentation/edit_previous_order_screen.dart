import 'dart:convert';

import 'package:asmara_dine/features/menu/models/edit_order_model.dart';
import 'package:asmara_dine/features/menu/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditPreviousOrderScreen extends StatefulWidget {
  final List<int> tableIds;
  final Order order;
  final String mergedOrderId;

  const EditPreviousOrderScreen({
    super.key,
    required this.order,
    required this.mergedOrderId,
    required this.tableIds,
  });

  @override
  State<EditPreviousOrderScreen> createState() =>
      _EditPreviousOrderScreenState();
}

class _EditPreviousOrderScreenState extends State<EditPreviousOrderScreen> {
  late List<EditableOrderItem> items;

  @override
  void initState() {
    super.initState();
    // Initialize mutable list from the passed order
    items = widget.order.items.map((e) {
      return EditableOrderItem(
        itemId: e.itemId,
        name: e.name,
        quantity: e.quantity,
        price: e.total / (e.quantity == 0 ? 1 : e.quantity), // Prevent div by 0
      );
    }).toList();
  }

  double get total => items.fold(0, (sum, i) => sum + (i.price * i.quantity));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for modern feel
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Previous Order",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text("No items in this order"))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _buildModernItemTile(items[i]),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildModernItemTile(EditableOrderItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Item Name and Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "€${item.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Modern Counter
            Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildIconButton(
                    icon: Icons.remove,
                    onTap: () {
                      setState(() {
                        if (item.quantity > 1) {
                          item.quantity--;
                        } else {
                          items.remove(item);
                        }
                      });
                    },
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      item.quantity.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  _buildIconButton(
                    icon: Icons.add,
                    onTap: () {
                      setState(() => item.quantity++);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 20, color: Colors.green[700]),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Price Section
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "€${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: _submitPatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                "SAVE CHANGES",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPatch() async {
    final tableIds = widget.tableIds;
    final orderItems = items
        .map(
          (item) => {
            "id": item.itemId,
            "qty": item.quantity,
            "itemName": item.name,
          },
        )
        .toList();
    final body = jsonEncode({
      "tableIds": tableIds,
      "orderItems": orderItems,

      "order": widget.mergedOrderId,
    });
    print(' body of teh edit order payload----${body}');
    try {
      final response = await http.post(
        Uri.parse(
          //'https://asmara-eindhoven.nl/api/orders/create'
          'https://asmara-eindhoven.nl/api/orders/update-order',
        ),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      debugPrint(response.body);
    } catch (e) {
      debugPrint(e.toString());
    }
    // await patchPreviousOrder(widget.mergedOrderId, payload);

    if (mounted) Navigator.pop(context, true);
  }
}
