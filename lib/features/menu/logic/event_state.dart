import 'package:asmara_dine/features/menu/models/menu_model.dart';
import 'package:asmara_dine/features/menu/models/order_model.dart';

class MenuState {
  final List<MenuCategory> categories;
  final Order order;
  final bool orderPlaced;

  MenuState({
    required this.categories,
    required this.order,
    this.orderPlaced = false,
  });

  MenuState copyWith({
    List<MenuCategory>? categories,
    Order? order,
    bool? orderPlaced,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      order: order ?? this.order,
      orderPlaced: orderPlaced ?? this.orderPlaced,
    );
  }
}
