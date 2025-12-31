import 'package:asmara_dine/core/animation/animatedPageRoute.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuScreen extends StatefulWidget {
  final List<int> tableIds;
  final List<String> tableName;
  const MenuScreen({super.key, required this.tableIds, required this.tableName});

  factory MenuScreen.fromTableIds({required List<int> tableIds, required List<String> tableName}) {
    return MenuScreen(tableIds: tableIds, tableName: tableName,);
  }

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int selectedTab = 0;
  final searchController = TextEditingController();
  String searchText = "";

  String get _appBarLabel {
    final sorted = [...widget.tableName]..sort();
    return sorted.join('+');
  }

  @override
  void initState() {
    super.initState();

    context.read<MenuBloc>().add(
          LoadExistingOrders(widget.tableIds.first),
        );
    context.read<MenuBloc>().add(LoadMenu());

    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.trim().toLowerCase();
      });
    });
  }

  /// ✅ Pull-to-refresh handler
  Future<void> _onRefresh() async {
    HapticFeedback.heavyImpact();
    context.read<MenuBloc>().add(
          LoadExistingOrders(widget.tableIds.first),
        );
    context.read<MenuBloc>().add(LoadMenu());

    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 44,
        backgroundColor: Colors.green,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Table $_appBarLabel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            splashRadius: 22,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              context.read<MenuBloc>().add(
                    LoadExistingOrders(widget.tableIds.first),
                  );
            },
          ),
          const SizedBox(width: 6),
        ],
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

          BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state.categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }

              final categoryNames = [
                "All",
                ...state.categories.map((c) => c.categoryName).toList(),
              ];

              return Padding(
                padding: const EdgeInsets.all(8),
                child: CategoryTabs(
                  categories: categoryNames,
                  selectedIndex: selectedTab,
                  onTap: (i) => setState(() => selectedTab = i),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                if (state.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allItems =
                    state.categories.expand((c) => c.items).toList();

                List items = selectedTab == 0
                    ? allItems
                    : state.categories[selectedTab - 1].items;

                if (searchText.isNotEmpty) {
                  items = items.where((item) {
                    final name = item.name.toLowerCase();
                    final desc = item.description?.toLowerCase() ?? "";
                    return name.contains(searchText) ||
                        desc.contains(searchText);
                  }).toList();
                }

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching items found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // ✅ TABLET
                if (isTablet) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
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

                        return MenuItemCard(
                          name: item.name,
                          description: item.description,
                          imageUrl: item.image,
                          price: item.price,
                          quantity: orderItem.quantity,
                          onAdd: () {
                            context
                                .read<MenuBloc>()
                                .add(AddItemToOrder(item));
                          },
                          onRemove: () {
                            context
                                .read<MenuBloc>()
                                .add(RemoveItemFromOrder(item));
                          },
                        );
                      },
                    ),
                  );
                }

                // ✅ MOBILE
                return RefreshIndicator(
                  color: Colors.green,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
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

                      return MenuItemCard(
                        name: item.name,
                        description: item.description,
                        imageUrl: item.image,
                        price: item.price,
                        quantity: orderItem.quantity,
                        onAdd: () {
                          HapticFeedback.mediumImpact();
                          context
                              .read<MenuBloc>()
                              .add(AddItemToOrder(item));
                        },
                        onRemove: () {
                          HapticFeedback.heavyImpact();
                          context
                              .read<MenuBloc>()
                              .add(RemoveItemFromOrder(item));
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state.order.items.isEmpty) return const SizedBox.shrink();

          return OrderSummary(
            itemCount: state.order.items.length,
            total: state.order.grandTotal,
            onReviewTap: () {
              HapticFeedback.vibrate();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MenuBloc>(),
                    child:  OrderReviewScreen(tableIds: widget.tableIds),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state.allOrders.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            backgroundColor: Colors.green,
            icon: const Icon(Icons.history, color: Colors.white),
            label: const Text(
              "View Orders",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              
              Navigator.of(context).push(
  AnimatedPageRoute(
    page: BlocProvider.value(
      value: context.read<MenuBloc>(),
      child: OrderReviewScreen(tableIds: widget.tableIds),
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
