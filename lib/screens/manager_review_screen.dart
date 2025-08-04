import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/performance_review_model.dart';
import '../models/employee_model.dart';
import '../models/self_assessment_model.dart';
import '../services/performance_review_service.dart';
import '../services/employee_service.dart';
import '../services/self_assessment_service.dart';
import '../core/utils/app_theme.dart';

class ManagerReviewScreen extends StatefulWidget {
  final UserModel userModel;
  final PerformanceReviewModel review;

  const ManagerReviewScreen({
    super.key,
    required this.userModel,
    required this.review,
  });

  @override
  State<ManagerReviewScreen> createState() => _ManagerReviewScreenState();
}

class _ManagerReviewScreenState extends State<ManagerReviewScreen> {
  bool _isLoading = true;
  String? _error;
  EmployeeModel? _employee;
  SelfAssessmentModel? _selfAssessment;
  
  // Manager review data
  Map<String, String> _managerDecisions = {}; // 'accept' or 'reject' for each question
  Map<String, String> _managerComments = {}; // Manager comments for each question
  Map<String, double> _questionRatings = {}; // Individual ratings for each question (1-5)
  String _overallSummary = '';
  double _averageRating = 0.0;
  int _overallRating = 0; // Manager's overall rating (separate from average)
  bool _isReadOnly = false;
  
  // HR ratings data (for display only)
  Map<String, double> _hrRatings = {}; // HR ratings for each KPI
  String _hrOverallComments = '';
  int _hrOverallRating = 0;
  
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
      
      // Initialize manager decisions, comments, and ratings for each self-review question
      if (selfAssessment != null) {
        // Initialize for KPI ratings
        selfAssessment.kpiRatings.forEach((kpi, rating) {
          final key = 'kpi_$kpi';
          _managerDecisions[key] = 'pending';
          _managerComments[key] = '';
          _questionRatings[key] = 3.0; // Default rating
        });
        
        // Initialize for text fields
        final textFields = ['achievements', 'challenges', 'goals', 'feedback'];
        for (String field in textFields) {
          _managerDecisions[field] = 'pending';
          _managerComments[field] = '';
          _questionRatings[field] = 3.0; // Default rating
        }
      }

      // Check if manager review already exists and load it
      await _loadExistingManagerReview();
      
      setState(() {
        _employee = employee;
        _selfAssessment = selfAssessment;
        _isLoading = false;
      });
      
      // Don't calculate average rating initially - wait for manager to provide ratings
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Calculate average rating from manager KPI ratings only
  void _calculateAverageRating() {
    // Get KPI ratings from manager's ratings (exclude text-based questions)
    final kpiRatingValues = <double>[];
    
    // Add KPI ratings from self-assessment that manager has rated
    if (_selfAssessment != null) {
      _selfAssessment!.kpiRatings.forEach((kpi, rating) {
        final kpiKey = 'kpi_$kpi'; // Use the prefixed key format
        if (_questionRatings.containsKey(kpiKey)) {
          final managerRating = _questionRatings[kpiKey]!;
          kpiRatingValues.add(managerRating);
        }
      });
    }
    
    // Calculate average if there are KPI ratings
    // For submitted reviews, always calculate the average
    // For new reviews, only calculate if manager has made changes or if it's read-only (submitted)
    if (kpiRatingValues.isNotEmpty) {
      if (_isReadOnly) {
        // If read-only (submitted), always show the actual average
        double sum = kpiRatingValues.reduce((a, b) => a + b);
        _averageRating = sum / kpiRatingValues.length;
      } else {
        // For editable reviews, check if manager has made any changes from defaults
        bool hasNonDefaultRatings = kpiRatingValues.any((rating) => rating != 3.0);
        if (hasNonDefaultRatings) {
          double sum = kpiRatingValues.reduce((a, b) => a + b);
          _averageRating = sum / kpiRatingValues.length;
        } else {
          _averageRating = 0.0; // Show 0.0 until manager provides actual ratings
        }
      }
    } else {
      _averageRating = 0.0;
    }
    
    print('Average rating calculated: $_averageRating from ${kpiRatingValues.length} KPI ratings (isReadOnly: $_isReadOnly)');
  }

