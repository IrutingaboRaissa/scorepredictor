// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<double?> getPrediction(List<double> features) async {
  final url = Uri.parse('http://127.0.0.1:8000/predict');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'features': features}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['prediction'] as double;
  } else {
    // Error handling: log or handle error as needed in production
    return null;
  }
}

