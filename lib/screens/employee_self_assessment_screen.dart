import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/self_assessment_model.dart';
import '../services/self_assessment_service.dart';
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
    _loadEmployeeData();
    _initializeQuarterSelection();
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

  Future<void> _loadAssessmentData() async {
    if (_employeeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final assessment = await SelfAssessmentService.getSelfAssessmentByEmployeeAndQuarter(
        _employeeId!,
        _selectedQuarter,
        _selectedYear,
      );

      setState(() {
        _currentAssessment = assessment;
        _isReadOnly = !SelfAssessmentService.isCurrentQuarter(_selectedQuarter, _selectedYear);
      });

      if (assessment != null) {
        // Load existing data
        _kpiRatings.clear();
        _kpiRatings.addAll(assessment.kpiRatings);
        _achievementsController.text = assessment.achievements;
        _challengesController.text = assessment.challenges;
        _goalsController.text = assessment.goals;
        _feedbackController.text = assessment.feedback;
      } else {
        // Reset to default values for new assessment
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
                'Self Assessment',
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
    return Column(
      children: _kpiRatings.entries.map((entry) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context) / 2),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
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
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: const Color(0xFF333333),
                    thumbColor: AppTheme.primaryColor,
                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                    valueIndicatorColor: AppTheme.primaryColor,
                    valueIndicatorTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.getSmallFontSize(context),
                    ),
                  ),
                  child: Slider(
                    value: entry.value,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    label: entry.value.toString(),
                    onChanged: _isReadOnly ? null : (value) {
                      setState(() {
                        _kpiRatings[entry.key] = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getSpacing(context) / 2,
                  vertical: ResponsiveUtils.getSpacing(context) / 3,
                ),
                decoration: BoxDecoration(
                  color: _getRatingColor(entry.value).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.value.toString(),
                  style: TextStyle(
                    color: _getRatingColor(entry.value),
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
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

  Future<void> _submitAssessment() async {
    if (_formKey.currentState!.validate() && _employeeId != null) {
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
          success = await SelfAssessmentService.updateSelfAssessment(assessment);
        } else {
          success = await SelfAssessmentService.createSelfAssessment(assessment);
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
} 