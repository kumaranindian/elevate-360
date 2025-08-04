import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/performance_review_model.dart';
import '../models/employee_model.dart';
import '../services/performance_review_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import 'hr_review_screen.dart';

class HRAssessmentsScreen extends StatefulWidget {
  final UserModel userModel;

  const HRAssessmentsScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<HRAssessmentsScreen> createState() => _HRAssessmentsScreenState();
}

class _HRAssessmentsScreenState extends State<HRAssessmentsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, List<Map<String, dynamic>>> _groupedReviews = {
    'hr_review_pending': [],
    'completed': [],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('DEBUG: Loading data for HR: ${widget.userModel.uid}');
      
      // First, debug all reviews in database
      await PerformanceReviewService.debugAllReviews();
      
      // Load reviews specifically for HR using the existing method
      // First try the dedicated HR method
      List<PerformanceReviewModel> hrReviews = [];
      try {
        hrReviews = await PerformanceReviewService.getReviewsForHR();
        print('DEBUG HR: Found ${hrReviews.length} reviews from getReviewsForHR()');
        
        // Debug each review found
        for (int i = 0; i < hrReviews.length; i++) {
          final review = hrReviews[i];
          print('DEBUG HR: Review $i - ID: ${review.id}, Status: "${review.status}", Employee: ${review.employeeId}');
          print('DEBUG HR: Review $i - Created: ${review.createdAt}, Updated: ${review.updatedAt}');
        }
      } catch (e) {
        print('DEBUG HR: Error with getReviewsForHR(): $e');
        print('DEBUG HR: Stack trace: ${e.toString()}');
      }
      
      // If no reviews found, provide helpful debug information
      if (hrReviews.isEmpty) {
        print('DEBUG HR: No reviews found with status "manager review completed"');
        print('DEBUG HR: This means either:');
        print('DEBUG HR: 1. No reviews have completed manager review yet');
        print('DEBUG HR: 2. All reviews are already completed by HR');
        print('DEBUG HR: 3. There might be a data issue');
      }
      
      print('DEBUG HR: Processing ${hrReviews.length} reviews for HR');
      
      // Group reviews by HR status with deduplication
      final Map<String, List<Map<String, dynamic>>> groupedReviews = {
        'hr_review_pending': [],
        'completed': [],
      };
      
      // Track processed employees to avoid duplicates
      final Set<String> processedEmployees = <String>{};

      for (final review in hrReviews) {
        
        // Skip if this employee has already been processed (deduplication)
        if (processedEmployees.contains(review.employeeId)) {
          print('DEBUG HR: Skipping duplicate employee: ${review.employeeId}');
          continue;
        }
        
        // Mark this employee as processed
        processedEmployees.add(review.employeeId);
        
        // Load employee data for each review
        final employee = await EmployeeService.getEmployeeById(review.employeeId);
        
        final processedReviewData = {
          'review': review,
          'employee': employee,
          'employee_name': employee?.fullName ?? 'Unknown Employee',
          'employee_email': employee?.email ?? '',
          'department': employee?.departmentId ?? 'Unknown Department',
          'role': employee?.roleId ?? 'Unknown Role',
        };

        print('DEBUG HR: Review ${review.id} - Status: ${review.status} - Employee: ${employee?.fullName}');

        // Group by status from HR perspective
        switch (review.status) {
          case 'manager review completed':
            // These are reviews awaiting HR review
            print('DEBUG HR: Adding to hr_review_pending: ${review.id}');
            groupedReviews['hr_review_pending']!.add(processedReviewData);
            break;
          case 'review completed':
            // These are fully completed reviews
            print('DEBUG HR: Adding to completed: ${review.id}');
            groupedReviews['completed']!.add(processedReviewData);
            break;
          default:
            // Other statuses (self review pending, manager review pending) are not relevant for HR
            print('DEBUG HR: Ignoring review with status: ${review.status}');
            break;
        }
      }
      
      setState(() {
        _groupedReviews = groupedReviews;
        _isLoading = false;
      });
      
      print('DEBUG: HR Reviews loaded - Pending: ${_groupedReviews['hr_review_pending']!.length}, Completed: ${_groupedReviews['completed']!.length}');
    } catch (e) {
      print('DEBUG: Error loading HR data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Header section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HR Performance Reviews',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Review and approve employee performance assessments',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Pending HR Review',
                        _groupedReviews['hr_review_pending']!.length,
                        Icons.pending_actions,
                        AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Completed Reviews',
                        _groupedReviews['completed']!.length,
                        Icons.check_circle,
                        AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Reviews content
          Expanded(
            child: _buildReviewSections(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSections() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HR Review Pending Section
          if (_groupedReviews['hr_review_pending']!.isNotEmpty) ...[
            _buildSectionHeader(
              'Pending HR Review',
              _groupedReviews['hr_review_pending']!.length,
              Icons.pending_actions,
              AppTheme.warningColor,
            ),
            const SizedBox(height: 12),
            ..._groupedReviews['hr_review_pending']!.map((reviewData) =>
              _buildReviewCard(reviewData, true)
            ),
            const SizedBox(height: 24),
          ],
          
          // Completed Reviews Section
          if (_groupedReviews['completed']!.isNotEmpty) ...[
            _buildSectionHeader(
              'Completed Reviews',
              _groupedReviews['completed']!.length,
              Icons.check_circle,
              AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            ..._groupedReviews['completed']!.map((reviewData) =>
              _buildReviewCard(reviewData, false)
            ),
            const SizedBox(height: 24),
          ],
          
          // Empty state
          if (_groupedReviews['hr_review_pending']!.isEmpty && _groupedReviews['completed']!.isEmpty)
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> reviewData, bool isPending) {
    final review = reviewData['review'] as PerformanceReviewModel;
    final employee = reviewData['employee'] as EmployeeModel?;
    final employeeName = reviewData['employee_name'] as String;
    final department = reviewData['department'] as String;
    final role = reviewData['role'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isPending ? () => _navigateToHRReview(review, employee) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Employee avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        employeeName.isNotEmpty ? employeeName[0].toUpperCase() : 'E',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Employee info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employeeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$role • $department',
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending 
                            ? AppTheme.warningColor.withOpacity(0.1)
                            : AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isPending ? 'Pending Review' : 'Completed',
                        style: TextStyle(
                          color: isPending ? AppTheme.warningColor : AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Review details
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${review.quarter} ${review.year}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(review.updatedAt),
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
                
                if (isPending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToHRReview(review, employee),
                          icon: const Icon(Icons.rate_review, size: 16),
                          label: const Text('Conduct HR Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.assignment_turned_in,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No Reviews Available',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are currently no performance reviews awaiting HR review.',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateToHRReview(PerformanceReviewModel review, EmployeeModel? employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HRReviewScreen(
          userModel: widget.userModel,
          review: review,
        ),
      ),
    ).then((result) {
      // Refresh data if review was submitted
      if (result == true) {
        _loadData();
      }
    });
  }
}
