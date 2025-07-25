
import 'package:flutter/material.dart';
import 'api_service.dart';

// Hunt Green theme only
const Color huntGreen = Color(0xFF355E3B);

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  // List of controllers for each input field
  final List<TextEditingController> _controllers = List.generate(7, (_) => TextEditingController());
  String? _predictionResult;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _featureNames = [
    'Attendance (%)',
    'Parental Engagement (1=Low, 2=Medium, 3=High)',
    'Sleep Hours',
    'Previous Grades',
    'Hours Studied',
    'Tutoring Sessions',
    'Physical Activity',
  ];

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _predict() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Validate inputs
      List<double> inputs = [];
      for (int i = 0; i < _controllers.length; i++) {
        final text = _controllers[i].text.trim();
        if (text.isEmpty) {
          throw Exception('Please enter ${_featureNames[i]}');
        }
        final value = double.tryParse(text);
        if (value == null) {
          throw Exception('Invalid value for ${_featureNames[i]}');
        }
        inputs.add(value);
      }
      // Call the backend API for prediction
      final prediction = await getPrediction(inputs);
      if (prediction != null) {
        await savePredictionHistory(inputs, prediction);
        setState(() {
          _predictionResult = 'Predicted Score: ${prediction.toStringAsFixed(2)}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Prediction failed. Please check your API connection.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Prediction'),
        centerTitle: true,
        backgroundColor: huntGreen,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Student Performance Factors:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: huntGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ...List.generate(_featureNames.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _controllers[i],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _featureNames[i],
                    labelStyle: TextStyle(color: huntGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: huntGreen, width: 2),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _predict,
                icon: const Icon(Icons.analytics),
                label: const Text('Predict'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: huntGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                Center(child: CircularProgressIndicator(color: huntGreen)),
              if (_predictionResult != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: huntGreen.withOpacity(0.5)),
                  ),
                  child: Text(
                    _predictionResult!,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: huntGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
