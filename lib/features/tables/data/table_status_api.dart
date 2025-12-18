import 'dart:convert';
import 'package:asmara_dine/features/tables/models/table_model.dart';
import 'package:http/http.dart' as http;
//'https://asmara-eindhoven.nl/api/tables?'

class TableRepository {
  Future<List<TableModel>> fetchTables() async {
    final response = await http.get(
      Uri.parse('https://asmara-eindhoven.nl/api/tables?'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);

      return data.map((e) => TableModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tables');
    }
  }
}
