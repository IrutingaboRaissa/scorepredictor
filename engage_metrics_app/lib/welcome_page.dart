import 'package:flutter/material.dart';

import 'prediction_screen.dart';
import 'history_page.dart';
import 'settings_page.dart';

// Hunt Green theme only
const Color huntGreen = Color(0xFF355E3B);

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EngageMetrics'),
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
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology,
                  size: 80,
                  color: huntGreen,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to EngageMetrics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: huntGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Predict student exam scores based on key performance factors',
                  style: TextStyle(
                    fontSize: 18,
                    color: huntGreen,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PredictionScreen()),
                    );
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Make Prediction'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: huntGreen,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryPage()),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View History'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: huntGreen,
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