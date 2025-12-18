import 'dart:convert';

import 'package:asmara_dine/features/menu/logic/order_id_memory.dart';
import 'package:asmara_dine/features/menu/models/order_model.dart';
import 'package:http/http.dart' as http;

import '../models/menu_model.dart';

//"https://asmara-eindhoven.nl/api"

class MenuApiService {
  final String baseUrl = "https://asmara-eindhoven.nl/api";

  Future<List<MenuCategory>> fetchMenu() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu/items'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['menu']);

        if (data['status'] == true && data['menu'] != null) {
          final List<MenuCategory> menuList = (data['menu'] as List)
              .map((e) => MenuCategory.fromJson(e))
              .toList();
          return menuList;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load menu: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching menu: $e');
      rethrow;
    }
  }

  // for getting the current orders globally--
  Future<Order?> fetchOrdersForTable(int tableId) async {
    final baseUrl = 'https://asmara-eindhoven.nl/api/tables';
    final response = await http.get(Uri.parse('$baseUrl/detail/$tableId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final orderId = data['order'] as String;
      final tableIds = (data['tableIds'] as List)
          .map((e) => (e as num).toInt())
          .toList();

      OrderMemory.instance.saveForTables(tableIds, orderId);
      print(response.body);

      return Order.fromJson(data);
      
    } else {
      throw Exception("Failed to load table orders");
    }
  }
}
