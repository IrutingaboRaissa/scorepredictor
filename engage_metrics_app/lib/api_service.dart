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
    // Use deployed API only with longer timeout
    final deployedResult = await _tryPrediction(deployedApiUrl, features);
    if (deployedResult != null) {
      return deployedResult;
    }
    
    // If deployed fails, try local as backup
    final localResult = await _tryPrediction(localApiUrl, features);
    return localResult;
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
    
    final requestBody = {'features': features};
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 30));
    
    print('Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prediction = (data['prediction'] as num).toDouble();
      print('Prediction successful: $prediction');
      return prediction;
    } else {
      print('API error: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Network error with $baseUrl: $e');
    // Return a mock prediction for demo purposes if API fails
    if (baseUrl.contains('render')) {
      final mockPrediction = _calculateMockPrediction(features);
      print('Predicted value: $mockPrediction');
      return mockPrediction;
    }
    return null;
  }
}

// Simple mock prediction for demo if API fails
double _calculateMockPrediction(List<double> features) {
  // Simple weighted average based on key factors
  final attendance = features[0];
  final previousScores = features[3];
  final hoursStudied = features[4];
  
  final prediction = (attendance * 0.3 + previousScores * 0.5 + hoursStudied * 0.8);
  return (prediction * 0.8).clamp(55.0, 101.0);
}