  Future<void> _loadExistingManagerReview() async {
    try {
      // Generate manager review ID (type 2 for manager review)
      final quarterLower = widget.review.quarter.toLowerCase().replaceAll(' ', '').replaceAll(widget.review.year.toString(), '');
      final managerReviewId = '${widget.review.year}_${quarterLower}_${widget.review.employeeId}_2';
      
      // Load existing manager review from performance_reviews collection
      final performanceReview = await PerformanceReviewService.getReviewById(managerReviewId);
      
      if (performanceReview?.managerReviewData != null) {
        final managerData = performanceReview!.managerReviewData!;
        
        // Check if manager review is already submitted
        final managerDataStatus = managerData['status'] as String? ?? 'Draft';
        _isReadOnly = managerDataStatus == 'Submitted' || managerDataStatus == 'manager review completed';
        
        // Also check the document-level status
        if (performanceReview.status == 'manager review completed') {
          _isReadOnly = true;
        }
        
        // CRITICAL: Check if HR has completed their review - if so, manager review must be permanently read-only
        await _checkHRCompletionStatus();
        
        // Also check if the original self-review document has 'review completed' status (indicates HR completion)
        if (widget.review.status == 'review completed') {
          _isReadOnly = true;
          print('Manager review set to read-only: HR review has been completed');
        }
        
        // Load existing ratings and comments if available
        if (managerData['question_ratings'] != null) {
          final existingRatings = Map<String, double>.from(
            (managerData['question_ratings'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ),
          );
          _questionRatings.addAll(existingRatings);
        }
        
        // Load existing manager decisions
        if (managerData['manager_decisions'] != null) {
          final existingDecisions = Map<String, String>.from(
            managerData['manager_decisions'] as Map<String, dynamic>,
          );
          _managerDecisions.addAll(existingDecisions);
        }
        
        // Load existing manager comments
        if (managerData['manager_comments'] != null) {
          final existingComments = Map<String, String>.from(
            managerData['manager_comments'] as Map<String, dynamic>,
          );
          _managerComments.addAll(existingComments);
        }
        
        // Load overall rating and summary
        if (managerData['overall_rating'] != null) {
          _overallRating = (managerData['overall_rating'] as num).toInt();
        }
        
        if (managerData['overall_summary'] != null) {
          _overallSummary = managerData['overall_summary'] as String;
          _summaryController.text = _overallSummary;
        }
        
        // Calculate average rating if ratings exist
        _calculateAverageRating();
        
        print('Loaded existing manager review. Status: $managerDataStatus, ReadOnly: $_isReadOnly');
      }
      
      // Also load HR review data if it exists (for display purposes)
      await _loadHRReviewData();
    } catch (e) {
      print('Error loading existing manager review: $e');
      // Continue with default values if loading fails
    }
  }

  Future<void> _checkHRCompletionStatus() async {
    try {
      // Generate HR review ID (type 3 for HR review)
      final quarterLower = widget.review.quarter.toLowerCase().replaceAll(' ', '').replaceAll(widget.review.year.toString(), '');
      final hrReviewId = '${widget.review.year}_${quarterLower}_${widget.review.employeeId}_3';
      
      // Check if HR review document exists and is completed
      final hrReview = await PerformanceReviewService.getReviewById(hrReviewId);
      
      if (hrReview != null) {
        // If HR review exists and has 'review completed' status, manager review must be read-only
        if (hrReview.status == 'review completed') {
          _isReadOnly = true;
          print('Manager review set to read-only: HR review found with completed status');
        }
      }
    } catch (e) {
      print('Error checking HR completion status: $e');
      // Continue without setting read-only if check fails
    }
  }

  Future<void> _loadHRReviewData() async {
    try {
      // Generate HR review ID (type 3 for HR review)
      final quarterLower = widget.review.quarter.toLowerCase().replaceAll(' ', '').replaceAll(widget.review.year.toString(), '');
      final hrReviewId = '${widget.review.year}_${quarterLower}_${widget.review.employeeId}_3';
      
      // Load existing HR review from performance_reviews collection
      final hrReview = await PerformanceReviewService.getReviewById(hrReviewId);
      
      if (hrReview?.hrReviewData != null) {
        final hrData = hrReview!.hrReviewData!;
        
        // Load HR KPI ratings
        if (hrData['question_ratings'] != null) {
          final hrRatings = Map<String, double>.from(
            (hrData['question_ratings'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ),
          );
          _hrRatings.addAll(hrRatings);
        }
        
        // Load HR overall rating and comments
        if (hrData['overall_rating'] != null) {
          _hrOverallRating = (hrData['overall_rating'] as num).toInt();
        }
        
        if (hrData['overall_comments'] != null) {
          _hrOverallComments = hrData['overall_comments'] as String;
        }
        
        print('Loaded HR review data. HR ratings: ${_hrRatings.length}, Overall rating: $_hrOverallRating');
      } else {
        print('No HR review data found for ID: $hrReviewId');
      }
    } catch (e) {
      print('Error loading HR review data: $e');
      // Continue with empty HR data if loading fails
    }
  }

  Future<bool> _showSubmissionConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Confirm Submission',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to submit this manager review? Once submitted, it cannot be edited.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Review'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _submitManagerReview() async {
    // Show confirmation dialog before submitting
    final confirmed = await _showSubmissionConfirmationDialog();
    if (!confirmed) return;
    
    // Calculate the average rating
    _calculateAverageRating();
    
    // Check if manager has provided actual ratings (not just defaults)
    bool hasActualRatings = false;
    if (_selfAssessment != null) {
      _selfAssessment!.kpiRatings.forEach((kpi, rating) {
        final kpiKey = 'kpi_$kpi';
        if (_questionRatings.containsKey(kpiKey) && _questionRatings[kpiKey] != 3.0) {
          hasActualRatings = true;
        }
      });
    }
    
    if (!hasActualRatings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide ratings for KPI questions'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an overall rating'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_overallSummary.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an overall summary'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Note: Accept/reject decisions are no longer required since those buttons were removed from UI
    // Manager just needs to provide ratings and summary

    try {
      setState(() => _isLoading = true);

      final managerReviewData = {
        'manager_decisions': _managerDecisions,
        'manager_comments': _managerComments,
        'question_ratings': _questionRatings,
        'average_rating': _averageRating,
        'overall_rating': _overallRating,
        'overall_summary': _overallSummary,
        'reviewed_by': widget.userModel.uid,
        'reviewed_at': DateTime.now().toIso8601String(),
      };

      await PerformanceReviewService.submitManagerReview(
        reviewId: widget.review.id,
        managerReviewData: managerReviewData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manager review submitted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          'Manager Review - ${_employee?.firstName ?? ''} ${_employee?.lastName ?? ''}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
              : _buildReviewContent(),
    );
  }

  Widget _buildReviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmployeeHeader(),
          const SizedBox(height: 24),
          _buildSelfReviewSection(),
          const SizedBox(height: 24),
          _buildOverallReviewSection(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildEmployeeHeader() {
    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                '${_employee?.firstName[0] ?? ''}${_employee?.lastName[0] ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_employee?.firstName ?? ''} ${_employee?.lastName ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Review Period: ${widget.review.quarter} ${widget.review.year}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Status: ${widget.review.statusDisplayText}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfReviewSection() {
    if (_selfAssessment == null) {
      return Card(
        color: const Color(0xFF2A2A2A),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'No self-review data available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Self-Review Answers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // KPI Ratings Section - Show self-rating and allow manager rating
        const Text(
          'KPI Ratings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._selfAssessment!.kpiRatings.entries.map((entry) {
          return _buildKpiRatingCard(entry.key, entry.value.toInt());
        }).toList(),
        
        const SizedBox(height: 24),
        
        // Text Information Section - Read-only display
        const Text(
          'Employee Responses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (_selfAssessment!.achievements.isNotEmpty)
          _buildTextInfoCard('Achievements', _selfAssessment!.achievements),
        if (_selfAssessment!.challenges.isNotEmpty)
          _buildTextInfoCard('Challenges', _selfAssessment!.challenges),
        if (_selfAssessment!.goals.isNotEmpty)
          _buildTextInfoCard('Goals', _selfAssessment!.goals),
        if (_selfAssessment!.feedback.isNotEmpty)
          _buildTextInfoCard('Additional Feedback', _selfAssessment!.feedback),
      ],
    );
  }

  // New method for KPI ratings - shows self-rating and allows manager rating
  Widget _buildKpiRatingCard(String kpiName, int selfRating) {
    final questionKey = 'kpi_$kpiName';
    return Card(
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kpiName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // All three ratings in same row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                children: [
                  // Employee self-rating (left side)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Self Rating:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < selfRating ? Icons.star : Icons.star_border,
                                color: index < selfRating ? Colors.amber : Colors.grey,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              '$selfRating/5',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider
                  Container(
                    height: 50,
                    width: 1,
                    color: const Color(0xFF333333),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  
                  // Manager rating (middle)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Rating:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              final rating = index + 1;
                              final currentRating = (_questionRatings[questionKey] ?? 3.0).round();
                              return GestureDetector(
                                onTap: _isReadOnly ? null : () {
                                  setState(() {
                                    _questionRatings[questionKey] = rating.toDouble();
                                    _calculateAverageRating(); // Recalculate average when star rating changes
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 1),
                                  child: Icon(
                                    rating <= currentRating ? Icons.star : Icons.star_border,
                                    color: rating <= currentRating ? Colors.amber : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              '${(_questionRatings[questionKey] ?? 3.0).round()}/5',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider
                  Container(
                    height: 50,
                    width: 1,
                    color: const Color(0xFF333333),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  
                  // HR rating (right side)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HR Rating:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Builder(
                          builder: (context) {
                            final hrRating = _hrRatings[questionKey]?.round() ?? 0;
                            if (hrRating == 0) {
                              return const Text(
                                'Not rated yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }
                            return Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < hrRating ? Icons.star : Icons.star_border,
                                    color: index < hrRating ? Colors.green : Colors.grey,
                                    size: 20,
                                  );
                                }),
                                const SizedBox(width: 4),
                                Text(
                                  '$hrRating/5',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // New method for text information - read-only display
  Widget _buildTextInfoCard(String title, String content) {
    return Card(
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Text(
                content,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewQuestionCard(String questionKey, String answer) {
    return Card(
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question: ${questionKey.replaceAll('_', ' ').toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Text(
                answer,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _managerDecisions[questionKey] = 'accept'),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _managerDecisions[questionKey] == 'accept'
                          ? AppTheme.successColor
                          : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _managerDecisions[questionKey] = 'reject'),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _managerDecisions[questionKey] == 'reject'
                          ? AppTheme.errorColor
                          : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Rating slider for this question
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rating: ${_questionRatings[questionKey]?.toStringAsFixed(1) ?? '3.0'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _questionRatings[questionKey] ?? 3.0,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8, // 0.5 increments
                  activeColor: AppTheme.primaryColor,
                  inactiveColor: Colors.grey,
                  onChanged: (value) {
                    setState(() {
                      _questionRatings[questionKey] = value;
                      _calculateAverageRating(); // Recalculate average in real-time
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('1.0', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Text('3.0', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Text('5.0', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => _managerComments[questionKey] = value,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Manager Comments (Optional)',
                labelStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF333333)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overall Review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF2A2A2A),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating Summary Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF444444)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rating Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Average Rating Display
                      Row(
                        children: [
                          const Text(
                            'Average Rating:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '0.0',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_averageRating > 0) ...
                            List.generate(5, (index) {
                              return Icon(
                                index < _averageRating ? Icons.star : Icons.star_border,
                                color: index < _averageRating ? Colors.amber : Colors.grey,
                                size: 16,
                              );
                            }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Overall Rating Display
                      Row(
                        children: [
                          const Text(
                            'Overall Rating:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _overallRating > 0 ? _overallRating.toString() : 'Not set',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_overallRating > 0) ...
                            List.generate(5, (index) {
                              return Icon(
                                index < _overallRating ? Icons.star : Icons.star_border,
                                color: index < _overallRating ? Colors.blue : Colors.grey,
                                size: 16,
                              );
                            }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Overall Rating Section
                const Text(
                  'Overall Rating (1-5)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: _isReadOnly ? null : () => setState(() => _overallRating = index + 1),
                      child: Icon(
                        index < _overallRating ? Icons.star : Icons.star_border,
                        color: index < _overallRating ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Overall Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _summaryController,
                  onChanged: _isReadOnly ? null : (value) => _overallSummary = value,
                  enabled: !_isReadOnly,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Provide an overall summary of the employee\'s performance...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF333333)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    if (_isReadOnly) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: const Text(
          'Review Already Submitted',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitManagerReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Submit Manager Review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
