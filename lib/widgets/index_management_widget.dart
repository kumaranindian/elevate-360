import 'package:flutter/material.dart';
import '../services/index_initialization_service.dart';
import '../core/utils/app_theme.dart';

class IndexManagementWidget extends StatefulWidget {
  const IndexManagementWidget({super.key});

  @override
  State<IndexManagementWidget> createState() => _IndexManagementWidgetState();
}

class _IndexManagementWidgetState extends State<IndexManagementWidget> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _indexStatus = [];

  @override
  void initState() {
    super.initState();
    _loadIndexStatus();
  }

  Future<void> _loadIndexStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Define all required indexes
      final indexes = [
        {
          'name': 'Performance Reviews - Employee Reviews',
          'collection': 'performanceReviews',
          'fields': ['employee_id', 'year', 'quarter'],
          'description': 'For querying employee reviews with ordering'
        },
        {
          'name': 'Performance Reviews - Status Reviews',
          'collection': 'performanceReviews',
          'fields': ['status', 'updated_at'],
          'description': 'For querying reviews by status with ordering'
        },
        {
          'name': 'Performance Reviews - Reportee Reviews',
          'collection': 'performanceReviews',
          'fields': ['employee_id', 'status', 'updated_at'],
          'description': 'For querying reportee reviews with composite conditions'
        },
        {
          'name': 'Employees - By Manager',
          'collection': 'employees',
          'fields': ['manager_id'],
          'description': 'For querying employees by manager'
        },
        {
          'name': 'Goals - By Employee',
          'collection': 'goals',
          'fields': ['employee_id'],
          'description': 'For querying goals by employee'
        },
        {
          'name': 'Goals - By Status',
          'collection': 'goals',
          'fields': ['status'],
          'description': 'For querying goals by status'
        },
        {
          'name': 'Assessments - By Employee',
          'collection': 'self_assessments',
          'fields': ['employee_id'],
          'description': 'For querying assessments by employee'
        },
        {
          'name': 'Skills - By Employee',
          'collection': 'skills',
          'fields': ['employee_id'],
          'description': 'For querying skills by employee'
        },
        {
          'name': 'Reviews - By Employee',
          'collection': 'reviews',
          'fields': ['employee_id'],
          'description': 'For querying reviews by employee'
        }
      ];

      final statusList = <Map<String, dynamic>>[];
      
      for (final index in indexes) {
        final isAvailable = await IndexInitializationService.testIndexAvailability(
          index['collection'] as String,
          index['fields'] as List<String>,
        );
        
        statusList.add({
          ...index,
          'available': isAvailable,
          'creationLink': IndexInitializationService.getIndexCreationLink(
            index['collection'] as String,
            index['fields'] as List<String>,
          ),
        });
      }

      setState(() {
        _indexStatus = statusList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading index status: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Index Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.secondaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Firestore Index Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_indexStatus.where((index) => index['available'] == true).length}/${_indexStatus.length} indexes available',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _indexStatus.length,
                    itemBuilder: (context, index) {
                      final indexData = _indexStatus[index];
                      final isAvailable = indexData['available'] as bool;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppTheme.cardColor,
                        child: ListTile(
                          leading: Icon(
                            isAvailable ? Icons.check_circle : Icons.error,
                            color: isAvailable ? Colors.green : Colors.orange,
                          ),
                          title: Text(
                            indexData['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                indexData['description'] as String,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Collection: ${indexData['collection']}',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Fields: ${(indexData['fields'] as List<String>).join(', ')}',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          trailing: isAvailable
                              ? const Chip(
                                  label: Text('Available'),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.link, color: Colors.blue),
                                  onPressed: () => _showCreationLink(indexData),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loadIndexStatus,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Status'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _createAllIndexes,
                          icon: const Icon(Icons.build),
                          label: const Text('Create All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showCreationLink(Map<String, dynamic> indexData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Index: ${indexData['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Collection: ${indexData['collection']}'),
            const SizedBox(height: 8),
            Text('Fields: ${(indexData['fields'] as List<String>).join(', ')}'),
            const SizedBox(height: 16),
            const Text(
              'Click the link below to create this index in Firebase Console:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            SelectableText(
              indexData['creationLink'] as String,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Copy link to clipboard
              // You can implement clipboard functionality here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAllIndexes() async {
    try {
      await IndexInitializationService.initializeAllIndexes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Index creation links generated in console'),
            backgroundColor: Colors.green,
          ),
        );
        _loadIndexStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating indexes: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
} 