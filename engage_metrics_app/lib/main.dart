import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import 'welcome_page.dart';
import 'history_page.dart';


void main() {
  runApp(const EngageMetricsApp());
}

// Define custom colors for ML/education theme - warm, energetic palette
const MaterialColor primaryBrown = Colors.brown;
const Color accentAmber = Color(0xFFFFC107);  // Amber
const Color mlCrimson = Color(0xFFD32F2F);    // Deep red
const Color dataOrange = Color(0xFFFF5722);   // Deep orange
const Color backgroundCream = Color(0xFFFFF8E1); // Light cream

class EngageMetricsApp extends StatelessWidget {
  const EngageMetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EngageMetrics Predictor',
      theme: ThemeData(
        primarySwatch: primaryBrown,
        scaffoldBackgroundColor: backgroundCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: mlCrimson,
          foregroundColor: Colors.white,
          elevation: 3,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: dataOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentAmber, width: 2),
          ),
          border: OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final List<String> featureNames = [
    'Attendance (%)',
    'Parental Engagement (Low=1, Medium=2, High=3)',
    'Sleep Hours',
    'Previous Grades (0-100)',
    'Hours Studied',
    'Tutoring Sessions',
    'Physical Activity (hours/week)'
  ];
  final List<String> featureHints = [
    'e.g. 80',
    'Select 1, 2, or 3',
    'e.g. 7',
    'e.g. 85',
    'e.g. 20',
    'e.g. 2',
    'e.g. 5 (hours/week)'
  ];
  final List<IconData> featureIcons = [
    Icons.school,
    Icons.family_restroom,
    Icons.bedtime,
    Icons.grade,
    Icons.timer,
    Icons.school,
    Icons.directions_run
  ];
  final List<TextEditingController> controllers = List.generate(7, (_) => TextEditingController());
  String _result = '';
  bool _hasPredicted = false;

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _predict() async {
    // Validate inputs
    final input = controllers.map((c) => double.tryParse(c.text.trim())).toList();
    if (input.contains(null)) {
      setState(() {
        _result = 'Please enter valid numbers for all fields.';
        _hasPredicted = false;
      });
      return;
    }
    
    // Check for reasonable ranges
    // We've already checked for nulls, but we need to cast to non-nullable for Dart's null safety
    final List<double> validInputs = input.whereType<double>().toList();
    
    if (validInputs.length != input.length) {
      setState(() {
        _result = 'Please enter valid numbers for all fields.';
        _hasPredicted = false;
      });
      return;
    }
    
    if (validInputs[0] < 0 || validInputs[0] > 100) { // Attendance
      setState(() {
        _result = 'Attendance must be between 0 and 100%.';
        _hasPredicted = false;
      });
      return;
    }
    
    if (validInputs[1] < 1 || validInputs[1] > 3) { // Parental Engagement
      setState(() {
        _result = 'Parental Engagement must be 1, 2, or 3.';
        _hasPredicted = false;
      });
      return;
    }
    
    // Show loading indicator
    setState(() {
      _result = 'Calculating prediction...';
      _hasPredicted = false;
    });
    
    try {
      print('Sending prediction request with inputs: $validInputs');
      final prediction = await getPrediction(validInputs);
      
      if (prediction != null) {
        // Save prediction to history
        _savePredictionToHistory(validInputs, prediction);
        
        setState(() {
          _result = 'Predicted Exam Score: ${prediction.toStringAsFixed(2)}';
          _hasPredicted = true;
        });
        print('Prediction successful: $prediction');
      } else {
        setState(() {
          _result = 'Error connecting to API. Please check your internet connection and try again.';
          _hasPredicted = false;
        });
        print('Prediction failed: null result returned');
      }
    } catch (e) {
      print('Exception during prediction: $e');
      setState(() {
        _result = 'Error: ${e.toString()}';
        _hasPredicted = false;
      });
    }
  }
  
  Future<void> _savePredictionToHistory(List<double> inputs, double prediction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('prediction_history') ?? [];
      
      final record = PredictionRecord(
        inputs: inputs,
        prediction: prediction,
        timestamp: DateTime.now(),
      );
      
      historyJson.add(jsonEncode(record.toJson()));
      await prefs.setStringList('prediction_history', historyJson);
    } catch (e) {
      print('Error saving prediction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EngageMetrics Predictor'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Enter the following features:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: mlCrimson),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...List.generate(featureNames.length, (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: controllers[i],
                    decoration: InputDecoration(
                      labelText: featureNames[i],
                      hintText: featureHints[i],
                      prefixIcon: Icon(featureIcons[i], color: accentAmber),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                )),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _predict,
                  icon: const Icon(Icons.analytics, color: Colors.white),
                  label: const Text('Predict'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dataOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                if (_result.isNotEmpty)
                  Card(
                    color: _hasPredicted ? mlCrimson : Colors.red[300],
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Text(
                        _result,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
