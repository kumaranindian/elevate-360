import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class EmployeeSkillsScreen extends StatefulWidget {
  final UserModel userModel;

  const EmployeeSkillsScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<EmployeeSkillsScreen> createState() => _EmployeeSkillsScreenState();
}

class _EmployeeSkillsScreenState extends State<EmployeeSkillsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Technical', 'Soft Skills', 'Leadership', 'Domain'];
  
  // Demo skills data
  final List<Map<String, dynamic>> _skills = [
    {
      'name': 'Flutter Development',
      'category': 'Technical',
      'level': 4.2,
      'status': 'Advanced',
      'lastAssessed': '2024-01-15',
      'description': 'Mobile app development using Flutter framework',
      'resources': ['Flutter Documentation', 'Udemy Course', 'GitHub Projects'],
      'nextGoal': 'Master advanced state management',
    },
    {
      'name': 'Dart Programming',
      'category': 'Technical',
      'level': 4.0,
      'status': 'Advanced',
      'lastAssessed': '2024-01-10',
      'description': 'Programming language for Flutter development',
      'resources': ['Dart Language Tour', 'Practice Exercises'],
      'nextGoal': 'Learn advanced Dart features',
    },
    {
      'name': 'Firebase Integration',
      'category': 'Technical',
      'level': 3.5,
      'status': 'Intermediate',
      'lastAssessed': '2024-01-20',
      'description': 'Backend services integration with Firebase',
      'resources': ['Firebase Console', 'YouTube Tutorials'],
      'nextGoal': 'Master Firestore security rules',
    },
    {
      'name': 'Team Communication',
      'category': 'Soft Skills',
      'level': 4.0,
      'status': 'Advanced',
      'lastAssessed': '2024-01-25',
      'description': 'Effective communication within team environment',
      'resources': ['Communication Workshops', 'Team Meetings'],
      'nextGoal': 'Improve presentation skills',
    },
    {
      'name': 'Problem Solving',
      'category': 'Soft Skills',
      'level': 4.5,
      'status': 'Expert',
      'lastAssessed': '2024-01-18',
      'description': 'Analytical thinking and problem-solving abilities',
      'resources': ['Case Studies', 'Practice Problems'],
      'nextGoal': 'Mentor others in problem solving',
    },
    {
      'name': 'Project Leadership',
      'category': 'Leadership',
      'level': 3.0,
      'status': 'Intermediate',
      'lastAssessed': '2024-01-30',
      'description': 'Leading small to medium-sized projects',
      'resources': ['Leadership Training', 'Project Management Tools'],
      'nextGoal': 'Lead larger team projects',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredSkills = _getFilteredSkills();
    
    return ResponsiveUtils.buildResponsiveLayout(
      context: context,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
            
            // Skills Overview
            _buildSkillsOverview(),
            
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
            
            // Filter
            _buildFilterSection(),
            
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
            
            // Skills Grid
            _buildSkillsGrid(filteredSkills),
            
            // Add bottom padding to prevent overflow
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          ],
        ),
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
                'Skill Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
              Text(
                'Track and develop your professional skills',
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
                '4.0/5.0',
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

  Widget _buildSkillsOverview() {
    final stats = [
      {'label': 'Total Skills', 'value': '${_skills.length}', 'color': AppTheme.primaryColor},
      {'label': 'Advanced', 'value': '${_skills.where((s) => s['level'] >= 4.0).length}', 'color': AppTheme.successColor},
      {'label': 'Intermediate', 'value': '${_skills.where((s) => s['level'] >= 3.0 && s['level'] < 4.0).length}', 'color': AppTheme.warningColor},
      {'label': 'Beginner', 'value': '${_skills.where((s) => s['level'] < 3.0).length}', 'color': AppTheme.errorColor},
    ];

    return ResponsiveUtils.buildResponsiveSection(
      context: context,
      title: 'Skills Overview',
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
            childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.5 : 
                             ResponsiveUtils.isTablet(context) ? 2.0 : 2.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) / 
                (ResponsiveUtils.isDesktop(context) ? 1.5 : 1)),
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
          value: _selectedCategory,
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
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSkillsGrid(List<Map<String, dynamic>> skills) {
    return ResponsiveUtils.buildResponsiveSection(
      context: context,
      title: 'Skills',
      icon: Icons.psychology,
      children: [
        if (skills.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: ResponsiveUtils.getIconSize(context) * 2,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),
                Text(
                  'No skills found',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                  ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
                context,
                mobile: 1,
                tablet: 2,
                desktop: 3,
              ),
              crossAxisSpacing: ResponsiveUtils.getSpacing(context),
              mainAxisSpacing: ResponsiveUtils.getSpacing(context),
              childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.2 : 
                               ResponsiveUtils.isTablet(context) ? 1.4 : 1.8,
            ),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              return _buildSkillCard(skills[index]);
            },
          ),
      ],
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill) {
    final levelColor = _getLevelColor(skill['level']);
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) / (isDesktop ? 1.5 : 1)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getCardBorderRadius(context)),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with category and level
          Row(
            children: [
              Expanded(
                child: Text(
                  skill['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getSpacing(context) / 2,
                  vertical: ResponsiveUtils.getSpacing(context) / 3,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  skill['status'],
                  style: TextStyle(
                    color: levelColor,
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
          
          // Category
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context) / 2,
              vertical: ResponsiveUtils.getSpacing(context) / 3,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              skill['category'],
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: ResponsiveUtils.getSmallFontSize(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context) / (isDesktop ? 1.5 : 1)),
          
          // Description
          Text(
            skill['description'],
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: ResponsiveUtils.getSmallFontSize(context),
            ),
            maxLines: isDesktop ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context) / (isDesktop ? 1.5 : 1)),
          
          // Level indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: ResponsiveUtils.getSmallFontSize(context),
                    ),
                  ),
                  Text(
                    '${skill['level']}/5.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.getSmallFontSize(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
              LinearProgressIndicator(
                value: skill['level'] / 5.0,
                backgroundColor: const Color(0xFF333333),
                valueColor: AlwaysStoppedAnimation<Color>(levelColor),
              ),
            ],
          ),
          
          if (!isDesktop) ...[
            SizedBox(height: ResponsiveUtils.getSpacing(context) / (isDesktop ? 1.5 : 1)),
            
            // Next goal and last assessed in a compact layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: AppTheme.warningColor,
                      size: ResponsiveUtils.getSmallIconSize(context),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context) / 2),
                    Expanded(
                      child: Text(
                        skill['nextGoal'],
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: ResponsiveUtils.getSmallFontSize(context),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
                
                Text(
                  'Last assessed: ${skill['lastAssessed']}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredSkills() {
    if (_selectedCategory == 'All') {
      return _skills;
    }
    return _skills.where((skill) => skill['category'] == _selectedCategory).toList();
  }

  Color _getLevelColor(double level) {
    if (level >= 4.5) return AppTheme.successColor;
    if (level >= 4.0) return AppTheme.primaryColor;
    if (level >= 3.0) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
} 