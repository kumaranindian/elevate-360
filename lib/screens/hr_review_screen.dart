import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/performance_review_model.dart';
import '../models/employee_model.dart';
import '../models/self_assessment_model.dart';
import '../services/performance_review_service.dart';
import '../services/employee_service.dart';
import '../services/self_assessment_service.dart';
import '../core/utils/app_theme.dart';

class HRReviewScreen extends StatefulWidget {
  final UserModel userModel;
  final PerformanceReviewModel review;
  final VoidCallback? onReviewSubmitted; // Callback to refresh parent screen

  const HRReviewScreen({
    super.key,
    required this.userModel,
    required this.review,
    this.onReviewSubmitted,
  });

  @override
  State<HRReviewScreen> createState() => _HRReviewScreenState();
}

class _HRReviewScreenState extends State<HRReviewScreen> {
  bool _isLoading = true;
  String? _error;
  EmployeeModel? _employee;
  SelfAssessmentModel? _selfAssessment;
  
  // HR review data
  Map<String, double> _questionRatings = {}; // Individual HR ratings for each question (1-5)
  String _overallSummary = '';
  double _averageRating = 0.0;
  int _overallRating = 0; // HR's overall rating (separate from average)
  bool _isReadOnly = false;
  
  // Existing review data for display
  Map<String, double> _managerRatings = {};
  
  final TextEditingController _summaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployeeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Loading employee data for ID: ${widget.review.employeeId}');
      final employee = await EmployeeService.getEmployeeById(widget.review.employeeId);
      
      // Load the self-assessment data for this employee and quarter
      print('Loading self-assessment for employee: ${widget.review.employeeId}, quarter: ${widget.review.quarter}, year: ${widget.review.year}');
      final selfAssessment = await SelfAssessmentService.getSelfAssessmentByEmployeeAndQuarter(
        widget.review.employeeId,
        widget.review.quarter,
        widget.review.year,
      );
      print('Self-assessment loaded: ${selfAssessment != null ? 'SUCCESS' : 'NULL'}');
      
      // Initialize HR ratings for each self-review question
      if (selfAssessment != null) {
        // Initialize for KPI ratings
        selfAssessment.kpiRatings.forEach((kpi, rating) {
          final key = 'kpi_$kpi';
          _questionRatings[key] = 3.0; // Default rating
        });
      }

      // Check if HR review already exists and load it
      await _loadExistingHRReview();
      
      // Load manager review data for display
      await _loadManagerReviewData();
      
      setState(() {
        _employee = employee;
        _selfAssessment = selfAssessment;
        _isLoading = false;
      });
      
