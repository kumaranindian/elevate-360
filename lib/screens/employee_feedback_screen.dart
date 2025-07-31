import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class EmployeeFeedbackScreen extends StatefulWidget {
  final UserModel userModel;

  const EmployeeFeedbackScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<EmployeeFeedbackScreen> createState() => _EmployeeFeedbackScreenState();
}

class _EmployeeFeedbackScreenState extends State<EmployeeFeedbackScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Manager', 'Peer', 'HR'];
  
  // Demo feedback data
  final List<Map<String, dynamic>> _feedbackList = [
    {
      'id': '1',
      'from': 'Sarah Wilson',
      'role': 'Manager',
      'type': 'Manager',
      'date': '2024-02-15',
      'rating': 4.2,
      'title': 'Q4 2023 Performance Review',
      'content': 'Excellent work on the Project A implementation. Your technical skills and problem-solving abilities are outstanding. You consistently meet deadlines and produce high-quality code. Areas for improvement: Consider taking on more leadership responsibilities and mentoring junior developers.',
      'strengths': ['Technical Excellence', 'Problem Solving', 'Meeting Deadlines'],
      'areas': ['Leadership', 'Mentoring'],
      'status': 'Completed',
    },
    {
      'id': '2',
      'from': 'Mike Johnson',
      'role': 'Senior Developer',
      'type': 'Peer',
      'date': '2024-01-20',
      'rating': 4.5,
      'title': 'Peer Feedback - Team Collaboration',
      'content': 'Great team player! You\'re always willing to help others and share knowledge. Your code reviews are thorough and constructive. You communicate effectively and contribute valuable ideas during team discussions.',
      'strengths': ['Teamwork', 'Knowledge Sharing', 'Communication'],
      'areas': ['Code Review Speed'],
      'status': 'Completed',
    },
    {
      'id': '3',
      'from': 'Jennifer Smith',
      'role': 'HR Manager',
      'type': 'HR',
      'date': '2024-01-10',
      'rating': 4.0,
      'title': '360-Degree Feedback Summary',
      'content': 'Strong performance across all areas. You demonstrate excellent professional behavior and contribute positively to team culture. Your growth mindset and willingness to learn are commendable.',
      'strengths': ['Professional Behavior', 'Growth Mindset', 'Team Culture'],
      'areas': ['Public Speaking'],
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFeedback = _getFilteredFeedback();
    
    return ResponsiveUtils.buildResponsiveLayout(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          
          // Statistics
          _buildStatistics(),
          
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          
          // Filter
          _buildFilterSection(),
          
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          
          // Feedback list
          _buildFeedbackList(filteredFeedback),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up,
                color: AppTheme.successColor,
                size: ResponsiveUtils.getSmallIconSize(context),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context) / 2),
              Text(
                '4.2/5.0',
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final stats = [
      {'label': 'Total Reviews', 'value': '${_feedbackList.length}', 'color': AppTheme.primaryColor},
      {'label': 'Avg Rating', 'value': '4.2/5.0', 'color': AppTheme.successColor},
      {'label': 'This Quarter', 'value': '2', 'color': AppTheme.warningColor},
      {'label': 'Pending', 'value': '0', 'color': AppTheme.errorColor},
    ];

    return ResponsiveUtils.buildResponsiveSection(
      context: context,
      title: 'Feedback Statistics',
      icon: Icons.analytics,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
              context,
              mobile: 2,
              tablet: 4,
              desktop: 4,
            ),
            crossAxisSpacing: ResponsiveUtils.getSpacing(context),
            mainAxisSpacing: ResponsiveUtils.getSpacing(context),
            childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.5 : 2.0,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getSpacing(context)),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
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
          items: _filters.map((String filter) {
            return DropdownMenuItem<String>(
              value: filter,
              child: Text(filter),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFilter = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFeedbackList(List<Map<String, dynamic>> feedbackList) {
    return ResponsiveUtils.buildResponsiveSection(
      context: context,
      title: 'Feedback Reviews',
      icon: Icons.feedback,
      children: [
        if (feedbackList.isEmpty)
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
                  'No feedback found',
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
            children: feedbackList.map((feedback) => _buildFeedbackCard(feedback)).toList(),
          ),
      ],
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
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
                backgroundColor: _getTypeColor(feedback['type']),
                child: Text(
                  feedback['from'][0],
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
                      feedback['from'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      feedback['role'],
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
                  color: _getTypeColor(feedback['type']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feedback['type'],
                  style: TextStyle(
                    color: _getTypeColor(feedback['type']),
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Title and rating
          Row(
            children: [
              Expanded(
                child: Text(
                  feedback['title'],
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
                    feedback['rating'].toString(),
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
            'Date: ${feedback['date']}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: ResponsiveUtils.getSmallFontSize(context),
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Content
          Text(
            feedback['content'],
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getBodyFontSize(context),
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Strengths and areas
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strengths:',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: ResponsiveUtils.getSmallFontSize(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
                    ...(feedback['strengths'] as List<String>).map((strength) => 
                      Padding(
                        padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context) / 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.successColor,
                              size: ResponsiveUtils.getSmallIconSize(context),
                            ),
                            SizedBox(width: ResponsiveUtils.getSpacing(context) / 2),
                            Expanded(
                              child: Text(
                                strength,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveUtils.getSmallFontSize(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Areas for Improvement:',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontSize: ResponsiveUtils.getSmallFontSize(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
                    ...(feedback['areas'] as List<String>).map((area) => 
                      Padding(
                        padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context) / 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: AppTheme.warningColor,
                              size: ResponsiveUtils.getSmallIconSize(context),
                            ),
                            SizedBox(width: ResponsiveUtils.getSpacing(context) / 2),
                            Expanded(
                              child: Text(
                                area,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveUtils.getSmallFontSize(context),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  List<Map<String, dynamic>> _getFilteredFeedback() {
    if (_selectedFilter == 'All') {
      return _feedbackList;
    }
    return _feedbackList.where((feedback) => feedback['type'] == _selectedFilter).toList();
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'manager':
        return AppTheme.primaryColor;
      case 'peer':
        return AppTheme.successColor;
      case 'hr':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }
} 