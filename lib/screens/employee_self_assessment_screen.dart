import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/self_assessment_model.dart';
import '../models/performance_review_model.dart';
import '../services/self_assessment_service.dart';
import '../services/performance_review_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class EmployeeSelfAssessmentScreen extends StatefulWidget {
  final UserModel userModel;

  const EmployeeSelfAssessmentScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<EmployeeSelfAssessmentScreen> createState() => _EmployeeSelfAssessmentScreenState();
}

class _EmployeeSelfAssessmentScreenState extends State<EmployeeSelfAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isReadOnly = false;
  
  String? _employeeId;
  String _selectedQuarter = '';
  int _selectedYear = 0;
  SelfAssessmentModel? _currentAssessment;
  PerformanceReviewModel? _performanceReview;
  Map<String, double>? _managerRatings;
  Map<String, double>? _hrRatings;
  Map<String, String>? _managerComments;
  Map<String, String>? _hrComments;
  
  // Assessment data
  final Map<String, double> _kpiRatings = {
    'Technical Skills': 3.0,
    'Communication': 3.0,
    'Teamwork': 3.0,
    'Problem Solving': 3.0,
    'Leadership': 3.0,
    'Innovation': 3.0,
    'Quality of Work': 3.0,
    'Meeting Deadlines': 3.0,
  };
  
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _challengesController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _managerRatings = {};
    _hrRatings = {};
    _managerComments = {};
    _hrComments = {};
    _loadEmployeeData();
    _initializeQuarterSelection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data whenever the screen becomes active (e.g., tab navigation)
    if (_employeeId != null) {
      _loadAssessmentData();
    }
  }

  @override
  void dispose() {
    _achievementsController.dispose();
    _challengesController.dispose();
    _goalsController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final employee = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      setState(() {
        _employeeId = employee.id;
      });
      _loadAssessmentData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading employee data: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _initializeQuarterSelection() {
    final currentQuarter = SelfAssessmentService.getCurrentQuarter();
    final currentYear = SelfAssessmentService.getCurrentYear();
    setState(() {
      _selectedQuarter = currentQuarter;
      _selectedYear = currentYear;
    });
  }

  // Comprehensive method to fetch and segregate all ratings for the user
  Future<void> _fetchAndSegregateAllRatings() async {
    try {
      print('🔍 Fetching ALL reviews for employee ID: $_employeeId');
      
      // Initialize/reset all rating maps and UI state
      setState(() {
        _managerRatings = {};
        _hrRatings = {};
        _managerComments = {};
        _hrComments = {};
        // Reset performance review object to clear stale status
        _performanceReview = null;
        // Reset read-only state
        _isReadOnly = false;
      });
      
      // 1. Get ALL reviews for this employee ID
      final allReviews = await PerformanceReviewService.getReviewsByEmployeeId(_employeeId!);
      print('📋 Found ${allReviews.length} total reviews for employee');
      
      // Filter reviews for the selected quarter and year
      final quarterReviews = allReviews.where((review) => 
        review.quarter == _selectedQuarter && review.year == _selectedYear
      ).toList();
      
      print('📅 Found ${quarterReviews.length} reviews for $_selectedQuarter $_selectedYear');
      
      // 2. Segregate reviews by type and extract data
      bool hasSelfRating = false;
      bool hasManagerRating = false;
      bool hasHRRating = false;
      
      for (final review in quarterReviews) {
        print('🔍 Processing review ID: ${review.id}');
        print('   📋 selfReviewData: ${review.selfReviewData != null ? "EXISTS (${review.selfReviewData!.keys.toList()})" : "NULL"}');
        print('   📋 managerReviewData: ${review.managerReviewData != null ? "EXISTS (${review.managerReviewData!.keys.toList()})" : "NULL"}');
        print('   📋 hrReviewData: ${review.hrReviewData != null ? "EXISTS (${review.hrReviewData!.keys.toList()})" : "NULL"}');
        
        // Check if this is a self-assessment (contains self_assessment_data)
        // First check in selfReviewData, then check document root
        Map<String, dynamic>? selfAssessmentData;
        
        if (review.selfReviewData != null && review.selfReviewData!.isNotEmpty) {
          final selfData = review.selfReviewData!;
          if (selfData['self_assessment_data'] != null) {
            selfAssessmentData = selfData['self_assessment_data'] as Map<String, dynamic>;
            print('📋 Found self_assessment_data in selfReviewData');
          }
        }
        
        // If not found in selfReviewData, check if self_assessment_data exists directly in document
        if (selfAssessmentData == null) {
          // The logs show self_assessment_data exists but selfReviewData is null
          // This means the document has self_assessment_data field directly
          // Let's try to access it through the document's raw data
          try {
            // Since the model maps from 'self_review_data' but our document has 'self_assessment_data'
            // we need to check the original document structure
            final reviewData = review.toJson();
            
            // Check multiple possible locations for the self assessment data
            if (reviewData['self_assessment_data'] != null) {
              selfAssessmentData = reviewData['self_assessment_data'] as Map<String, dynamic>;
              print('📋 Found self_assessment_data in document root');
            } else {
              // Also check if it's nested under a different structure
              print('🔍 Available fields in document: ${reviewData.keys.toList()}');
              
              // Check each field to see if any contains self_assessment_data
              for (final key in reviewData.keys) {
                final value = reviewData[key];
                if (value is Map<String, dynamic> && value['self_assessment_data'] != null) {
                  selfAssessmentData = value['self_assessment_data'] as Map<String, dynamic>;
                  print('📋 Found self_assessment_data nested under: $key');
                  break;
                }
              }
            }
          } catch (e) {
            print('⚠️ Error accessing document root data: $e');
          }
        }
        
        // Extract KPI ratings if self_assessment_data was found
        if (selfAssessmentData != null && selfAssessmentData['kpi_ratings'] != null) {
          final selfKpiRatings = selfAssessmentData['kpi_ratings'] as Map<String, dynamic>;
          setState(() {
            _kpiRatings.clear();
            selfKpiRatings.forEach((key, value) {
              _kpiRatings[key] = (value as num).toDouble();
            });
          });
          hasSelfRating = true;
          print('✅ Self ratings found: $_kpiRatings');
        }
        
        // Check if this is a manager review (contains manager_review_data)
        if (review.managerReviewData != null && review.managerReviewData!.isNotEmpty) {
          final managerData = review.managerReviewData!;
          if (managerData['question_ratings'] != null) {
            final managerKpiRatings = managerData['question_ratings'] as Map<String, dynamic>;
            setState(() {
              _managerRatings = {};
              managerKpiRatings.forEach((key, value) {
                String kpiName = key;
                if (key.startsWith('kpi_')) {
                  kpiName = key.substring(4);
                }
                _managerRatings?[kpiName] = (value as num).toDouble();
              });
            });
            
            // Load manager comments
            if (managerData['manager_comments'] != null) {
              final managerComments = managerData['manager_comments'] as Map<String, dynamic>;
              setState(() {
                _managerComments = {};
                managerComments.forEach((key, value) {
                  String kpiName = key;
                  if (key.startsWith('kpi_')) {
                    kpiName = key.substring(4);
                  }
                  _managerComments?[kpiName] = value.toString();
                });
              });
            }
            
            hasManagerRating = true;
            print('✅ Manager ratings found: $_managerRatings');
            print('✅ Manager comments found: $_managerComments');
          }
        }
        
        // Check if this is an HR review (contains hr_review_data)
        if (review.hrReviewData != null && review.hrReviewData!.isNotEmpty) {
          final hrData = review.hrReviewData!;
          if (hrData['question_ratings'] != null) {
            final hrKpiRatings = hrData['question_ratings'] as Map<String, dynamic>;
            setState(() {
              _hrRatings = {};
              hrKpiRatings.forEach((key, value) {
                String kpiName = key;
                if (key.startsWith('kpi_')) {
                  kpiName = key.substring(4);
                }
                _hrRatings?[kpiName] = (value as num).toDouble();
              });
            });
            
            // Load HR comments (if available) - HR typically doesn't have per-KPI comments
            if (hrData['hr_comments'] != null) {
              final hrComments = hrData['hr_comments'] as Map<String, dynamic>;
              setState(() {
                _hrComments = {};
                hrComments.forEach((key, value) {
                  String kpiName = key;
                  if (key.startsWith('kpi_')) {
                    kpiName = key.substring(4);
                  }
                  _hrComments?[kpiName] = value.toString();
                });
              });
            }
            
            hasHRRating = true;
            print('✅ HR ratings found: $_hrRatings');
            print('✅ HR comments found: $_hrComments');
          }
        }
      }
      
      // 3. Set the main performance review for status display
      if (quarterReviews.isNotEmpty) {
        setState(() {
          _performanceReview = quarterReviews.first;
        });
      } else {
        // If no reviews found for this quarter, ensure all data is cleared
        setState(() {
          _performanceReview = null;
          // Reset self-rating data to default values for empty quarter
          _kpiRatings.clear();
          _kpiRatings.addAll({
            'Technical Skills': 3.0,
            'Communication': 3.0,
            'Teamwork': 3.0,
            'Problem Solving': 3.0,
            'Leadership': 3.0,
            'Innovation': 3.0,
            'Quality of Work': 3.0,
            'Meeting Deadlines': 3.0,
          });
          _isReadOnly = false;
        });
        print('🔄 No reviews found for $_selectedQuarter $_selectedYear - Reset to default state');
      }
      
      // 4. Set read-only flag if self-assessment is completed
      if (hasSelfRating) {
        setState(() {
          _isReadOnly = true;
        });
        print('🔒 Self-assessment completed - Setting read-only mode');
      }
      
      // 5. Determine and log the current state
      String currentState;
      if (!hasSelfRating) {
        currentState = '🔴 SELF RATING PENDING - Employee needs to complete self-assessment';
      } else if (!hasManagerRating) {
        currentState = '🟡 MANAGER RATING PENDING - Manager needs to complete review';
      } else if (!hasHRRating) {
        currentState = '🟠 HR RATING PENDING - HR needs to complete review';
      } else {
        currentState = '🟢 ALL RATINGS COMPLETED - Review process finished';
      }
      
      print('\n📊 RATING SEGREGATION SUMMARY:');
      print('Self Rating: ${hasSelfRating ? "✅" : "❌"} ${hasSelfRating ? _kpiRatings.length : 0} KPIs');
      print('Manager Rating: ${hasManagerRating ? "✅" : "❌"} ${hasManagerRating ? _managerRatings!.length : 0} KPIs');
      print('HR Rating: ${hasHRRating ? "✅" : "❌"} ${hasHRRating ? _hrRatings!.length : 0} KPIs');
      print('Current State: $currentState\n');
      
      // Log missing ratings for debugging
      if (!hasManagerRating) {
        print('❌ No manager ratings found - Manager review may not be completed yet');
      }
      if (!hasHRRating) {
        print('❌ No HR ratings found - HR review may not be completed yet');
      }
      
    } catch (e) {
      print('❌ Error fetching and segregating ratings: $e');
    }
  }

  // Note: Removed _loadManagerReviewData and _loadHRReviewData methods
  // Now using comprehensive _fetchAndSegregateAllRatings method instead

  Future<void> _loadAssessmentData() async {
    if (_employeeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch and segregate all ratings for this user
      await _fetchAndSegregateAllRatings();
      
      // Load self-assessment data if available
      final assessment = await SelfAssessmentService.getSelfAssessmentByEmployeeAndQuarter(
        _employeeId!,
        _selectedQuarter,
        _selectedYear,
      );

      setState(() {
        _currentAssessment = assessment;
        
        // Determine read-only state based on self-rating submission
        bool hasSelfRating = _kpiRatings.isNotEmpty && _kpiRatings.values.any((rating) => rating != 3.0);
        bool isSubmitted = assessment?.status == 'Submitted';
        
        // Once self-rating is done, it should never be editable again
        _isReadOnly = isSubmitted || hasSelfRating || !SelfAssessmentService.isCurrentQuarter(_selectedQuarter, _selectedYear);
      });

      if (assessment != null) {
        // Load existing self-assessment data only if no performance review data was found
        // This prevents overwriting quarter-specific data from performance reviews
        bool hasPerformanceReviewData = _kpiRatings.isNotEmpty && _kpiRatings.values.any((rating) => rating != 3.0);
        
        if (!hasPerformanceReviewData) {
          // Only load from self-assessment if no performance review data exists
          _kpiRatings.clear();
          _kpiRatings.addAll(assessment.kpiRatings);
        }
        
        // Always load text fields from self-assessment
        _achievementsController.text = assessment.achievements;
        _challengesController.text = assessment.challenges;
        _goalsController.text = assessment.goals;
        _feedbackController.text = assessment.feedback;
      } else {
        // Initialize default values for new assessment only if no self-rating exists
        if (_kpiRatings.isEmpty || _kpiRatings.values.every((rating) => rating == 3.0)) {
          _kpiRatings.addAll({
            'Technical Skills': 3.0,
            'Communication': 3.0,
            'Teamwork': 3.0,
            'Problem Solving': 3.0,
            'Leadership': 3.0,
            'Innovation': 3.0,
            'Quality of Work': 3.0,
            'Meeting Deadlines': 3.0,
          });
        }
        _achievementsController.clear();
        _challengesController.clear();
        _goalsController.clear();
        _feedbackController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading assessment data: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onQuarterChanged(String? newValue) {
    if (newValue == null) return;
    
    final parts = newValue.split(' ');
    final quarter = parts[0];
    final year = int.parse(parts[1]);
    
    setState(() {
      _selectedQuarter = quarter;
      _selectedYear = year;
    });
    
    _loadAssessmentData();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.buildResponsiveLayout(
      context: context,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                
                // Assessment Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // KPI Ratings Section
                      ResponsiveUtils.buildResponsiveSection(
                        context: context,
                        title: 'KPI Self-Ratings',
                        icon: Icons.assessment,
                        children: [
                          Text(
                            'Rate yourself on a scale of 1-5 for each competency area:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getBodyFontSize(context),
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context)),
                          _buildKPIRatings(),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                      
                      // Achievements Section
                      ResponsiveUtils.buildResponsiveSection(
                        context: context,
                        title: 'Key Achievements',
                        icon: Icons.star,
                        children: [
                          TextFormField(
                            controller: _achievementsController,
                            enabled: !_isReadOnly,
                            maxLines: ResponsiveUtils.isMobile(context) ? 4 : 6,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Describe your key achievements and accomplishments...',
                              hintStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF333333)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF333333)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.primaryColor),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              contentPadding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                      
                      // Challenges Section
                      ResponsiveUtils.buildResponsiveSection(
                        context: context,
                        title: 'Challenges Faced',
                        icon: Icons.warning,
                        children: [
                          TextFormField(
                            controller: _challengesController,
                            enabled: !_isReadOnly,
                            maxLines: ResponsiveUtils.isMobile(context) ? 4 : 6,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Describe the challenges you faced and how you overcame them...',
                              hintStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF333333)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF333333)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.primaryColor),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              contentPadding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                      
                      // Goals Section
                      ResponsiveUtils.buildResponsiveSection(
                        context: context,
                        title: 'Future Goals',
                        icon: Icons.flag,
                        children: [
                          TextFormField(
                            controller: _goalsController,
                            enabled: !_isReadOnly,
                            maxLines: ResponsiveUtils.isMobile(context) ? 4 : 6,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Describe your goals for the next period...',
                              hintStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF333333)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF333333)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.primaryColor),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              contentPadding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                      
                      // Feedback Section
                      ResponsiveUtils.buildResponsiveSection(
                        context: context,
                        title: 'Feedback & Suggestions',
                        icon: Icons.feedback,
                        children: [
                          TextFormField(
                            controller: _feedbackController,
                            enabled: !_isReadOnly,
                            maxLines: ResponsiveUtils.isMobile(context) ? 4 : 6,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Share your feedback and suggestions for improvement...',
                              hintStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF333333)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF333333)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.primaryColor),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              contentPadding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                      
                      // Submit Button (only show if not read-only)
                      if (!_isReadOnly) _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assessment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
              Text(
                _isReadOnly 
                    ? 'View your submitted assessment'
                    : 'Evaluate your performance and set goals',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                ),
              ),
              if (_currentAssessment?.submittedDate != null) ...[
                SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
                Text(
                  'Submitted: ${_currentAssessment!.submittedDate!.toString().split(' ')[0]}',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              // Show performance review status
              if (_performanceReview != null) ...[
                SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_performanceReview!.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusDisplayText(_performanceReview!.status),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.getSmallFontSize(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getSpacing(context),
            vertical: ResponsiveUtils.getSpacing(context) / 2,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: '$_selectedQuarter $_selectedYear',
              dropdownColor: const Color(0xFF2A2A2A),
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getBodyFontSize(context),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.textSecondary,
                size: ResponsiveUtils.getSmallIconSize(context),
              ),
              items: SelfAssessmentService.getAvailableQuarters().map((String quarter) {
                return DropdownMenuItem<String>(
                  value: quarter,
                  child: Text(quarter),
                );
              }).toList(),
              onChanged: _onQuarterChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIRatings() {
    // Always show comparison ratings once self-assessment is completed
    // This allows employees to see their ratings and pending manager/HR ratings
    final hasSelfRatings = _kpiRatings.isNotEmpty;
    final showComparisonRatings = hasSelfRatings && _isReadOnly; // Show comparison when self-assessment is completed
    
    return Column(
      children: _kpiRatings.entries.map((entry) {
        final selfRating = entry.value.round();
        final managerRating = _managerRatings?[entry.key]?.round() ?? 0;
        
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context) / 2),
          child: showComparisonRatings
              ? _buildComparisonRatingCard(entry.key, selfRating, managerRating)
              : _buildSingleRatingRow(entry.key, entry.value),
        );
      }).toList(),
    );
  }

  // Build comprehensive comparison card showing self, manager, and HR ratings with comments
  Widget _buildComparisonRatingCard(String kpiName, int selfRating, int managerRating) {
    final hrRating = _hrRatings?[kpiName]?.round() ?? 0;
    final selfComment = ''; // Comments not available in current model
    final managerComment = _managerComments?[kpiName] ?? '';
    final hrComment = _hrComments?[kpiName] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kpiName,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Horizontal layout with all three ratings side-by-side
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              children: [
                // Self Rating (Left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Rating:',
                        style: TextStyle(
                          color: Colors.white,
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
                              size: 18,
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
                      if (selfComment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B2A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF415A77)),
                          ),
                          child: Text(
                            selfComment,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Divider
                Container(
                  height: 80,
                  width: 1,
                  color: const Color(0xFF333333),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                
                // Manager Rating (Middle)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Manager Rating:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (managerRating == 0)
                            const Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < managerRating ? Icons.star : Icons.star_border,
                              color: index < managerRating ? Colors.amber : Colors.grey,
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            managerRating > 0 ? '$managerRating/5' : 'Not rated',
                            style: TextStyle(
                              color: managerRating > 0 ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (managerComment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Text(
                            managerComment,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Divider
                Container(
                  height: 80,
                  width: 1,
                  color: const Color(0xFF333333),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                
                // HR Rating (Right)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'HR Rating:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (hrRating == 0)
                            const Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < hrRating ? Icons.star : Icons.star_border,
                              color: index < hrRating ? Colors.green : Colors.grey,
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            hrRating > 0 ? '$hrRating/5' : 'Not rated',
                            style: TextStyle(
                              color: hrRating > 0 ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (hrComment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Text(
                            hrComment,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build single rating row (original slider-based display)
  Widget _buildSingleRatingRow(String kpiName, double rating) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            kpiName,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context)),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              ...List.generate(5, (index) {
                final starRating = index + 1;
                final isSelected = starRating <= rating.round();
                return GestureDetector(
                  onTap: _isReadOnly ? null : () {
                    setState(() {
                      _kpiRatings[kpiName] = starRating.toDouble();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected ? Colors.amber : Colors.grey,
                      size: 28,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${rating.round()}/5',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getSmallFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getSpacing(context) / 2,
            vertical: ResponsiveUtils.getSpacing(context) / 3,
          ),
          decoration: BoxDecoration(
            color: _getRatingColor(rating).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rating.toString(),
            style: TextStyle(
              color: _getRatingColor(rating),
              fontSize: ResponsiveUtils.getSmallFontSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    // If assessment is already submitted (read-only), show appropriate status
    if (_isReadOnly || (_currentAssessment?.status != null && 
        (_currentAssessment!.status == 'Submitted' || 
         _currentAssessment!.status == 'awaiting manager review' ||
         _currentAssessment!.status == 'self review completed' ||
         _currentAssessment!.status == 'review completed'))) {
      
      // Use the same status logic as the top status display for consistency
      String statusMessage;
      Color statusColor;
      IconData statusIcon;
      
      // Data-driven status determination based on segregated ratings
      final hasSelfRating = _currentAssessment != null && _currentAssessment!.kpiRatings.isNotEmpty;
      final hasManagerRatings = _managerRatings != null && _managerRatings!.isNotEmpty;
      final hasHRRatings = _hrRatings != null && _hrRatings!.isNotEmpty;
      
      // Status logic based on actual data presence
      if (hasHRRatings) {
        // All ratings completed
        statusMessage = 'Review Completed';
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
      } else if (hasManagerRatings) {
        // Manager completed, awaiting HR
        statusMessage = 'Awaiting HR Review';
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
      } else if (hasSelfRating) {
        // Self completed, awaiting manager
        statusMessage = 'Awaiting Manager Review';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      } else {
        // No ratings yet, self-assessment pending
        statusMessage = 'Complete Self Assessment';
        statusColor = Colors.grey;
        statusIcon = Icons.assignment;
      }
      
      return Container(
        width: double.infinity,
        padding: ResponsiveUtils.getButtonPadding(context),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              statusMessage,
              style: TextStyle(
                color: statusColor,
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitAssessment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: ResponsiveUtils.getButtonPadding(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                height: ResponsiveUtils.getSmallIconSize(context),
                width: ResponsiveUtils.getSmallIconSize(context),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _currentAssessment != null ? 'Update Assessment' : 'Submit Assessment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return AppTheme.successColor;
    if (rating >= 3.5) return AppTheme.primaryColor;
    if (rating >= 2.5) return AppTheme.warningColor;
    return AppTheme.errorColor;
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
            'Are you sure you want to submit this self-assessment? Once submitted, it cannot be edited.',
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
              child: const Text('Submit Assessment'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _submitAssessment() async {
    if (_formKey.currentState!.validate() && _employeeId != null) {
      // Show confirmation dialog before submitting
      final confirmed = await _showSubmissionConfirmationDialog();
      if (!confirmed) return;
      setState(() {
        _isSubmitting = true;
      });

      try {
        final assessment = SelfAssessmentModel(
          id: _currentAssessment?.id ?? '',
          employeeId: _employeeId!,
          quarter: _selectedQuarter,
          year: _selectedYear,
          kpiRatings: Map.from(_kpiRatings),
          achievements: _achievementsController.text,
          challenges: _challengesController.text,
          goals: _goalsController.text,
          feedback: _feedbackController.text,
          status: 'awaiting manager review',
          submittedDate: DateTime.now(),
          createdAt: _currentAssessment?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        bool success;
        if (_currentAssessment != null) {
          // Update the existing assessment
          success = await SelfAssessmentService.updateSelfAssessment(assessment);
        } else {
          // Create new assessment
          success = await SelfAssessmentService.createSelfAssessment(assessment);
        }

        // Now submit the assessment to change status to 'self review completed'
        if (success) {
          success = await SelfAssessmentService.submitSelfAssessment(
            _employeeId!,
            _selectedQuarter,
            _selectedYear,
          );
        }

        if (success) {
          // Update the current assessment reference
          setState(() {
            _currentAssessment = assessment;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_currentAssessment != null 
                  ? 'Assessment updated successfully!' 
                  : 'Assessment submitted successfully!'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting assessment: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Helper method to get status display color
  Color _getStatusColor(String status) {
    switch (status) {
      case PerformanceReviewModel.STATUS_AWAITING_SELF_REVIEW:
        return Colors.orange;
      case PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED:
        return Colors.blue;
      case PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED:
        return Colors.purple;
      case PerformanceReviewModel.STATUS_REVIEW_COMPLETED:
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status display text
  String _getStatusDisplayText(String status) {
    switch (status) {
      case PerformanceReviewModel.STATUS_AWAITING_SELF_REVIEW:
        return 'Awaiting Self Review';
      case PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED:
        return 'Awaiting Manager Review';
      case PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED:
        return 'Awaiting HR Review';
      case PerformanceReviewModel.STATUS_REVIEW_COMPLETED:
        return 'Review Completed';
      default:
        return 'Unknown Status';
    }
  }
} 