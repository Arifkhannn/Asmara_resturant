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
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          final order = state.order;
          if (order.items.isEmpty) {
            return const _EmptyOrder();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionTitle(title: "Your Items"),
              const SizedBox(height: 8),
              ...order.items.map((line) {
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
                          "Add any special instructions (e.g., less spicy, extra cheese)...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle(title: "Bill Summary"),
              const SizedBox(height: 8),
              const _TotalsCard(),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
      bottomNavigationBar: _OrderBottomBar(noteController: _noteController),
      backgroundColor: Colors.grey.shade100,
    );
  }
}

/// Item card reused
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "€${unitPrice.toStringAsFixed(2)} each",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
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

/// Totals card
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
                    fontSize: bold ? 15 : 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                    fontSize: bold ? 16 : 14,
                    color: bold ? Colors.green.shade800 : null,
                  ),
                ),
              ],
            ),
          );
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                row("Subtotal", "€${subtotal.toStringAsFixed(2)}"),
                row("Tax (10%)", "€${tax.toStringAsFixed(2)}"),
                const Divider(height: 24),
                row("Grand Total", "€${total.toStringAsFixed(2)}", bold: true),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bottom bar with Place Order flow
class _OrderBottomBar extends StatelessWidget {
  final TextEditingController noteController;
  const _OrderBottomBar({required this.noteController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final disabled = state.order.items.isEmpty && !state.orderPlaced;

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
                    'Payable: €${state.order.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: disabled
                      ? null
                      : () async {
                          if (!state.orderPlaced) {
                            // Place order
                            await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Place Order'),
                                content: Text(
                                  'Confirm order for Table ${state.order.tableId}?\n'  
                                  'Items: ${state.order.items.length}\n'
                                  'Total: €${state.order.grandTotal.toStringAsFixed(2)}\n\n'
                                  'Note: ${noteController.text.isEmpty ? "None" : noteController.text}',
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
                                    onPressed: () {
                                      context.read<MenuBloc>().add(
                                        PlaceOrder(),
                                      );
                                      context.read<TableBloc>().add(
                                        TableStatusUpdated(
                                          tableId: state.order.tableId,
                                          status: "occupied",
                                        ),
                                      );
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Order placed successfully',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Confirm',style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600),),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Complete order
                            context.read<MenuBloc>().add(CompleteOrder());
                            context.read<TableBloc>().add(
                              TableStatusUpdated(
                                tableId: state.order.tableId,
                                status: "Free",
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Order completed, Table released',
                                ),
                              ),
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TablesPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.orderPlaced
                        ? Colors.red.shade600
                        : Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    state.orderPlaced ? 'Complete Order' : 'Place Order',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Section Title
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

/// Empty Order
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
