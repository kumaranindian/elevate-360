import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class EmployeeAssessmentScreen extends StatefulWidget {
  final UserModel userModel;

  const EmployeeAssessmentScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<EmployeeAssessmentScreen> createState() => _EmployeeAssessmentScreenState();
}

class _EmployeeAssessmentScreenState extends State<EmployeeAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  
  // Assessment data
  final Map<String, double> _kpiRatings = {
    'Technical Skills': 4.0,
    'Communication': 3.5,
    'Teamwork': 4.2,
    'Problem Solving': 4.0,
    'Leadership': 3.0,
    'Innovation': 3.8,
    'Quality of Work': 4.5,
    'Meeting Deadlines': 4.0,
  };
  
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _challengesController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  
  String _selectedPeriod = 'Q1 2024';
  final List<String> _assessmentPeriods = [
    'Q1 2024',
    'Q4 2023',
    'Q3 2023',
    'Q2 2023',
  ];

  @override
  void initState() {
    super.initState();
    _achievementsController.text = 'Successfully completed Project A implementation with 95% client satisfaction. Improved code quality by reducing complexity by 30%.';
    _challengesController.text = 'Learning new framework took longer than expected. Balancing multiple projects was challenging.';
    _goalsController.text = 'Master advanced Flutter concepts. Improve leadership skills. Contribute to team knowledge sharing.';
    _feedbackController.text = 'Would appreciate more mentorship opportunities and clearer project priorities.';
  }

  @override
  void dispose() {
    _achievementsController.dispose();
    _challengesController.dispose();
    _goalsController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.buildResponsiveLayout(
      context: context,
      child: Column(
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
                
                // Submit Button
                _buildSubmitButton(),
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
                'Evaluate your performance and set goals',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                ),
              ),
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
              value: _selectedPeriod,
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
              items: _assessmentPeriods.map((String period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeriod = newValue!;
                });
              },
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
                    onChanged: (value) {
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
                'Submit Assessment',
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

  void _submitAssessment() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Assessment submitted successfully!'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }
} 