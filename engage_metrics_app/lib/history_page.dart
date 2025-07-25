import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'settings_page.dart';

// Color constants for UI
// Hunt Green theme only
const Color huntGreen = Color(0xFF355E3B);
const Color backgroundWhite = Colors.white;

class PredictionRecord {
  final List<double> inputs;
  final double prediction;
  final DateTime timestamp;

  PredictionRecord({
    required this.inputs,
    required this.prediction,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'inputs': inputs,
      'prediction': prediction,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PredictionRecord.fromJson(Map<String, dynamic> json) {
    return PredictionRecord(
      inputs: List<double>.from(json['inputs']),
      prediction: json['prediction'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<PredictionRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('prediction_history') ?? [];
    
    setState(() {
      _history = historyJson
          .map((item) => PredictionRecord.fromJson(jsonDecode(item)))
          .toList();
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  String _getFeatureName(int index) {
    final featureNames = [
      'Attendance (%)',
      'Parental Engagement',
      'Sleep Hours',
      'Previous Grades',
      'Hours Studied',
      'Tutoring Sessions',
      'Physical Activity'
    ];
    return index < featureNames.length ? featureNames[index] : 'Feature $index';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
        centerTitle: true,
        backgroundColor: huntGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: backgroundWhite,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: huntGreen))
            : _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: huntGreen.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No prediction history yet',
                          style: TextStyle(
                            fontSize: 18,
                           color: huntGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final record = _history[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: huntGreen, width: 4),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Prediction: ${record.prediction.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                       color: huntGreen,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(record.timestamp),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Text(
                                  'Input Values:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                   color: huntGreen,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...List.generate(
                                  record.inputs.length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      '${_getFeatureName(i)}: ${record.inputs[i]}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}