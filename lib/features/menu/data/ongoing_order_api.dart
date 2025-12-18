import 'dart:convert';

import 'package:asmara_dine/features/menu/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher-js/core/transports/url_schemes.dart';

Future<List<Order>> fetchOrdersForTable(int tableId) async {
  final baseUrl = 'https://asmara-eindhoven.nl/api/tables';
  final response = await http.get(Uri.parse('$baseUrl/detail/$tableId'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return (data as List).map((e) => Order.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load table orders");
  }
}
