import 'dart:convert';
import 'package:asmara_dine/features/tables/models/table_model.dart';
import 'package:http/http.dart' as http;

class TableRepository {
  Future<List<TableModel>> fetchTables() async {
    final response = await http.get(
      Uri.parse('https://asmara-eindhoven.nl/api/tables?'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      /// ✅ API returns: [ [ {...}, {...} ] ]
      final List<dynamic> tablesJson = decoded[0];

      return tablesJson
          .map<TableModel>((json) => TableModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load tables');
    }
  }
}
