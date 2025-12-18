import 'dart:convert';
import 'package:http/http.dart' as http;

//"https://asmara-eindhoven.nl/api/orders/served-order/$orderId";

Future<void> markOrderServed(String orderId) async {
  final String url =
      "https://asmara-eindhoven.nl/api/orders/served-order/$orderId";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        // Add Authorization if required:
        // "Authorization": "Bearer YOUR_TOKEN",
      },
      
    );

    if (response.statusCode == 200) {
      print("✅ Order Served Successfully → $orderId");
    } else {
      print("❌ Failed to serve order. Code: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  } catch (e) {
    print("🔥 Error calling served-order API: $e");
  }
}
