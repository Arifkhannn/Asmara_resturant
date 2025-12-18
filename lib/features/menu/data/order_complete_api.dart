import 'package:http/http.dart' as http;

class OrderCompleteApi {
  final String baseUrl = "https://asmara-eindhoven.nl/api";

  Future<int> paymentStatus(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/complete-order/$id'),
      headers: {'Accept': 'application/json'},
    );
    print(response.statusCode);
    print(response.body);
    return response.statusCode;
  }
}
