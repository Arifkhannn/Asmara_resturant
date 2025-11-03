// lib/features/menu/presentation/menu_screen.dart

import 'package:asmara_dine/features/menu/logic/event_bloc.dart';
import 'package:asmara_dine/features/menu/logic/event_menu.dart';
import 'package:asmara_dine/features/menu/logic/event_state.dart';
import 'package:asmara_dine/features/menu/models/order_model.dart';
import 'package:asmara_dine/features/menu/presentation/order_review.dart';
import 'package:asmara_dine/features/menu/presentation/widgets/category_tab.dart';
import 'package:asmara_dine/features/menu/presentation/widgets/menuItem_card.dart';
import 'package:asmara_dine/features/menu/presentation/widgets/order_summary.dart';

import 'package:asmara_dine/features/menu/presentation/widgets/search_bar.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuScreen extends StatefulWidget {
  final List<int> tableIds;
  const MenuScreen({super.key, required this.tableIds});

  /// convenience constructor used when previously passing single int
  factory MenuScreen.fromTableIds({required List<int> tableIds}) {
    return MenuScreen(tableIds: tableIds);
  }

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int selectedTab = 0;
  final searchController = TextEditingController();

  String get _appBarLabel {
    final sorted = [...widget.tableIds]..sort();
    return sorted.join('+'); // "1+2+3"
  }

  @override
  void initState() {
    super.initState();
    // Load menu from API when screen opens
    context.read<MenuBloc>().add(LoadMenu());
  }

  int get representativeId => widget.tableIds.isNotEmpty ? widget.tableIds.first : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${_appBarLabel}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: MenuSearchBar(
              controller: searchController,
              onFilterTap: () {},
            ),
          ),

          // Category Tabs (dynamic)
          BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state.categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final categoryNames = [
                "All",
                ...state.categories.map((c) => c.categoryName).toList()
              ];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CategoryTabs(
                  categories: categoryNames,
                  selectedIndex: selectedTab,
                  onTap: (i) => setState(() => selectedTab = i),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Menu Item List
          Expanded(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                if (state.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allItems = state.categories.expand((c) => c.items).toList();
                final items = selectedTab == 0
                    ? allItems
                    : state.categories[selectedTab - 1].items;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final orderItem = state.order.items.firstWhere(
                      (i) => i.itemId == item.itemId,
                      orElse: () => OrderItem(
                        itemId: item.itemId,
                        quantity: 0,
                        price: item.price,
                        name: item.name,
                        total: 0.0,
                      ),
                    );

                    final quantity = orderItem.quantity;

                    return MenuItemCard(
                      name: item.name,
                      description: item.description,
                      imageUrl: item.image,
                      price: item.price,
                      quantity: quantity,
                      onAdd: () {
                        context.read<MenuBloc>().add(AddItemToOrder(item));

                        // mark all involved tables as occupied in TableBloc
                        // (Use state.order.tableIds to get the live list from MenuBloc)
                        //table status updae commented by arif while addind the items 
                       final tableIds = state.order.tableIds;
                       /* for (final tid in tableIds) {
                          context.read<TableBloc>().add(
                            TableStatusUpdated(tableId: tid, status: "occupied"),
                          );
                        }
         */                      },
                      onRemove: () {
                        context.read<MenuBloc>().add(RemoveItemFromOrder(item));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom bar with total and review button
      bottomNavigationBar: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state.order.items.isEmpty) return const SizedBox.shrink();
          return OrderSummary(
            itemCount: state.order.items.length,
            total: state.order.grandTotal,
            onReviewTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MenuBloc>(),
                    child: const OrderReviewScreen(),
                  ),
                ),
              );
            },
          );
        },
      ),

      // Floating Button for Previous Orders
      floatingActionButton: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state.allOrders.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            backgroundColor: Colors.green,
            icon: const Icon(Icons.history, color: Colors.white),
            label: const Text("View Orders", style: TextStyle(color: Colors.white)),
            onPressed: () {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MenuBloc>(),
                    child: const OrderReviewScreen(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
