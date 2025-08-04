import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/self_assessment_model.dart';
import '../models/employee_model.dart';
import '../models/manager_rating_model.dart';
import 'manager_assessments_screen.dart';
import '../services/self_assessment_service.dart';
import '../services/employee_service.dart';
import '../services/manager_rating_service.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class ManagerSelfAssessmentScreen extends StatefulWidget {
  final UserModel userModel;

  const ManagerSelfAssessmentScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ManagerSelfAssessmentScreen> createState() => _ManagerSelfAssessmentScreenState();
}

class _ManagerSelfAssessmentScreenState extends State<ManagerSelfAssessmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  
  // Manager data
  String? _managerId;
  String _selectedQuarter = '';
  int _selectedYear = 0;
  SelfAssessmentModel? _currentAssessment;
  List<EmployeeModel> _reportees = [];
  EmployeeModel? _selectedReportee;
  List<SelfAssessmentModel> _reporteeAssessments = [];
  
  // Manager KPI ratings - specific to management roles
  final Map<String, double> _managerKpiRatings = {
    'Team Leadership': 3.0,
    'Strategic Planning': 3.0,
    'People Management': 3.0,
    'Communication': 3.0,
    'Decision Making': 3.0,
    'Performance Management': 3.0,
    'Coaching & Development': 3.0,
    'Conflict Resolution': 3.0,
    'Resource Management': 3.0,
    'Innovation & Change': 3.0,
  };
  
  // Employee rating by manager
  final Map<String, double> _employeeRatings = {
    'Technical Skills': 3.0,
    'Communication': 3.0,
    'Teamwork': 3.0,
    'Problem Solving': 3.0,
    'Initiative': 3.0,
    'Quality of Work': 3.0,
    'Meeting Deadlines': 3.0,
    'Professional Growth': 3.0,
  };
  
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _challengesController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _managerFeedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _achievementsController.dispose();
    _challengesController.dispose();
    _goalsController.dispose();
    _feedbackController.dispose();
    _managerFeedbackController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get manager employee record
      final manager = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      _managerId = manager.id;
      
      // Load reportees
      final reportees = await EmployeeService.getReporteesByManagerId(widget.userModel.uid);
      
      // Set current quarter and year
      final now = DateTime.now();
      _selectedYear = now.year;
      _selectedQuarter = 'Q${((now.month - 1) ~/ 3) + 1}';
      
      setState(() {
        _reportees = reportees;
        _isLoading = false;
      });
      
      await _loadCurrentAssessment();
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentAssessment() async {
    if (_managerId == null) return;
    
    try {
      final assessments = await SelfAssessmentService.getSelfAssessmentsByEmployeeId(_managerId!);
      final currentAssessment = assessments.where((a) => 
        a.quarter == _selectedQuarter && a.year == _selectedYear
      ).firstOrNull;
      
      if (currentAssessment != null) {
        setState(() {
          _currentAssessment = currentAssessment;
          _managerKpiRatings.addAll(currentAssessment.kpiRatings);
          _achievementsController.text = currentAssessment.achievements;
          _challengesController.text = currentAssessment.challenges;
          _goalsController.text = currentAssessment.goals;
          _feedbackController.text = currentAssessment.feedback;
        });
      }
    } catch (e) {
      print('Error loading current assessment: $e');
    }
  }

  Future<void> _loadReporteeAssessments(String employeeId) async {
    try {
      final assessments = await SelfAssessmentService.getSelfAssessmentsByEmployeeId(employeeId);
      setState(() {
        _reporteeAssessments = assessments;
      });
    } catch (e) {
      print('Error loading reportee assessments: $e');
    }
  }

  Future<void> _submitManagerAssessment() async {
    if (!_formKey.currentState!.validate() || _managerId == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculate overall rating from KPI ratings
      final overallRating = _calculateOverallRating(_managerKpiRatings);
      
      final assessment = SelfAssessmentModel(
        id: _currentAssessment?.id ?? '',
        employeeId: _managerId!,
        quarter: _selectedQuarter,
        year: _selectedYear,
        kpiRatings: Map<String, double>.from(_managerKpiRatings),
        achievements: _achievementsController.text,
        challenges: _challengesController.text,
        goals: _goalsController.text,
        feedback: '${_feedbackController.text}\n\nOverall Rating: ${overallRating.toStringAsFixed(1)}/5.0',
        status: 'Submitted',
        submittedDate: DateTime.now(),
        createdAt: _currentAssessment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_currentAssessment != null) {
        await SelfAssessmentService.updateSelfAssessment(assessment);
      } else {
        await SelfAssessmentService.createSelfAssessment(assessment);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manager self-assessment submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadCurrentAssessment();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting assessment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  double _calculateOverallRating(Map<String, double> ratings) {
    if (ratings.isEmpty) return 0.0;
    final sum = ratings.values.reduce((a, b) => a + b);
    return sum / ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          'Manager Assessment',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontSize: ResponsiveUtils.getBodyFontSize(context),
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Self Assessment'),
            Tab(text: 'My Team'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSelfAssessmentTab(),
          _buildTeamAssessmentTab(),
        ],
      ),
    );
  }

  Widget _buildSelfAssessmentTab() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuarterSelector(),
              SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
              _buildManagerKpiSection(),
              SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
              _buildTextFieldsSection(),
              SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamAssessmentTab() {
    // Import the ManagerAssessmentsScreen widget to show reportee reviews
    return ManagerAssessmentsScreen(userModel: widget.userModel);
  }

  Widget _buildQuarterSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppTheme.primaryColor,
                size: ResponsiveUtils.getIconSize(context),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Text(
                'Assessment Period',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedQuarter,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF2A2A2A),
                  decoration: InputDecoration(
                    labelText: 'Quarter',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
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
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                  ),
                  items: ['Q1', 'Q2', 'Q3', 'Q4'].map((quarter) {
                    return DropdownMenuItem(
                      value: quarter,
                      child: Text(quarter, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedQuarter = value!;
                    });
                    _loadCurrentAssessment();
                  },
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF2A2A2A),
                  decoration: InputDecoration(
                    labelText: 'Year',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
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
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                  ),
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - 2 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString(), style: const TextStyle(color: Colors.white)),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                    });
                    _loadCurrentAssessment();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagerKpiSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: AppTheme.primaryColor,
                size: ResponsiveUtils.getIconSize(context),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Text(
                'Manager KPI Self-Ratings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
          Text(
            'Rate yourself on the following management competencies (1-5 scale)',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          ..._managerKpiRatings.entries.map((entry) {
            return _buildRatingSlider(
              entry.key,
              entry.value,
              (value) {
                setState(() {
                  _managerKpiRatings[entry.key] = value;
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTextFieldsSection() {
    return Column(
      children: [
        _buildTextFieldCard(
          'Key Achievements',
          'Describe your major accomplishments this quarter...',
          _achievementsController,
        ),
        SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
        _buildTextFieldCard(
          'Challenges Faced',
          'What challenges did you encounter and how did you address them?',
          _challengesController,
        ),
        SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
        _buildTextFieldCard(
          'Goals for Next Quarter',
          'What are your goals and priorities for the upcoming quarter?',
          _goalsController,
        ),
        SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
        _buildTextFieldCard(
          'Additional Feedback',
          'Any additional comments or feedback...',
          _feedbackController,
        ),
      ],
    );
  }

  Widget _buildReporteeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Team Member',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EmployeeModel>(
              value: _selectedReportee,
              decoration: const InputDecoration(
                labelText: 'Team Member',
                border: OutlineInputBorder(),
              ),
              items: _reportees.map((employee) {
                return DropdownMenuItem(
                  value: employee,
                  child: Text('${employee.firstName} ${employee.lastName}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReportee = value;
                });
                if (value != null) {
                  _loadReporteeAssessments(value.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReporteeAssessmentView() {
    if (_reporteeAssessments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No self-assessments found for ${_selectedReportee?.firstName} ${_selectedReportee?.lastName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final latestAssessment = _reporteeAssessments.first;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedReportee?.firstName}\'s Latest Self-Assessment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${latestAssessment.quarter} ${latestAssessment.year} • Overall Rating: ${_calculateOverallRating(latestAssessment.kpiRatings).toStringAsFixed(1)}/5.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Self-Ratings:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...latestAssessment.kpiRatings.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRatingColor(entry.value),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (latestAssessment.achievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Achievements:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(latestAssessment.achievements),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManagerRatingSection() {
    final latestAssessment = _reporteeAssessments.isNotEmpty ? _reporteeAssessments.first : null;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rate_review,
                color: AppTheme.primaryColor,
                size: ResponsiveUtils.getIconSize(context),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Text(
                'Rate ${_selectedReportee?.firstName} ${_selectedReportee?.lastName}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
          Text(
            'Compare with employee\'s self-assessment and provide your rating',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Rating Comparison Section
          if (latestAssessment != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
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
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Employee Self-Assessment: ${latestAssessment.quarter} ${latestAssessment.year}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Criteria Comparison
                  ..._buildCriteriaComparison(latestAssessment),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No self-assessment found for ${_selectedReportee?.firstName}. You can still provide your rating.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            
            // Manager ratings without comparison
            ..._employeeRatings.entries.map((entry) {
              return _buildSimpleRatingSlider(
                entry.key,
                entry.value,
                (value) {
                  setState(() {
                    _employeeRatings[entry.key] = value;
                  });
                },
              );
            }).toList(),
          ],
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Manager Feedback Section
          Text(
            'Manager Feedback',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _managerFeedbackController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Provide detailed feedback for this team member...',
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
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 4,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitManagerRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Submit Manager Rating',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSlider(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(value),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}/5',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldCard(String title, String hint, TextEditingController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitManagerAssessment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Submit Self-Assessment'),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.lightGreen;
    if (rating >= 2.5) return Colors.orange;
    if (rating >= 1.5) return Colors.deepOrange;
    return Colors.red;
  }

  List<Widget> _buildCriteriaComparison(SelfAssessmentModel assessment) {
    final List<Widget> widgets = [];
    
    // Map employee self-ratings to manager rating criteria
    final criteriaMapping = {
      'Technical Skills': 'Technical Skills',
      'Communication': 'Communication',
      'Teamwork': 'Teamwork',
      'Problem Solving': 'Problem Solving',
      'Leadership': 'Initiative',
      'Innovation': 'Quality of Work',
      'Quality of Work': 'Meeting Deadlines',
      'Meeting Deadlines': 'Professional Growth',
    };
    
    for (final entry in _employeeRatings.entries) {
      final criteriaName = entry.key;
      final managerRating = entry.value;
      
      // Find corresponding employee self-rating
      double? employeeSelfRating;
      for (final assessmentEntry in assessment.kpiRatings.entries) {
        if (criteriaMapping[assessmentEntry.key] == criteriaName || 
            assessmentEntry.key == criteriaName) {
          employeeSelfRating = assessmentEntry.value;
          break;
        }
      }
      
      widgets.add(_buildCriteriaComparisonRow(
        criteriaName,
        employeeSelfRating,
        managerRating,
        (value) {
          setState(() {
            _employeeRatings[criteriaName] = value;
          });
        },
      ));
    }
    
    return widgets;
  }

  Widget _buildCriteriaComparisonRow(
    String criteriaName,
    double? employeeSelfRating,
    double managerRating,
    Function(double) onManagerRatingChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Criteria Name
          Text(
            criteriaName,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Comparison Row
          Row(
            children: [
              // Employee Self-Rating Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Self-Rating',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: ResponsiveUtils.getSmallFontSize(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (employeeSelfRating != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getRatingColor(employeeSelfRating).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getRatingColor(employeeSelfRating).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${employeeSelfRating.toStringAsFixed(1)}/5.0',
                              style: TextStyle(
                                color: _getRatingColor(employeeSelfRating),
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: employeeSelfRating / 5.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getRatingColor(employeeSelfRating),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Not rated',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Manager Rating Column
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.supervisor_account,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Your Rating',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: ResponsiveUtils.getSmallFontSize(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRatingColor(managerRating),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${managerRating.toStringAsFixed(1)}/5',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: managerRating,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      activeColor: Colors.orange,
                      inactiveColor: Colors.grey.withOpacity(0.3),
                      onChanged: onManagerRatingChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Comparison Indicator
          if (employeeSelfRating != null) ...[
            const SizedBox(height: 12),
            _buildComparisonIndicator(employeeSelfRating, managerRating),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonIndicator(double selfRating, double managerRating) {
    final difference = managerRating - selfRating;
    final absDistance = difference.abs();
    
    Color indicatorColor;
    IconData indicatorIcon;
    String indicatorText;
    
    if (absDistance <= 0.5) {
      indicatorColor = AppTheme.successColor;
      indicatorIcon = Icons.check_circle;
      indicatorText = 'Aligned ratings';
    } else if (difference > 0) {
      indicatorColor = Colors.blue;
      indicatorIcon = Icons.trending_up;
      indicatorText = 'Manager rates higher (+${difference.toStringAsFixed(1)})';
    } else {
      indicatorColor = Colors.red;
      indicatorIcon = Icons.trending_down;
      indicatorText = 'Manager rates lower (${difference.toStringAsFixed(1)})';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: indicatorColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            indicatorIcon,
            color: indicatorColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            indicatorText,
            style: TextStyle(
              color: indicatorColor,
              fontSize: ResponsiveUtils.getSmallFontSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRatingSlider(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(value),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}/5',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSelfAssessmentWarning() {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getSectionSpacing(context)),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: ResponsiveUtils.getIconSize(context),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Self-Assessment First',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You need to complete your own self-assessment before rating your team members.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: ResponsiveUtils.getBodyFontSize(context) - 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRestrictedMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            color: AppTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Rating Restricted',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getSubtitleFontSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your self-assessment for ${_selectedQuarter} ${_selectedYear} to unlock team member rating.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _tabController.animateTo(0); // Switch to self-assessment tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Go to Self-Assessment'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitManagerRating() async {
    if (_selectedReportee == null || _managerId == null) return;

    try {
      // Check if a rating already exists for this period
      final existingRating = await ManagerRatingService.getManagerRating(
        _selectedReportee!.id,
        _managerId!,
        _selectedQuarter,
        _selectedYear,
      );

      final rating = ManagerRatingModel(
        id: existingRating?.id ?? '',
        employeeId: _selectedReportee!.id,
        managerId: _managerId!,
        quarter: _selectedQuarter,
        year: _selectedYear,
        kpiRatings: Map<String, double>.from(_employeeRatings),
        feedback: _managerFeedbackController.text,
        overallRating: _calculateOverallRating(_employeeRatings),
        createdAt: existingRating?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'Submitted',
      );

      if (existingRating != null) {
        await ManagerRatingService.updateManagerRating(rating);
      } else {
        await ManagerRatingService.createManagerRating(rating);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating submitted for ${_selectedReportee!.firstName}!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      setState(() {
        _employeeRatings.updateAll((key, value) => 3.0);
        _managerFeedbackController.clear();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
