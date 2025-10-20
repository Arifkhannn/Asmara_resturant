

import 'package:asmara_dine/features/menu/data/menu_api.dart';
import 'package:asmara_dine/features/menu/logic/event_menu.dart';
import 'package:asmara_dine/features/menu/logic/event_state.dart';
import 'package:asmara_dine/features/menu/models/order_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  static final Map<int, MenuState> _tableStates = {};
  final MenuApiService _menuApiService = MenuApiService();
  final int tableId;

  MenuBloc(this.tableId)
      : super(
          _tableStates[tableId] ??
              MenuState(
                categories: [],
                order: Order(
                  tableId: tableId,
                  items: [],
                  subtotal: 0,
                  tax: 0,
                  grandTotal: 0,
                ),
                allOrders: [],
                orderPlaced: false,
              ),
        ) {
    on<LoadMenu>(_onLoadMenu);
    on<AddItemToOrder>(_onAddItem);
    on<RemoveItemFromOrder>(_onRemoveItem);
    on<PlaceOrder>(_onPlaceOrder);
    on<CompleteOrder>(_onCompleteOrder);
  }

  // ------------------- Load Menu -------------------
  Future<void> _onLoadMenu(LoadMenu event, Emitter<MenuState> emit) async {
    try {
      final menuData = await _menuApiService.fetchMenu();
      final updatedState = state.copyWith(categories: menuData);
      _persistState(updatedState);
      emit(updatedState);
    } catch (e) {
      print('Error loading menu: $e');
    }
  }

  // ------------------- Add Item -------------------
  // inside event_bloc.dart (MenuBloc)
void _onAddItem(AddItemToOrder event, Emitter<MenuState> emit) {
  final items = [...state.order.items];
  final index = items.indexWhere((i) => i.itemId == event.item.itemId);

  if (index >= 0) {
    final updated = items[index];
    items[index] = OrderItem(
      itemId: updated.itemId,
      name: updated.name,
      quantity: updated.quantity + 1,
      price: updated.price,
      total: updated.total + updated.price,
    );
  } else {
    items.add(OrderItem(
      itemId: event.item.itemId,
      name: event.item.name,
      quantity: 1,
      price: event.item.price,
      total: event.item.price,
    ));
  }

  final subtotal = items.fold(0.0, (sum, i) => sum + i.total);
  final tax = subtotal * 0.1;
  final grandTotal = subtotal + tax;

  // NOTE: reset orderPlaced so UI shows Place Order when new items are added
  final updatedState = state.copyWith(
    order: Order(
      tableId: state.order.tableId,
      items: items,
      subtotal: subtotal,
      tax: tax,
      grandTotal: grandTotal,
    ),
    orderPlaced: false, // <--- important
  );

  _persistState(updatedState);
  emit(updatedState);
}


  // ------------------- Remove Item -------------------
  void _onRemoveItem(RemoveItemFromOrder event, Emitter<MenuState> emit) {
    final items = [...state.order.items];
    final index = items.indexWhere((i) => i.itemId == event.item.itemId);

    if (index >= 0) {
      final updated = items[index];
      if (updated.quantity > 1) {
        items[index] = OrderItem(
          itemId: updated.itemId,
          name: updated.name,
          quantity: updated.quantity - 1,
          price: updated.price,
          total: updated.total - updated.price,
        );
      } else {
        items.removeAt(index);
      }
    }

    final subtotal = items.fold(0.0, (sum, i) => sum + i.total);
    final tax = subtotal * 0.1;
    final grandTotal = subtotal + tax;

    final updatedState = state.copyWith(
      order: Order(
        tableId: state.order.tableId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        grandTotal: grandTotal,
      ),
    );

    _persistState(updatedState);
    emit(updatedState);
  }

  // ------------------- Place Order -------------------
  void _onPlaceOrder(PlaceOrder event, Emitter<MenuState> emit) {
    // Save current order batch
    final newOrderBatch = state.order.copyWith(orderId: DateTime.now().millisecondsSinceEpoch);

    // Append this batch to allOrders
    final updatedAllOrders = [...state.allOrders, newOrderBatch];

    // Reset current order for next additions
    final resetOrder = Order(
      tableId: state.order.tableId,
      items: [],
      subtotal: 0,
      tax: 0,
      grandTotal: 0,
    );

    final updatedState = state.copyWith(
      order: resetOrder,
      allOrders: updatedAllOrders,
      orderPlaced: true,
    );

    _persistState(updatedState);
    emit(updatedState);
  }

  // ------------------- Complete Order -------------------
  void _onCompleteOrder(CompleteOrder event, Emitter<MenuState> emit) {
    // At this point you could send allOrders to your POS API
    final resetState = MenuState(
      categories: state.categories,
      order: Order(
        tableId: state.order.tableId,
        items: [],
        subtotal: 0,
        tax: 0,
        grandTotal: 0,
      ),
      allOrders: [],
      orderPlaced: false,
    );

    _persistState(resetState);
    emit(resetState);
  }

  // ------------------- Helper -------------------
  void _persistState(MenuState newState) {
    _tableStates[state.order.tableId] = newState;
  }
}
