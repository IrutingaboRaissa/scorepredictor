import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const EngageMetricsApp());
}

// Define a custom maroon MaterialColor
const MaterialColor maroon = MaterialColor(
  0xFF800000,
  <int, Color>{
    50: Color(0xFFF2E6E6),
    100: Color(0xFFE6B3B3),
    200: Color(0xFFCC6666),
    300: Color(0xFFB31A1A),
    400: Color(0xFF990000),
    500: Color(0xFF800000),
    600: Color(0xFF660000),
    700: Color(0xFF4D0000),
    800: Color(0xFF330000),
    900: Color(0xFF1A0000),
  },
);

class EngageMetricsApp extends StatelessWidget {
  const EngageMetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EngageMetrics Predictor',
      theme: ThemeData(
        primarySwatch: maroon,
        scaffoldBackgroundColor: const Color(0xFFF8F0F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: maroon,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: maroon,
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
            borderSide: BorderSide(color: maroon, width: 2),
          ),
          border: OutlineInputBorder(),
        ),
      ),
      home: const PredictionScreen(),
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
    'Parental Involvement (1-10)',
    'Study Time (hours/week)',
    'Previous Grades (0-100)',
    'Participation (1-10)'
  ];
  final List<String> featureHints = [
    'e.g. 80',
    'e.g. 7',
    'e.g. 20',
    'e.g. 85',
    'e.g. 8'
  ];
  final List<IconData> featureIcons = [
    Icons.school,
    Icons.family_restroom,
    Icons.timer,
    Icons.grade,
    Icons.emoji_people
  ];
  final List<TextEditingController> controllers = List.generate(5, (_) => TextEditingController());
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
    final input = controllers.map((c) => double.tryParse(c.text.trim())).toList();
    if (input.contains(null)) {
      setState(() {
        _result = 'Please enter valid numbers for all fields.';
        _hasPredicted = false;
      });
      return;
    }
    final prediction = await getPrediction(input.cast<double>());
    setState(() {
      _result = prediction != null ? 'Predicted Exam Score: ${prediction.toStringAsFixed(2)}' : 'Error getting prediction.';
      _hasPredicted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EngageMetrics Predictor'),
        centerTitle: true,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: maroon.shade700),
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
                      prefixIcon: Icon(featureIcons[i], color: maroon.shade700),
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
                    backgroundColor: maroon,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 28),
                if (_result.isNotEmpty)
                  Card(
                    color: _hasPredicted ? maroon : Colors.red[100],
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
