import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderMemory {
  static final OrderMemory instance = OrderMemory._internal();
  OrderMemory._internal();

  static const String _key = "order_memory_map";

  /// Local in-memory map (mirrors SharedPreferences)
  Map<int, String> tableOrderMap = {};

  /// Load from SharedPreferences on initialization
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw != null) {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      tableOrderMap = decoded.map(
        (key, value) => MapEntry(int.parse(key), value.toString()),
      );
    }
  }

  /// Save the whole map into SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tableOrderMap.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    await prefs.setString(_key, jsonEncode(encoded));
  }

  /// Save orderId for all merged tables
  Future<void> saveForTables(List<int> tableIds, String orderId) async {
    for (int id in tableIds) {
      tableOrderMap[id] = orderId;
    }
    await _saveToPrefs();
  }

  /// Get existing orderId for a merged group
  String? getForMergedTables(List<int> tableIds) {
    for (int id in tableIds) {
      if (tableOrderMap.containsKey(id)) {
        return tableOrderMap[id];
      }
    }
    return null;
  }

  /// Clear mapping when tables are freed
  Future<void> clearTables(List<int> tableIds) async {
    for (int id in tableIds) {
      tableOrderMap.remove(id);
    }
    await _saveToPrefs();
  }


  Future<void> clearAll() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_key);
  tableOrderMap.clear();
}
}
