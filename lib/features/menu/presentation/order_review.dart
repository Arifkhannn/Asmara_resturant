import 'package:asmara_dine/features/menu/logic/event_bloc.dart';
import 'package:asmara_dine/features/menu/logic/event_menu.dart';
import 'package:asmara_dine/features/menu/logic/event_state.dart';
import 'package:asmara_dine/features/tables/logic/table_bloc.dart';
import 'package:asmara_dine/features/tables/logic/table_event.dart';
import 'package:asmara_dine/features/tables/presentation/table_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 2,
      ),
      backgroundColor: Colors.grey.shade100,

      // BODY same as before
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
                    onRemove: () =>
                        context.read<MenuBloc>().add(RemoveItemFromOrder(menuItem)),
                  );
                }),
                const SizedBox(height: 16),
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
                        hintText: "Add any special instructions (e.g., less spicy)...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const _SectionTitle(title: "Current Bill Summary"),
                const SizedBox(height: 8),
                const _TotalsCard(),
                const SizedBox(height: 24),
              ],

              if (hasPrevious) ...[
                const _SectionTitle(title: "Previous Orders"),
                const SizedBox(height: 8),
                ...previousOrders.map((order) => Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Order #${order.orderId ?? '-'}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 8),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(item.name,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ),
                                      Text("x${item.quantity}",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 13)),
                                      const SizedBox(width: 6),
                                      Text("€${item.total.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    )),
              ],
              const SizedBox(height: 100),
            ],
          );
        },
      ),

      // BOTTOM BAR (unchanged, still shows Place Order when hasCurrent && !orderPlaced)
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
          );
        },
      ),

      // ----------------- NEW: floatingActionButton -----------------
      // Show a prominent FAB to "Complete Order" whenever there are previous orders.
      // This keeps it separate from bottom bar Place Order flow.
      floatingActionButton: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          // If there are no previous orders, don't show the FAB.
          if (state.allOrders.isEmpty) return const SizedBox.shrink();

          // Show a red "Complete Order" FAB that completes all placed orders and frees table.
          return FloatingActionButton.extended(
            backgroundColor: Colors.red.shade600,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: const Text("Complete Order", style: TextStyle(color: Colors.white)),
            onPressed: () {
              // Confirm before completing
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Complete Order'),
                  content: Text(
                    'Complete all placed orders for Table ${state.order.tableId} and release the table?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Complete orders and free table
                        context.read<MenuBloc>().add(CompleteOrder());
                        context.read<TableBloc>().add(TableStatusUpdated(
                          tableId: state.order.tableId,
                          status: "Free",
                        ));

                        Navigator.pop(context); // close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Orders completed, table released')),
                        );

                        // Navigate back to tables screen
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const TablesPage()),
                          (route) => false,
                        );
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ===== rest of widgets unchanged (copy your existing widgets) =====

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
                  Text(title,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text("€${unitPrice.toStringAsFixed(2)} each",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: onRemove,
                        color: Colors.redAccent,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(quantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: onAdd,
                        color: Colors.green,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Spacer(),
                      Text("€${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                Text(label,
                    style: TextStyle(
                        fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
                Text(value,
                    style: TextStyle(
                        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                        color: bold ? Colors.green.shade800 : null)),
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

class _OrderBottomBar extends StatelessWidget {
  final TextEditingController noteController;
  final bool showPlaceOrder;
  final bool showCompleteOrder;

  const _OrderBottomBar({
    required this.noteController,
    required this.showPlaceOrder,
    required this.showCompleteOrder,
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
                    style:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
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
                            'Note: ${noteController.text.isEmpty ? "None" : noteController.text}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<MenuBloc>().add(PlaceOrder());
                                context.read<TableBloc>().add(
                                      TableStatusUpdated(
                                          tableId: state.order.tableId,
                                          status: "occupied"),
                                    );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order placed successfully'),
                                  ),
                                );
                              },
                              child: const Text('Confirm',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Place Order'),
                  ),

               /* if (showCompleteOrder)
                  ElevatedButton(
                    onPressed: () {
                      context.read<MenuBloc>().add(CompleteOrder());
                      context.read<TableBloc>().add(TableStatusUpdated(
                        tableId: state.order.tableId,
                        status: "Free",
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order completed, Table released'),
                        ),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const TablesPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Complete Order'),
                  ),*/
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
  }
}

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
            Icon(Icons.shopping_basket_outlined,
                size: 64, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text('No items in the order',
                style: TextStyle(color: Colors.grey.shade600)),
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
