import 'package:asmara_dine/features/menu/models/menu_model.dart';
import 'package:asmara_dine/features/menu/models/order_model.dart';

class MenuState {
  final List<MenuCategory> categories; // menu list
  final Order order; // current live order (user adding now)
  final List<Order> allOrders; // all previously placed orders for this table
  final bool orderPlaced;

  MenuState({
    required this.categories,
    required this.order,
    this.allOrders = const [],
    this.orderPlaced = false,
  });

  MenuState copyWith({
    List<MenuCategory>? categories,
    Order? order,
    List<Order>? allOrders,
    bool? orderPlaced,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      order: order ?? this.order,
      allOrders: allOrders ?? this.allOrders,
      orderPlaced: orderPlaced ?? this.orderPlaced,
    );
  }

  // 🧮 Combine all orders + current order for a grand total
  double get fullSubtotal {
    final current = order.subtotal;
    final past = allOrders.fold(0.0, (sum, o) => sum + o.subtotal);
    return current + past;
  }

  double get fullTax {
    final current = order.tax;
    final past = allOrders.fold(0.0, (sum, o) => sum + o.tax);
    return current + past;
  }

  double get fullGrandTotal {
    final current = order.grandTotal;
    final past = allOrders.fold(0.0, (sum, o) => sum + o.grandTotal);
    return current + past;
  }

  
}
class AllOrdersLoaded extends MenuState {
  final List<Order> orders;

  AllOrdersLoaded(MenuState s, this.orders)
      : super(
          categories: s.categories,
          order: s.order,
          allOrders: s.allOrders,
          orderPlaced: s.orderPlaced,
        );
}

