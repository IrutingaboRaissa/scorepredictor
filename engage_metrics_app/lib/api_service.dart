import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Save a prediction record to local history
Future<void> savePredictionHistory(List<double> inputs, double prediction) async {
  final prefs = await SharedPreferences.getInstance();
  final historyJson = prefs.getStringList('prediction_history') ?? [];
  final record = {
    'inputs': inputs,
    'prediction': prediction,
    'timestamp': DateTime.now().toIso8601String(),
  };
  historyJson.add(jsonEncode(record));
  await prefs.setStringList('prediction_history', historyJson);
}

// Load all prediction records from local history
Future<List<Map<String, dynamic>>> loadPredictionHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final historyJson = prefs.getStringList('prediction_history') ?? [];
  return historyJson.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
}

//  API URLs
const String localApiUrl = 'http://127.0.0.1:8000';
const String deployedApiUrl = 'https://scorepredictor-b45k.onrender.com';


Future<String> getApiBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getString('api_base_url') ?? localApiUrl;
}

// Set the API base URL
Future<void> setApiBaseUrl(String url) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('api_base_url', url);
}

Future<double?> getPrediction(List<double> features) async {
  try {
    // Try user-configured API URL first
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString('api_base_url');
    if (customUrl != null) {
      final customResult = await _tryPrediction(customUrl, features);
      if (customResult != null) {
        return customResult;
      }
      print('Custom API failed, trying deployed API...');
    }

    // Fallback to deployed API
    final deployedResult = await _tryPrediction(deployedApiUrl, features);
    if (deployedResult != null) {
      return deployedResult;
    }
    print('Deployed API failed, trying local API...');

    // Fallback to local API
    final localResult = await _tryPrediction(localApiUrl, features);
    if (localResult != null) {
      return localResult;
    }

    return null;
  } catch (e) {
    print('Prediction error: $e');
    return null;
  }
}

Future<double?> _tryPrediction(String baseUrl, List<double> features) async {
  final url = Uri.parse('$baseUrl/predict');
  
  try {
    print('Attempting prediction with URL: $url');
    print('Sending features: $features');
    
    // Use features array format for deployed API
    final requestBody = {
      'features': features
    };
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 10));
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prediction = data['prediction'] as double;
      print('Prediction successful: $prediction');
      return prediction;
    } else {
      print('API error: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('Network error with $baseUrl: $e');
    return null;
  }
}

