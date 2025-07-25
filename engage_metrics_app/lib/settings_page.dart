import 'package:flutter/material.dart';
import 'api_service.dart';

// Hunt Green theme only
const Color huntGreen = Color(0xFF355E3B);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiUrlController = TextEditingController();
  String _currentApiUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentApiUrl();
  }

  Future<void> _loadCurrentApiUrl() async {
    final url = await getApiBaseUrl();
    setState(() {
      _currentApiUrl = url;
      _apiUrlController.text = url;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveApiUrl() async {
    final newUrl = _apiUrlController.text.trim();
    if (newUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('API URL cannot be empty'),
          backgroundColor: huntGreen,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await setApiBaseUrl(newUrl);
      setState(() {
        _currentApiUrl = newUrl;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('API URL saved successfully'),
          backgroundColor: huntGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving API URL: $e'),
          backgroundColor: huntGreen,
        ),
      );
    }
  }

  Future<void> _useLocalApi() async {
    await setApiBaseUrl(localApiUrl);
    _loadCurrentApiUrl();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Using local API'),
        backgroundColor: huntGreen,
      ),
    );
  }

  Future<void> _useDeployedApi() async {
    await setApiBaseUrl(deployedApiUrl);
    _loadCurrentApiUrl();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Using deployed API'),
        backgroundColor: huntGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Settings'),
        centerTitle: true,
        backgroundColor: huntGreen,
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: huntGreen))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Current API URL:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: huntGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: huntGreen.withOpacity(0.5)),
                      ),
                      child: Text(
                        _currentApiUrl,
                        style: TextStyle(color: huntGreen),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Change API URL:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: huntGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apiUrlController,
                      decoration: InputDecoration(
                        labelText: 'API URL',
                        labelStyle: TextStyle(color: huntGreen),
                        hintText: 'e.g., http://127.0.0.1:8000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: huntGreen, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveApiUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: huntGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Custom URL'),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Quick Settings:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: huntGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _useLocalApi,
                      icon: const Icon(Icons.computer),
                      label: const Text('Use Local API'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: huntGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _useDeployedApi,
                      icon: const Icon(Icons.cloud),
                      label: const Text('Use Deployed API'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: huntGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}