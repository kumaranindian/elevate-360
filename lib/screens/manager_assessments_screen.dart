import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/performance_review_model.dart';
import '../models/employee_model.dart';
import '../services/performance_review_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import 'manager_review_screen.dart';

class ManagerAssessmentsScreen extends StatefulWidget {
  final UserModel userModel;

  const ManagerAssessmentsScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ManagerAssessmentsScreen> createState() => _ManagerAssessmentsScreenState();
}

class _ManagerAssessmentsScreenState extends State<ManagerAssessmentsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, List<Map<String, dynamic>>> _groupedReviews = {
    'self_review_pending': [],
    'manager_review_pending': [],
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
      print('DEBUG: Loading data for manager: ${widget.userModel.uid}');
      
      // First, debug all reviews in database
      await PerformanceReviewService.debugAllReviews();
      
      // Load reportee reviews grouped by status
      final groupedReviews = await PerformanceReviewService.getReporteeReviewsByStatus(widget.userModel.uid);
      
      setState(() {
        _groupedReviews = groupedReviews;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading data: $e');
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
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performance Reviews - Manager Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review reportees who have completed their self-assessments',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Review status counts
                Row(
                  children: [
                    Expanded(
                      child: _buildCountCard(
                        'Self Review Pending',
                        _groupedReviews['self_review_pending']!.length,
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCountCard(
                        'Manager Review Pending',
                        _groupedReviews['manager_review_pending']!.length,
                        Icons.rate_review,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCountCard(
                        'HR Review Pending',
                        _groupedReviews['hr_review_pending']!.length,
                        Icons.assignment_turned_in,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCountCard(
                        'Completed',
                        _groupedReviews['completed']!.length,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildGroupedReviews(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedReviews() {
    final totalReviews = _groupedReviews.values
        .map((list) => list.length)
        .fold(0, (sum, count) => sum + count);

    if (totalReviews == 0) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, color: Colors.white70, size: 48),
              SizedBox(height: 16),
              Text(
                'No reportees found',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Check if you have any team members assigned',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        // Manager Review Pending Section
        if (_groupedReviews['manager_review_pending']!.isNotEmpty)
          _buildStatusSection(
            'Manager Review Pending',
            _groupedReviews['manager_review_pending']!,
            Colors.blue,
            Icons.rate_review,
          ),
        
        // HR Review Pending Section (Manager Review Completed)
        if (_groupedReviews['hr_review_pending']!.isNotEmpty)
          _buildDetailedStatusSection(
            'Manager Review Completed - Awaiting HR Review',
            _groupedReviews['hr_review_pending']!,
            Colors.purple,
            Icons.assignment_turned_in,
          ),
        
        // Completed Section
        if (_groupedReviews['completed']!.isNotEmpty)
          _buildStatusSection(
            'Completed Reviews',
            _groupedReviews['completed']!,
            Colors.green,
            Icons.check_circle,
          ),
      ],
    );
  }

  Widget _buildStatusSection(
    String title,
    List<Map<String, dynamic>> reviews,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${reviews.length}',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...reviews.map((reviewData) => _buildReviewCard(reviewData)).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> reviewData) {
    final employeeName = reviewData['employee_name'] as String;
    final status = reviewData['status'] as String;
    final quarter = reviewData['quarter'];
    final year = reviewData['year'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  employeeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (quarter != null && year != null) ...[
            const SizedBox(height: 8),
            Text(
              'Review Period: Q$quarter $year',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Review ratings summary
          _buildReviewRatingsSummaryFromData(reviewData),
          const SizedBox(height: 12),
          // Action button based on status
          if (status == 'self review completed' || status == 'Self Review Completed')
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate to manager review screen
                final reviewId = reviewData['review_id'];
                if (reviewId != null) {
                  // Load the full review model and navigate
                  try {
                    final review = await PerformanceReviewService.getReviewById(reviewId);
                    if (review != null) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManagerReviewScreen(
                            userModel: widget.userModel,
                            review: review,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadData(); // Refresh the list
                      }
                    }
                  } catch (e) {
                    print('Error loading review: $e');
                  }
                }
              },
              icon: const Icon(Icons.rate_review, size: 16),
              label: const Text('Review Performance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            )
          else
            Text(
              _getActionText(status),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  String _getActionText(String status) {
    switch (status.toLowerCase()) {
      case 'awaiting self review':
      case 'no review created':
        return 'Waiting for employee to complete self-review';
      case 'manager review completed':
        return 'Pending HR review';
      case 'review completed':
        return 'Review completed';
      default:
        return 'Status: $status';
    }
  }

  Widget _buildDetailedStatusSection(
    String title,
    List<Map<String, dynamic>> reviews,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${reviews.length}',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Show detailed submitted information for each review
              ...reviews.map((reviewData) => _buildDetailedReviewCard(reviewData, color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedReviewCard(Map<String, dynamic> reviewData, Color color) {
    final employeeName = reviewData['employee_name'] ?? 'Unknown Employee';
    final status = reviewData['status'] ?? 'Unknown';
    final quarter = reviewData['quarter'];
    final year = reviewData['year'];
    final selfReviewData = reviewData['self_review_data'];
    final managerReviewData = reviewData['manager_review_data'];
    final hrReviewData = reviewData['hr_review_data'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee name and review period
          Row(
            children: [
              Expanded(
                child: Text(
                  employeeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (quarter != null && year != null)
                Text(
                  'Q$quarter $year',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Self Review, Manager Review, and HR Review Ratings Side by Side
          Row(
            children: [
              // Self Review Ratings
              Expanded(
                child: _buildDetailedRatingSection(
                  'Self Review',
                  selfReviewData,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              // Manager Review Ratings
              Expanded(
                child: _buildDetailedRatingSection(
                  'Manager Review',
                  managerReviewData,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              // HR Review Ratings
              Expanded(
                child: _buildDetailedRatingSection(
                  'HR Review',
                  hrReviewData,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // View Details Button
          Row(
            children: [
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showDetailedReviewModal(reviewData),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withOpacity(0.2),
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetailedReviewModal(Map<String, dynamic> reviewData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade800),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.assessment, color: Colors.purple, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reviewData['employee_name'] ?? 'Unknown Employee',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Performance Review - Q${reviewData['quarter']} ${reviewData['year']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildDetailedReviewContent(reviewData),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailedReviewContent(Map<String, dynamic> reviewData) {
    print('DEBUG: Full review data in modal: $reviewData');
    
    final selfReviewData = reviewData['self_review_data'];
    final managerReviewData = reviewData['manager_review_data'];
    final hrReviewData = reviewData['hr_review_data'];
    
    print('DEBUG: Self review data: $selfReviewData');
    print('DEBUG: Manager review data: $managerReviewData');
    print('DEBUG: HR review data: $hrReviewData');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Self Review Section
        _buildReviewSection(
          'Self Assessment',
          selfReviewData,
          Colors.blue,
          Icons.person,
        ),
        
        const SizedBox(height: 24),
        
        // Manager Review Section
        _buildReviewSection(
          'Manager Assessment',
          managerReviewData,
          Colors.green,
          Icons.supervisor_account,
        ),
        
        const SizedBox(height: 24),
        
        // HR Review Section
        _buildReviewSection(
          'HR Assessment',
          hrReviewData,
          Colors.purple,
          Icons.business_center,
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, dynamic reviewData, Color color, IconData icon) {
    if (reviewData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Not completed',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Handle different data structures for different review types
    Map<String, dynamic>? kpiRatings;
    dynamic overallRating;
    String? overallFeedback;
    String? achievements;
    String? challenges;
    String? goals;
    
    if (reviewData is Map<String, dynamic>) {
      // Try different field names based on review type
      kpiRatings = reviewData['kpi_ratings'] as Map<String, dynamic>? ?? 
                   reviewData['question_ratings'] as Map<String, dynamic>?;
      
      overallRating = reviewData['overall_rating'];
      
      overallFeedback = reviewData['overall_feedback'] as String? ?? 
                       reviewData['overall_summary'] as String?;
      
      // Try to get achievements, challenges, goals from different locations
      if (reviewData['achievements'] != null) {
        achievements = reviewData['achievements'] as String?;
      } else if (reviewData['manager_comments'] != null) {
        final comments = reviewData['manager_comments'] as Map<String, dynamic>;
        achievements = comments['achievements'] as String?;
      }
      
      if (reviewData['challenges'] != null) {
        challenges = reviewData['challenges'] as String?;
      } else if (reviewData['manager_comments'] != null) {
        final comments = reviewData['manager_comments'] as Map<String, dynamic>;
        challenges = comments['challenges'] as String?;
      }
      
      if (reviewData['goals'] != null) {
        goals = reviewData['goals'] as String?;
      } else if (reviewData['manager_comments'] != null) {
        final comments = reviewData['manager_comments'] as Map<String, dynamic>;
        goals = comments['goals'] as String?;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // KPI Ratings
          if (kpiRatings != null && kpiRatings.isNotEmpty) ...[
            const Text(
              'KPI Ratings:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...kpiRatings.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      final rating = (entry.value as num?)?.toDouble() ?? 0.0;
                      return Icon(
                        index < rating.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(entry.value as num?)?.toStringAsFixed(1) ?? '0.0'}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
          
          // Overall Rating
          if (overallRating != null) ...[
            Row(
              children: [
                const Text(
                  'Overall Rating: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    final rating = (overallRating as num?)?.toDouble() ?? 0.0;
                    return Icon(
                      index < rating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(overallRating as num?)?.toStringAsFixed(1) ?? '0.0'}',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          // Overall Feedback
          if (overallFeedback != null && overallFeedback.toString().isNotEmpty) ...[
            const Text(
              'Overall Feedback:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              overallFeedback.toString(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Achievements
          if (achievements != null && achievements.toString().isNotEmpty) ...[
            const Text(
              'Achievements:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievements.toString(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Challenges
          if (challenges != null && challenges.toString().isNotEmpty) ...[
            const Text(
              'Challenges:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              challenges.toString(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Goals
          if (goals != null && goals.toString().isNotEmpty) ...[
            const Text(
              'Goals:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              goals.toString(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedRatingSection(String title, dynamic reviewData, Color color) {
    if (reviewData == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Not completed',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    // Calculate average rating from KPI ratings
    double averageRating = 0.0;
    int ratingCount = 0;
    
    if (reviewData is Map<String, dynamic>) {
      // Try different field names for KPI ratings
      final kpiRatings = reviewData['kpi_ratings'] as Map<String, dynamic>? ?? 
                        reviewData['question_ratings'] as Map<String, dynamic>?;
      
      if (kpiRatings != null) {
        double totalRating = 0.0;
        int count = 0;
        kpiRatings.forEach((key, value) {
          if (value is num && key.startsWith('kpi_')) {
            totalRating += value.toDouble();
            count++;
          }
        });
        if (count > 0) {
          averageRating = totalRating / count;
          ratingCount = count;
        }
      }
      
      // If no KPI ratings found, try to use average_rating field directly
      if (averageRating == 0.0 && reviewData['average_rating'] != null) {
        averageRating = (reviewData['average_rating'] as num).toDouble();
        ratingCount = 1; // Indicate we have a rating
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            // Star rating display
            ...List.generate(5, (index) {
              return Icon(
                index < averageRating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
            const SizedBox(width: 8),
            Text(
              '${averageRating.toStringAsFixed(1)} ($ratingCount KPIs)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewRatingsSummaryFromData(Map<String, dynamic> reviewData) {
    return Row(
      children: [
        // Self Rating
        Expanded(
          child: _buildRatingCard(
            'Self Rating',
            _formatRating(_calculateRatingFromData(reviewData, 'self_review_data')),
            reviewData['self_review_data'] != null ? Colors.blue : Colors.grey,
            reviewData['self_review_data'] != null ? 'Completed' : 'Pending',
          ),
        ),
        const SizedBox(width: 8),
        // Manager Rating
        Expanded(
          child: _buildRatingCard(
            'Manager Rating',
            _formatRating(_calculateRatingFromData(reviewData, 'manager_review_data')),
            reviewData['manager_review_data'] != null ? Colors.green : Colors.grey,
            reviewData['manager_review_data'] != null ? 'Completed' : 'Pending',
          ),
        ),
        const SizedBox(width: 8),
        // HR Rating
        Expanded(
          child: _buildRatingCard(
            'HR Rating',
            _formatRating(_calculateRatingFromData(reviewData, 'hr_review_data')),
            reviewData['hr_review_data'] != null ? Colors.orange : Colors.grey,
            reviewData['hr_review_data'] != null ? 'Completed' : 'Pending',
          ),
        ),
      ],
    );
  }

  String _formatRating(double? rating) {
    if (rating == null) return '--';
    return rating.toStringAsFixed(1);
  }

  double? _calculateRatingFromData(Map<String, dynamic> reviewData, String dataKey) {
    final data = reviewData[dataKey];
    if (data == null) return null;
    
    if (data is Map<String, dynamic>) {
      // Check for overall_rating first
      if (data['overall_rating'] != null) {
        return (data['overall_rating'] as num).toDouble();
      }
      
      // Calculate from KPI ratings if available
      final kpiRatings = data['kpi_ratings'];
      if (kpiRatings is Map<String, dynamic> && kpiRatings.isNotEmpty) {
        double total = 0;
        int count = 0;
        kpiRatings.forEach((key, value) {
          if (value is num) {
            total += value.toDouble();
            count++;
          }
        });
        return count > 0 ? total / count : null;
      }
    }
    
    return null;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'awaiting manager review':
        return Colors.orange;
      case 'awaiting hr review':
        return Colors.blue;
      case 'review completed':
        return Colors.green;
      case 'awaiting self review':
        return Colors.yellow;
      case 'self review completed':
        return Colors.blue;
      case 'manager review completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCountCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRatingsSummary(PerformanceReviewModel review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Ratings Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRatingCard(
                  'Self Rating',
                  _getSelfRating(review),
                  review.selfReviewData != null ? Colors.blue : Colors.grey,
                  review.selfReviewData != null ? 'Completed' : 'Pending',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingCard(
                  'Manager Rating',
                  _getManagerRating(review),
                  review.managerReviewData != null ? Colors.green : Colors.grey,
                  review.managerReviewData != null ? 'Completed' : 'Pending',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingCard(
                  'HR Rating',
                  _getHRRating(review),
                  review.hrReviewData != null ? Colors.orange : Colors.grey,
                  review.hrReviewData != null ? 'Completed' : 'Pending',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(String title, String rating, Color color, String status) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            rating,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getSelfRating(PerformanceReviewModel review) {
    if (review.selfReviewData == null) return 'N/A';
    
    final selfData = review.selfReviewData!;
    if (selfData['overall_rating'] != null) {
      return '${selfData['overall_rating']}/5';
    }
    
    // Calculate average from KPI ratings if available
    if (selfData['kpi_ratings'] != null) {
      final kpiRatings = Map<String, dynamic>.from(selfData['kpi_ratings']);
      if (kpiRatings.isNotEmpty) {
        final total = kpiRatings.values.fold(0.0, (sum, rating) => sum + (rating as num).toDouble());
        final average = total / kpiRatings.length;
        return '${average.toStringAsFixed(1)}/5';
      }
    }
    
    return 'N/A';
  }

  String _getManagerRating(PerformanceReviewModel review) {
    if (review.managerReviewData == null) return 'N/A';
    
    final managerData = review.managerReviewData!;
    if (managerData['overall_rating'] != null) {
      return '${managerData['overall_rating']}/5';
    }
    
    // Calculate average from KPI ratings if available
    if (managerData['average_rating'] != null) {
      return '${managerData['average_rating']}/5';
    }
    
    if (managerData['kpi_ratings'] != null) {
      final kpiRatings = Map<String, dynamic>.from(managerData['kpi_ratings']);
      if (kpiRatings.isNotEmpty) {
        final total = kpiRatings.values.fold(0.0, (sum, rating) => sum + (rating as num).toDouble());
        final average = total / kpiRatings.length;
        return '${average.toStringAsFixed(1)}/5';
      }
    }
    
    return 'N/A';
  }

  String _getHRRating(PerformanceReviewModel review) {
    if (review.hrReviewData == null) return 'N/A';
    
    final hrData = review.hrReviewData!;
    if (hrData['overall_rating'] != null) {
      return '${hrData['overall_rating']}/5';
    }
    
    // Calculate average from KPI ratings if available
    if (hrData['kpi_ratings'] != null) {
      final kpiRatings = Map<String, dynamic>.from(hrData['kpi_ratings']);
      if (kpiRatings.isNotEmpty) {
        final total = kpiRatings.values.fold(0.0, (sum, rating) => sum + (rating as num).toDouble());
        final average = total / kpiRatings.length;
        return '${average.toStringAsFixed(1)}/5';
      }
    }
    
    return 'N/A';
  }
}
