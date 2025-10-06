import 'package:asmara_dine/features/menu/models/menu_model.dart';

abstract class MenuEvent {}

class LoadMenu extends MenuEvent {}

class AddItemToOrder extends MenuEvent {
  final MenuItem item;
  AddItemToOrder(this.item);
}

class RemoveItemFromOrder extends MenuEvent {
  final MenuItem item;
  RemoveItemFromOrder(this.item);
}

class PlaceOrder extends MenuEvent {}

class CompleteOrder extends MenuEvent {}