      // Don't calculate average rating initially - wait for HR to provide ratings
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExistingHRReview() async {
    try {
      // Generate HR review ID (type 3 for HR review)
      final quarterLower = widget.review.quarter.toLowerCase().replaceAll(' ', '').replaceAll(widget.review.year.toString(), '');
      final hrReviewId = '${widget.review.year}_${quarterLower}_${widget.review.employeeId}_3';
      
      // Load existing HR review from performance_reviews collection
      final performanceReview = await PerformanceReviewService.getReviewById(hrReviewId);
      
      if (performanceReview?.hrReviewData != null) {
        final hrData = performanceReview!.hrReviewData!;
        
        // Check if HR review is already submitted
        final hrDataStatus = hrData['status'] as String? ?? 'Draft';
        _isReadOnly = hrDataStatus == 'Submitted' || hrDataStatus == 'review completed';
        
        // Also check the document-level status
        if (performanceReview.status == 'review completed') {
          _isReadOnly = true;
        }
        
        // Load existing ratings and comments if available
        if (hrData['question_ratings'] != null) {
          final existingRatings = Map<String, double>.from(
            (hrData['question_ratings'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ),
          );
          existingRatings.forEach((key, value) {
            _questionRatings[key] = value;
          });
          print('Loaded ${existingRatings.length} existing HR ratings');
        }
        
        // HR decisions removed - no longer needed
        
        // HR comments removed - no longer needed
        
        // Load overall rating and summary
        if (hrData['overall_rating'] != null) {
          _overallRating = (hrData['overall_rating'] as num).toInt();
        }
        
        if (hrData['overall_summary'] != null) {
          _overallSummary = hrData['overall_summary'] as String;
          _summaryController.text = _overallSummary;
        }
        
        print('Loaded existing HR review. Status: $hrDataStatus, ReadOnly: $_isReadOnly');
      }
    } catch (e) {
      print('Error loading existing HR review: $e');
      // Continue with default values if loading fails
    }
  }

  Future<void> _loadManagerReviewData() async {
    try {
      // Generate manager review ID (type 2 for manager review)
      final quarterLower = widget.review.quarter.toLowerCase().replaceAll(' ', '').replaceAll(widget.review.year.toString(), '');
      final managerReviewId = '${widget.review.year}_${quarterLower}_${widget.review.employeeId}_2';
      
      print('Loading manager review data for ID: $managerReviewId');
      
      // Load existing manager review from performance_reviews collection
      final managerReview = await PerformanceReviewService.getReviewById(managerReviewId);
      
      if (managerReview?.managerReviewData != null) {
        final managerData = managerReview!.managerReviewData!;
        
        print('Manager review data found: ${managerData.keys}');
        
        // Load manager KPI ratings
        if (managerData['question_ratings'] != null) {
          final managerRatings = Map<String, double>.from(
            (managerData['question_ratings'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ),
          );
          _managerRatings.addAll(managerRatings);
          print('Loaded manager ratings: $_managerRatings');
        } else {
          print('No manager question_ratings found in data');
        }
      } else {
        print('No manager review data found for ID: $managerReviewId');
      }
    } catch (e) {
      print('Error loading manager review data: $e');
      // Continue with empty manager data if loading fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'HR Review - ${_employee?.fullName ?? 'Loading...'}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _loadEmployeeData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildHRReviewInterface(),
    );
  }

  Widget _buildHRReviewInterface() {
    if (_selfAssessment == null) {
      return const Center(
        child: Text('No self-assessment data found for this employee.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee Info Card
          _buildEmployeeInfoCard(),
          const SizedBox(height: 20),
          
          // KPI Reviews Section
          _buildKPIReviewsSection(),
          const SizedBox(height: 20),
          
          // Overall Rating and Summary Section
          _buildOverallRatingSection(),
          const SizedBox(height: 20),
          
          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Employee: ${_employee?.fullName ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Email: ${_employee?.email ?? 'Unknown'}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Department: ${_employee?.departmentId ?? 'Unknown'}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Review Period: ${widget.review.quarter} ${widget.review.year}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'KPI Performance Review',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._selfAssessment!.kpiRatings.entries.map((entry) {
            return _buildKPIReviewItem(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildKPIReviewItem(String kpi, double selfRating) {
    final key = 'kpi_$kpi';
    final hrRating = _questionRatings[key] ?? 3.0;
    
    // Get manager rating if available
    final managerRating = _managerRatings[key] ?? 0.0;
    final hasManagerRating = managerRating > 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: const Color(0xFF444444)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kpi,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Three ratings side by side
          Row(
            children: [
              // Self Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Self Rating', 
                      style: TextStyle(
                        fontWeight: FontWeight.w500, 
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStarRating(selfRating, false),
                    const SizedBox(height: 4),
                    Text(
                      selfRating.toStringAsFixed(1), 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Manager Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Manager Rating', 
                      style: TextStyle(
                        fontWeight: FontWeight.w500, 
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    managerRating > 0 
                        ? _buildStarRating(managerRating, false)
                        : const Text(
                            'Not Rated', 
                            style: TextStyle(color: Colors.orange),
                          ),
                    const SizedBox(height: 4),
                    Text(
                      managerRating > 0 ? managerRating.toStringAsFixed(1) : '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // HR Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'HR Rating', 
                      style: TextStyle(
                        fontWeight: FontWeight.w500, 
                        fontSize: 12,
                        color: hasManagerRating ? Colors.white70 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    hasManagerRating 
                        ? _buildStarRating(hrRating, !_isReadOnly, (rating) {
                            setState(() {
                              _questionRatings[key] = rating;
                              _calculateAverageRating();
                            });
                          })
                        : const Text(
                            'Requires Manager Rating', 
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                    const SizedBox(height: 4),
                    Text(
                      hasManagerRating ? hrRating.toStringAsFixed(1) : '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hasManagerRating ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating, bool interactive, [Function(double)? onRatingChanged]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged((index + 1).toDouble())
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 24,
          ),
        );
      }),
    );
  }

  Widget _buildOverallRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Overall Assessment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Average Rating Display
            Row(
              children: [
                const Text('Average KPI Rating: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 8),
                _buildStarRating(_averageRating, false),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overall Rating
            const Text('HR Overall Rating:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildStarRating(_overallRating.toDouble(), !_isReadOnly, (rating) {
              setState(() {
                _overallRating = rating.toInt();
              });
            }),
            const SizedBox(height: 16),
            
            // Overall Summary
            const Text('HR Overall Summary:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _summaryController,
              enabled: !_isReadOnly,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Provide your overall assessment and recommendations...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _overallSummary = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    if (_isReadOnly) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'HR Review Already Submitted',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitHRReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Submit HR Review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _calculateAverageRating() {
    if (_questionRatings.isEmpty) return;
    
    double sum = 0;
    int count = 0;
    
    _questionRatings.forEach((key, rating) {
      if (key.startsWith('kpi_')) {
        sum += rating;
        count++;
      }
    });
    
    _averageRating = count > 0 ? sum / count : 0.0;
  }

  Future<void> _submitHRReview() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm HR Review Submission'),
        content: const Text(
          'Are you sure you want to submit this HR review? Once submitted, it cannot be edited.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Calculate average if not already done
      _calculateAverageRating();
      
      // Submit HR review
      final hrReviewData = {
        'question_ratings': _questionRatings,
        'overall_rating': _overallRating,
        'average_rating': _averageRating,
        'overall_summary': _overallSummary,
        'hr_user_id': widget.userModel.uid,
      };
      
      await PerformanceReviewService.submitHRReview(
        reviewId: widget.review.id,
        hrReviewData: hrReviewData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HR review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Call refresh callback to update parent screen
        widget.onReviewSubmitted?.call();
        
        Navigator.of(context).pop(true); // Return true to indicate successful submission
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting HR review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
