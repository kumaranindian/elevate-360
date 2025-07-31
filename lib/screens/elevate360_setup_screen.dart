import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/elevate360_data_setup.dart';
import '../core/utils/app_theme.dart';

class Elevate360SetupScreen extends ConsumerStatefulWidget {
  const Elevate360SetupScreen({super.key});

  @override
  ConsumerState<Elevate360SetupScreen> createState() => _Elevate360SetupScreenState();
}

class _Elevate360SetupScreenState extends ConsumerState<Elevate360SetupScreen> {
  bool _isLoading = false;
  String _status = 'Ready to setup Elevate360 data';
  List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Elevate360 Data Setup'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Elevate360 Performance Management System',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will create a comprehensive performance management system with refined role-based access, Q1 & Q2 2025 data, and realistic organizational hierarchy.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Features Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Features:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('👥 19 Users with proper hierarchy'),
                  _buildFeatureItem('🔐 4 Role types: Employee, Manager, HR Manager, HR'),
                  _buildFeatureItem('📅 Q1 & Q2 2025 performance data'),
                  _buildFeatureItem('🎯 3-4 goals per user per quarter'),
                  _buildFeatureItem('📝 Self, Manager, and HR reviews'),
                  _buildFeatureItem('🏢 6 Teams across 6 Departments'),
                  _buildFeatureItem('📊 5 Goal categories with metrics'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.info_outline,
                    color: _isLoading ? Colors.orange : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Setup Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _setupElevate360Data,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Setting up Elevate360 data...'),
                        ],
                      )
                    : const Text(
                        'Setup Elevate360 Data',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Logs
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup Logs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            Color logColor = Colors.white;
                            
                            if (log.contains('✅')) {
                              logColor = Colors.green;
                            } else if (log.contains('❌')) {
                              logColor = Colors.red;
                            } else if (log.contains('⚠️')) {
                              logColor = Colors.orange;
                            } else if (log.contains('🚀')) {
                              logColor = Colors.blue;
                            }
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                log,
                                style: TextStyle(
                                  color: logColor,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setupElevate360Data() async {
    setState(() {
      _isLoading = true;
      _status = 'Setting up Elevate360 data...';
      _logs.clear();
    });

    try {
      _addLog('🚀 Starting Elevate360 data setup...');
      
      final setup = Elevate360DataSetup();
      await setup.setupElevate360Data();
      
      setState(() {
        _status = 'Elevate360 data setup completed successfully!';
        _isLoading = false;
      });
      
      _addLog('✅ Elevate360 data setup completed successfully!');
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Setup Complete!',
              style: TextStyle(color: Colors.white),
            ),
                         content: Text(
               'Elevate360 Performance Management System has been set up successfully with:\n\n'
               '• 19 Users with proper role hierarchy\n'
               '• Q1 & Q2 2025 performance data\n'
               '• Refined role-based access control\n'
               '• Comprehensive goal and review system\n\n'
               'Test Accounts:\n'
               '• malai@ideas2it.com (Manager - Multi-team)\n'
               '• jennifer@ideas2it.com (HR Manager)\n'
               '• sarah@ideas2it.com (HR - Read-only)\n'
               '• james@ideas2it.com (QA Manager)\n'
               '• maria@ideas2it.com (DevOps Manager)\n'
               '• david@ideas2it.com (Sales Manager)\n'
               '• All employees with Admin@1234 password',
               style: TextStyle(color: Colors.grey[300]),
             ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
      
      _addLog('❌ Error during setup: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $message');
    });
  }
} 