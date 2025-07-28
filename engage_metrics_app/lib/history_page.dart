
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  Future<void> _deleteRecord(int index) async {
    setState(() {
      _history.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('prediction_history', historyJson);
  }

  Future<void> _editRecord(int index) async {
    final record = _history[index];
    final inputControllers = List.generate(
      record.inputs.length,
      (i) => TextEditingController(text: record.inputs[i].toString()),
    );
    bool isLoading = false;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Edit Prediction Factors'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(inputControllers.length, (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: TextField(
                        controller: inputControllers[i],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _getFeatureName(i),
                        ),
                      ),
                    )),
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: CircularProgressIndicator(color: huntGreen),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final newInputsNullable = inputControllers
                        .map((c) => double.tryParse(c.text.trim()))
                        .toList();
                    if (newInputsNullable.contains(null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter valid numbers for all fields.')),
                      );
                      return;
                    }
                    final newInputs = newInputsNullable.cast<double>();
                    setStateDialog(() => isLoading = true);
                    // Call API to get new prediction
                    double? newPredictionNullable;
                    try {
                      newPredictionNullable = await _getPredictionFromApi(newInputs);
                    } catch (e) {
                      newPredictionNullable = null;
                    }
                    setStateDialog(() => isLoading = false);
                    if (newPredictionNullable != null) {
                      final newPrediction = newPredictionNullable;
                      setState(() {
                        _history[index] = PredictionRecord(
                          inputs: newInputs,
                          prediction: newPrediction,
                          timestamp: DateTime.now(),
                        );
                      });
                      final prefs = await SharedPreferences.getInstance();
                      final historyJson = _history.map((r) => jsonEncode(r.toJson())).toList();
                      await prefs.setStringList('prediction_history', historyJson);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to get prediction. Please try again.')),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<double?> _getPredictionFromApi(List<double> inputs) async {
    await Future.delayed(Duration(seconds: 1));
    return inputs.reduce((a, b) => a + b) / inputs.length;
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
        actions: [],
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
                          horizontal: 14,
                          vertical: 7,
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
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.orange),
                                          tooltip: 'Edit',
                                          onPressed: () => _editRecord(index),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Delete',
                                          onPressed: () => _deleteRecord(index),
                                        ),
                                      ],
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