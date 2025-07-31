import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class EmployeeFeedbackReceivedScreen extends StatefulWidget {
  final UserModel userModel;

  const EmployeeFeedbackReceivedScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<EmployeeFeedbackReceivedScreen> createState() => _EmployeeFeedbackReceivedScreenState();
}

class _EmployeeFeedbackReceivedScreenState extends State<EmployeeFeedbackReceivedScreen> {
  bool _isLoading = false;
  String? _employeeId;
  String _selectedQuarter = '';
  int _selectedYear = 0;
  List<ReviewModel> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
    _initializeQuarterSelection();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final employee = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      setState(() {
        _employeeId = employee.id;
      });
      _loadFeedbackData();
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
    final currentQuarter = _getCurrentQuarter();
    final currentYear = DateTime.now().year;
    setState(() {
      _selectedQuarter = currentQuarter;
      _selectedYear = currentYear;
    });
  }

  String _getCurrentQuarter() {
    final now = DateTime.now();
    final month = now.month;
    
    if (month >= 1 && month <= 3) return 'Q1';
    if (month >= 4 && month <= 6) return 'Q2';
    if (month >= 7 && month <= 9) return 'Q3';
    return 'Q4';
  }

  Future<void> _loadFeedbackData() async {
    if (_employeeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reviews = await ReviewService.getReviewsByQuarter(_selectedQuarter, _selectedYear);
      
      // Filter reviews for this employee
      final employeeReviews = reviews.where((review) => review.employeeId == _employeeId).toList();
      
      setState(() {
        _feedbackList = employeeReviews;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading feedback data: $e'),
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
    
    _loadFeedbackData();
  }

  List<String> _getAvailableQuarters() {
    final currentYear = DateTime.now().year;
    final currentQuarter = _getCurrentQuarter();
    final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
    
    List<String> availableQuarters = [];
    
    // Add current and previous quarters
    for (int year = currentYear; year >= currentYear - 2; year--) {
      for (String quarter in quarters) {
        if (year == currentYear && quarter == currentQuarter) {
          availableQuarters.add('$quarter $year');
          break;
        } else if (year < currentYear || (year == currentYear && quarters.indexOf(quarter) < quarters.indexOf(currentQuarter))) {
          availableQuarters.add('$quarter $year');
        }
      }
    }
    
    return availableQuarters;
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
                
                // Statistics
                _buildStatistics(),
                
                SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                
                // Feedback list
                _buildFeedbackList(),
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
                'Feedback Received',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
              Text(
                'Review feedback from managers, peers, and HR',
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
              items: _getAvailableQuarters().map((String quarter) {
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

  Widget _buildStatistics() {
    final totalReviews = _feedbackList.length;
    final avgRating = totalReviews > 0 
        ? _feedbackList.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews 
        : 0.0;
    
    final stats = [
      {'label': 'Total Reviews', 'value': '$totalReviews', 'color': AppTheme.primaryColor},
      {'label': 'Avg Rating', 'value': '${avgRating.toStringAsFixed(1)}/5.0', 'color': AppTheme.successColor},
      {'label': 'Manager Reviews', 'value': '${_feedbackList.where((r) => r.reviewType == 'Manager Review').length}', 'color': AppTheme.warningColor},
      {'label': 'HR Reviews', 'value': '${_feedbackList.where((r) => r.reviewType == 'HR Review').length}', 'color': AppTheme.errorColor},
    ];

    return ResponsiveUtils.buildResponsiveSection(
      context: context,
      title: 'Feedback Statistics',
      icon: Icons.analytics,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;
            
            return Wrap(
              spacing: ResponsiveUtils.getSpacing(context),
              runSpacing: ResponsiveUtils.getSpacing(context),
              children: stats.map((stat) {
                final cardWidth = isSmallScreen
                    ? constraints.maxWidth
                    : isMediumScreen
                        ? (constraints.maxWidth - ResponsiveUtils.getSpacing(context)) / 2
                        : (constraints.maxWidth - ResponsiveUtils.getSpacing(context) * 3) / 4;

                return SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stat['value'] as String,
                          style: TextStyle(
                            color: stat['color'] as Color,
                            fontSize: ResponsiveUtils.getTitleFontSize(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
                        Text(
                          stat['label'] as String,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: ResponsiveUtils.getSmallFontSize(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeedbackList() {
    return ResponsiveUtils.buildResponsiveSection(
      context: context,
      title: 'Feedback Reviews',
      icon: Icons.feedback,
      children: [
        if (_feedbackList.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.feedback_outlined,
                  size: ResponsiveUtils.getIconSize(context) * 2,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),
                Text(
                  'No feedback found for $_selectedQuarter $_selectedYear',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: _feedbackList.map((feedback) => _buildFeedbackCard(feedback)).toList(),
          ),
      ],
    );
  }

  Widget _buildFeedbackCard(ReviewModel feedback) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context)),
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getCardBorderRadius(context)),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: ResponsiveUtils.getSpacing(context),
                backgroundColor: _getTypeColor(feedback.reviewType),
                child: Text(
                  feedback.reviewType[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.reviewType,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Reviewer ID: ${feedback.reviewerId}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: ResponsiveUtils.getSmallFontSize(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getSpacing(context) / 2,
                  vertical: ResponsiveUtils.getSpacing(context) / 3,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(feedback.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feedback.status,
                  style: TextStyle(
                    color: _getStatusColor(feedback.status),
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Rating and date
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quarter: ${feedback.quarter} ${feedback.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.warningColor,
                    size: ResponsiveUtils.getSmallIconSize(context),
                  ),
                  SizedBox(width: ResponsiveUtils.getSpacing(context) / 2),
                  Text(
                    feedback.rating.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.getBodyFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
          
          // Date
          Text(
            'Date: ${feedback.submittedDate?.toString().split(' ')[0] ?? 'N/A'}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: ResponsiveUtils.getSmallFontSize(context),
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Comments
          Text(
            feedback.comments,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'manager review':
        return AppTheme.primaryColor;
      case 'peer review':
        return AppTheme.successColor;
      case 'hr review':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'awaiting manager review':
        return AppTheme.primaryColor;
      case 'awaiting hr review':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }
} 