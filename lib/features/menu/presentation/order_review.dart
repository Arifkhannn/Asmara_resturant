import 'dart:convert';
import 'package:asmara_dine/core/animation/animatedPageRoute.dart';
import 'package:asmara_dine/features/menu/data/order_complete_api.dart';
import 'package:asmara_dine/features/menu/data/serve_order_api.dart';
import 'package:asmara_dine/features/menu/logic/event_bloc.dart';
import 'package:asmara_dine/features/menu/logic/event_menu.dart';
import 'package:asmara_dine/features/menu/logic/event_state.dart';
import 'package:asmara_dine/features/menu/logic/order_id_memory.dart';
import 'package:asmara_dine/features/menu/presentation/edit_previous_order_screen.dart';
import 'package:asmara_dine/features/tables/logic/table_bloc.dart';
import 'package:asmara_dine/features/tables/logic/table_event.dart';
import 'package:asmara_dine/features/tables/presentation/table_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class OrderReviewScreen extends StatefulWidget {
  final List<int> tableIds;
  OrderReviewScreen({super.key, required this.tableIds});
  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  final _noteController = TextEditingController();
  // ✅ Spiciness variable
  String? _spicyPreference;
  String? ordersId;
  bool _showPreviousOrders = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Review Order',
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   backgroundColor: Colors.green.shade700,
      //   elevation: 2,
      //   actions: [
      //     IconButton(onPressed: (){}, icon: Icon(Icons.refresh,color: Colors.white,))
      //   ],
      // ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Review Order ${widget.tableIds}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 2,
        actions: [
          BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state.allOrders.isEmpty) return const SizedBox.shrink();

              return IconButton(
                tooltip: _showPreviousOrders
                    ? 'Hide Previous Orders'
                    : 'Show Previous Orders',
                icon: Icon(
                  _showPreviousOrders
                      ? Icons.history_toggle_off
                      : Icons.history,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _showPreviousOrders = !_showPreviousOrders;
                  });
                },
              );
            },
          ),
        ],
      ),

      backgroundColor: Colors.grey.shade100,
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          final currentOrder = state.order;
          final previousOrders = state.allOrders;
          final hasPrevious = previousOrders.isNotEmpty;

          if (currentOrder.items.isEmpty && !hasPrevious) {
            return const _EmptyOrder();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ✅ Current Order Section
              if (currentOrder.items.isNotEmpty) ...[
                const _SectionTitle(title: "Current Order"),
                const SizedBox(height: 8),
                ...currentOrder.items.map((line) {
                  final menuItem = state.categories
                      .expand((c) => c.items)
                      .firstWhere((m) => m.itemId == line.itemId);
                  return _OrderItemCard(
                    title: line.name,
                    unitPrice: line.price,
                    quantity: line.quantity,
                    total: line.total,
                    imageUrl: menuItem.image,
                    onAdd: () =>
                        context.read<MenuBloc>().add(AddItemToOrder(menuItem)),
                    onRemove: () => context.read<MenuBloc>().add(
                      RemoveItemFromOrder(menuItem),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // ✅ Special Note
                const _SectionTitle(title: "Special Note"),
                const SizedBox(height: 8),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            "Add any special instructions (e.g., less spicy)...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ✅ Spicy Preference Section
                Row(
                  children: const [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Select Spiciness Level",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        _buildSpicyOption(
                          emoji: "🌿",
                          title: "Less Spicy",
                          description: "Mild & flavorful",
                          value: "Less Spicy",
                        ),
                        _buildSpicyOption(
                          emoji: "❄️",
                          title: "No Spicy",
                          description: "Completely non-spicy",
                          value: "No Spicy",
                        ),
                        _buildSpicyOption(
                          emoji: "🌶️",
                          title: "More Spicy",
                          description: "Hot & fiery taste",
                          value: "More Spicy",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionTitle(title: "Current Bill Summary"),
                const SizedBox(height: 8),
                const _TotalsCard(),
                const SizedBox(height: 24),
              ],
              // ✅ Previous Orders
              if (hasPrevious && _showPreviousOrders) ...[
                const _SectionTitle(title: "Previous Orders"),
                const SizedBox(height: 8),

                ...previousOrders.map(
                  (order) => BlocBuilder<MenuBloc, MenuState>(
                    builder: (context, state) {
                      // ✅ This is needed for merged table OrderID
                      final tableIds = state.order.tableIds;
                      final mergedOrderId = OrderMemory.instance
                          .getForMergedTables(tableIds);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              bool isServed = order.isServed ?? false;

                              // ✅ API CALL

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ✅ TITLE + CHECKBOX
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Order #${order.orderId ?? '-'}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      // before placing the edit button functionallity
                                      // Row(
                                      //   children: [
                                      //     const Text(
                                      //       "Served",
                                      //       style: TextStyle(
                                      //         fontSize: 14,
                                      //         fontWeight: FontWeight.w700,
                                      //       ),
                                      //     ),
                                      //     Checkbox(
                                      //       value: isServed,
                                      //       fillColor:
                                      //           MaterialStateProperty.all(
                                      //             Colors.white,
                                      //           ),
                                      //       checkColor: Colors.green,
                                      //       activeColor: Colors.white,

                                      //       onChanged: isServed
                                      //           ? null // ✅ Cannot untick
                                      //           : (value) async {
                                      //               setState(
                                      //                 () => isServed = true,
                                      //               );
                                      //               order.isServed = true;

                                      //               // ✅ Call API using merged Order ID
                                      //               await markOrderServed(
                                      //                 mergedOrderId.toString(),
                                      //               );
                                      //             },
                                      //     ),
                                      //   ],
                                      // ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 32,
                                            width: 60,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                elevation: 1,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  AnimatedPageRoute(
                                                    page:
                                                        EditPreviousOrderScreen(
                                                          tableIds: tableIds,
                                                          order: order,
                                                          mergedOrderId:
                                                              mergedOrderId!,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'EDIT',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),

                                          const Text(
                                            "Served",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Checkbox(
                                            value: isServed,
                                            onChanged: isServed
                                                ? null
                                                : (value) async {
                                                    setState(
                                                      () => isServed = true,
                                                    );
                                                    order.isServed = true;
                                                    await markOrderServed(
                                                      mergedOrderId.toString(),
                                                    );
                                                  },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // ✅ ITEMS LIST
                                  ...order.items.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "x${item.quantity}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "€${item.total.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              SizedBox(height: 100),
            ],
          );
        },
      ),
      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          final hasPrevious = state.allOrders.isNotEmpty;
          final hasCurrent = state.order.items.isNotEmpty;
          if (!hasCurrent && !hasPrevious) return const SizedBox.shrink();

          final bool isPlacingNew = hasCurrent && !state.orderPlaced;
          final bool isCompleting = hasPrevious && !isPlacingNew;

          return _OrderBottomBar(
            noteController: _noteController,
            showPlaceOrder: isPlacingNew,
            showCompleteOrder: isCompleting,
            spicyPreference: _spicyPreference,
          );
        },
      ),
      // ✅ Complete Order FAB
      floatingActionButton: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state.allOrders.isEmpty) return const SizedBox.shrink();
          final mergedTableIds = state.order.tableIds;
          return FloatingActionButton.extended(
            backgroundColor: Colors.red.shade600,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: const Text(
              "Complete Order",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final updatedId = OrderMemory.instance.getForMergedTables(
                mergedTableIds,
              );
              debugPrint(
                "🔥 After Saving → Stored OrderID for tables $mergedTableIds = $updatedId",
              );

              OrderCompleteApi api = OrderCompleteApi();
              final statusVal = await api.paymentStatus(updatedId ?? '000');
              if (statusVal == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Orders completed, tables ${mergedTableIds.join(", ")} released',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );

                context.read<MenuBloc>().add(CompleteOrder());
                // ✅ Clear merged tables
                context.read<TableBloc>().add(
                  ClearMergedTables(tableIds: mergedTableIds),
                );
                // ✅ Mark tables free
                for (final tid in mergedTableIds) {
                  context.read<TableBloc>().add(
                    TableStatusUpdated(tableId: tid, status: "free"),
                  );
                }

                // clearing teh orderid---
                OrderMemory.instance.clearTables(mergedTableIds);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TablesPage()),
                );
              }
              if (statusVal == 400) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                    title: Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Payment not made yet!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'The order payment has not been completed yet.\nPlease complete the payment before releasing the table.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    actionsPadding: const EdgeInsets.only(
                      bottom: 12,
                      right: 10,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              // showDialog(
              //   context: context,
              //   builder: (_) => AlertDialog(
              //     title: const Text('Complete Order'),
              //     content: Text(
              //       'Complete all placed orders for Tables ${mergedTableIds.join(", ")} and release them?',
              //     ),
              //     actions: [
              //       TextButton(
              //         onPressed: () => Navigator.pop(context),
              //         child: const Text(
              //           'Cancel',
              //           style: TextStyle(color: Colors.red),
              //         ),
              //       ),
              //       ElevatedButton(
              //         onPressed: () {
              //           context.read<MenuBloc>().add(CompleteOrder());
              //           // ✅ Clear merged tables
              //           context.read<TableBloc>().add(
              //             ClearMergedTables(tableIds: mergedTableIds),
              //           );
              //           // ✅ Mark tables free
              //           for (final tid in mergedTableIds) {
              //             context.read<TableBloc>().add(
              //               TableStatusUpdated(tableId: tid, status: "free"),
              //             );
              //           }

              //           // clearing teh orderid---
              //           OrderMemory.instance.clearTables(mergedTableIds);

              //           Navigator.pop(context);
              //           ScaffoldMessenger.of(context).showSnackBar(
              //             SnackBar(
              //               content: Text(
              //                 'Orders completed, tables ${mergedTableIds.join(", ")} released',
              //               ),
              //             ),
              //           );
              //           Navigator.popUntil(context, (route) => route.isFirst);
              //         },
              //         child: const Text('Confirm'),
              //       ),
              //     ],
              //   ),
              // );
            },
          );
        },
      ),
    );
  }

  // ✅ Spicy Option radio button builder
  Widget _buildSpicyOption({
    required String emoji,
    required String title,
    required String description,
    required String value,
  }) {
    return RadioListTile<String>(
      activeColor: Colors.green.shade700,
      title: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      value: value,
      groupValue: _spicyPreference,
      onChanged: (val) {
        setState(() => _spicyPreference = val);
      },
    );
  }
}

// ✅ Order Item Card
class _OrderItemCard extends StatelessWidget {
  final String title;
  final double unitPrice;
  final int quantity;
  final double total;
  final String imageUrl;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _OrderItemCard({
    required this.title,
    required this.unitPrice,
    required this.quantity,
    required this.total,
    required this.imageUrl,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                height: 65,
                width: 65,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "€${unitPrice.toStringAsFixed(2)} each",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: onRemove,
                        color: Colors.redAccent,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: onAdd,
                        color: Colors.green,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Spacer(),
                      Text(
                        "€${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Totals Card
class _TotalsCard extends StatelessWidget {
  const _TotalsCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      buildWhen: (p, n) => p.order != n.order,
      builder: (context, state) {
        final subtotal = state.order.subtotal;
        final tax = state.order.tax;
        final total = state.order.grandTotal;

        Widget row(String label, String value, {bool bold = false}) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                    color: bold ? Colors.green.shade800 : null,
                  ),
                ),
              ],
            ),
          );
        }

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                row("Subtotal", "€${subtotal.toStringAsFixed(2)}"),
                row("Tax (10%)", "€${tax.toStringAsFixed(2)}"),
                const Divider(height: 20),
                row("Grand Total", "€${total.toStringAsFixed(2)}", bold: true),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ✅ Bottom Navigation Bar
class _OrderBottomBar extends StatelessWidget {
  final TextEditingController noteController;
  final bool showPlaceOrder;
  final bool showCompleteOrder;
  final String? spicyPreference;

  const _OrderBottomBar({
    required this.noteController,
    required this.showPlaceOrder,
    required this.showCompleteOrder,
    required this.spicyPreference,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12 + 8),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Payable: €${state.fullGrandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                // ✅ Place Order button
                if (showPlaceOrder)
                  ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Place Order'),
                          content: Text(
                            'Confirm new order?\n'
                            'Items: ${state.order.items.length}\n'
                            'Total: €${state.order.grandTotal.toStringAsFixed(2)}\n\n'
                            'Note: ${noteController.text.isEmpty ? "None" : noteController.text}\n'
                            'Taste: ${spicyPreference ?? "None"}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final tableIds = state.order.tableIds;
                                final orderItems = state.order.items
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
                                  "note": noteController.text,
                                  "tastes": spicyPreference,
                                  "order": OrderMemory.instance
                                      .getForMergedTables(tableIds),
                                });
                                try {
                                  final response = await http.post(
                                    Uri.parse(
                                      //'https://asmara-eindhoven.nl/api/orders/create'
                                      'https://asmara-eindhoven.nl/api/orders/create',
                                    ),
                                    headers: {
                                      'Accept': 'application/json',
                                      'Content-Type': 'application/json',
                                    },
                                    body: body,
                                  );
                                  if (response.statusCode == 200) {
                                    context.read<MenuBloc>().add(PlaceOrder());
                                    for (final tid in tableIds) {
                                      context.read<TableBloc>().add(
                                        TableStatusUpdated(
                                          tableId: tid,
                                          status: "occupied",
                                        ),
                                      );
                                    }
                                    debugPrint(
                                      '----------------------------------------------------${response.body}',
                                    );

                                    // extracting the orderid from the api response of the create order
                                    final data = jsonDecode(response.body);
                                    final orderid = data["order"];

                                    final existingId = OrderMemory.instance
                                        .getForMergedTables(tableIds);
                                    debugPrint(
                                      "🔥 Before Saving → Existing OrderID for tables $tableIds = $existingId",
                                    );

                                    if (existingId == null) {
                                      debugPrint(
                                        "✅ No orderId found, saving new orderId → $orderid",
                                      );
                                      OrderMemory.instance.saveForTables(
                                        tableIds,
                                        orderid,
                                      );
                                    }

                                    // 🔥 Re-fetch to confirm save
                                    final updatedId = OrderMemory.instance
                                        .getForMergedTables(tableIds);
                                    debugPrint(
                                      "🔥 After Saving → Stored OrderID for tables $tableIds = $updatedId",
                                    );

                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Order placed successfully 🎉',
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '😢 API error. Please try again.',
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '😢 Something went wrong. Try again.',
                                      ),
                                      duration: Duration(seconds: 5),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Place Order'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ✅ Section Title widget
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

// ✅ Empty Order screen
class _EmptyOrder extends StatelessWidget {
  const _EmptyOrder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 64,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 12),
            Text(
              'No items in the order',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Add Items'),
            ),
          ],
        ),
      ),
    );
  }
}
