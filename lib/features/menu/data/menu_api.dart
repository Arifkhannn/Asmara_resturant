import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/menu_model.dart';

class MenuApiService {
  final String baseUrl = "https://asmara.dftech.in/api"; // replace if needed

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
}
