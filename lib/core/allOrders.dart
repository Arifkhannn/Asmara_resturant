import 'package:asmara_dine/features/menu/logic/event_bloc.dart';
import 'package:asmara_dine/features/menu/logic/event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllOrdersScreen extends StatelessWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Active Orders")),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is AllOrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text("No active orders."));
            }

            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("Order #${order.orderId}"),
                    subtitle: Text(
                      "Table(s): ${order.tableIds.join(', ')}\n"
                      "Items Count: ${order.items.length}\n"
                      "Item Names: ${order.items.map((e) => e.name).join(', ')}"
                      
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
