import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../models/goal_model.dart';
import '../models/skill_model.dart';

import '../models/self_assessment_model.dart';
import '../core/utils/app_theme.dart';

import '../core/providers/auth_provider.dart';
import '../core/widgets/app_logo.dart';
import 'employee_profile_screen.dart';
import 'employee_goals_screen.dart';
import 'employee_self_assessment_screen.dart';

import 'employee_skill_tracker_screen.dart';
import 'notifications_coming_soon_screen.dart';
import 'login_screen.dart';
import '../services/employee_service.dart';
import '../services/goal_service.dart';
import '../services/self_assessment_service.dart';

import '../services/skill_service.dart';
import 'dart:math' as math;

class EmployeeDashboardScreen extends ConsumerStatefulWidget {
  final UserModel userModel;

  const EmployeeDashboardScreen({
    super.key,
    required this.userModel,
  });

  @override
  ConsumerState<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends ConsumerState<EmployeeDashboardScreen> {
  int _selectedIndex = 0;

  // Data for dashboard
  Map<String, dynamic>? _profile;
  List<GoalModel> _goals = [];
  List<SelfAssessmentModel> _assessments = [];

  List<SkillModel> _skills = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      debugPrint('Fetching employee data...');
      final employee = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      debugPrint('Employee data fetched successfully. Fetching goals...');
      
      final goals = await GoalService.getGoalsByEmployeeId(employee.id);
      debugPrint('Goals fetched successfully. Fetching assessments...');
      
      final assessments = await SelfAssessmentService.getSelfAssessmentsByEmployeeId(employee.id);
      debugPrint('Assessments fetched successfully. Fetching skills...');
      
      final skills = await SkillService.getSkillsByEmployeeId(employee.id);
      debugPrint('Skills fetched successfully. Updating state...');
      
      setState(() {
        _profile = employee.toJson();
        _goals = goals;
        _assessments = assessments;

        _skills = skills;
        _isLoading = false;
      });
      debugPrint('Dashboard data fetch completed successfully');
    } catch (e, stackTrace) {
      debugPrint('ERROR FETCHING DASHBOARD DATA:');
      debugPrint('Error details: $e');
      debugPrint('Stack trace:');
      debugPrint(stackTrace.toString());
      
      // Check specifically for Firestore index errors
      if (e.toString().contains('failed-precondition') && e.toString().contains('index')) {
        debugPrint('\nFIRESTORE INDEX ERROR DETECTED:');
        debugPrint('Please check the error message above for the index creation link');
        debugPrint('You can click the link to create the required index in the Firebase Console\n');
      }
      
      setState(() { 
        _error = e.toString(); 
        _isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Row(
        children: [
          // Sidebar - Hidden on mobile, shown on desktop
          if (MediaQuery.of(context).size.width > 768)
            _buildSidebar(),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top navigation bar
                _buildTopNavigation(),
                
                // Main content
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation for mobile
      bottomNavigationBar: MediaQuery.of(context).size.width <= 768
          ? _buildBottomNavigation()
          : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF0F0F0F),
      child: Column(
        children: [
          // Logo and title
          Container(
            padding: const EdgeInsets.all(20),
            child: const AppLogo(
              size: 40,
              showText: true,
            ),
          ),
          
          const Divider(color: Color(0xFF333333), height: 1),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildNavItem(Icons.dashboard, 'Dashboard', 0),
                _buildNavItem(Icons.person, 'My Profile', 1),
                _buildNavItem(Icons.flag, 'My Goals', 2),
                _buildNavItem(Icons.assessment, 'Assessment', 3),

                _buildNavItem(Icons.psychology, 'Skill Tracker', 5),
                _buildNavItem(Icons.notifications, 'Notifications', 6),
              ],
            ),
          ),
          
          const Divider(color: Color(0xFF333333), height: 1),
          
          // User profile section
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    widget.userModel.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userModel.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Employee',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF888888),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : const Color(0xFF888888),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF888888),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          bottom: BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo for mobile view
          if (MediaQuery.of(context).size.width <= 768)
            const AppLogoSmall(
              size: 32,
            ),
          
          if (MediaQuery.of(context).size.width <= 768)
            const SizedBox(width: 16),
          
          // Page title
          Expanded(
            child: Text(
              _getPageTitle(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Notifications
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
            },
            icon: const Icon(
              Icons.notifications,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF2A2A2A),
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: const Color(0xFF888888),
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Assessment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feedback),
          label: 'Feedback',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: 'Skills',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return EmployeeProfileScreen(userModel: widget.userModel);
      case 2:
        return EmployeeGoalsScreen(userModel: widget.userModel);
      case 3:
        return EmployeeSelfAssessmentScreen(userModel: widget.userModel);
      case 4:
        return Container(); // Feedback screen removed
      case 5:
        return EmployeeSkillTrackerScreen(userModel: widget.userModel);
      case 6:
        return const NotificationsComingSoonScreen();
      default:
        return _buildDashboardContent();
    }
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'My Profile';
      case 2:
        return 'My Goals';
      case 3:
        return 'Assessment';
      case 4:
        return 'Removed'; // Feedback removed
      case 5:
        return 'Skill Tracker';
      case 6:
        return 'Notifications';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your dashboard...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text('Error: $_error', style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _fetchDashboardData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section with Quick Actions
          if (_profile != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar with Status
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: isSmallScreen ? 32 : 40,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  (_profile!['first_name'] ?? 'E')[0],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 28 : 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: isSmallScreen ? 16 : 24),
                          // Profile Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_profile!['first_name'] ?? ''} ${_profile!['last_name'] ?? ''}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _profile!['email'] ?? '',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: isSmallScreen ? 14 : 16),
                                ),
                                Text(
                                  'Role: ${_profile!['role'] ?? 'Employee'}',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: isSmallScreen ? 14 : 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Quick Action Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickActionButton(
                            icon: Icons.edit,
                            label: 'Edit Profile',
                            onTap: () => setState(() => _selectedIndex = 1),
                          ),
                          _buildQuickActionButton(
                            icon: Icons.assessment,
                            label: 'Assessment',
                            onTap: () => setState(() => _selectedIndex = 3),
                          ),
                          _buildQuickActionButton(
                            icon: Icons.psychology,
                            label: 'Skills',
                            onTap: () => setState(() => _selectedIndex = 5),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 24),

          // Performance Overview
          Text(
            'Performance Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Grid with Animations
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 6 
                                 : constraints.maxWidth > 900 ? 4
                                 : constraints.maxWidth > 600 ? 3
                                 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildAnimatedStatCard(
                    'Active Goals',
                    '${_goals.where((g) => g.status != 'Completed').length}',
                    Icons.flag,
                    AppTheme.primaryColor,
                    _goals.where((g) => g.status != 'Completed').length / (_goals.isEmpty ? 1 : _goals.length),
                  ),
                  _buildAnimatedStatCard(
                    'Completed Goals',
                    '${_goals.where((g) => g.status == 'Completed').length}',
                    Icons.check_circle,
                    AppTheme.successColor,
                    _goals.where((g) => g.status == 'Completed').length / (_goals.isEmpty ? 1 : _goals.length),
                  ),
                  _buildAnimatedStatCard(
                    'Avg. Progress',
                    _goals.isNotEmpty ? '${(_goals.map((g) => g.progressPercentage as num).reduce((a, b) => a + b) / _goals.length).toStringAsFixed(1)}%' : '0%',
                    Icons.trending_up,
                    AppTheme.warningColor,
                    _goals.isEmpty ? 0 : _goals.map((g) => g.progressPercentage as num).reduce((a, b) => a + b) / (_goals.length * 100),
                  ),
                  _buildAnimatedStatCard(
                    'Skills',
                    '${_skills.length}',
                    Icons.psychology,
                    AppTheme.infoColor,
                    _skills.length / 10, // Assuming 10 is a good target for skills
                  ),
                  _buildAnimatedStatCard(
                    'Assessments',
                    '${_assessments.length}',
                    Icons.assessment,
                    Colors.teal,
                    _assessments.length / 4, // Assuming 4 is a good target for assessments (quarterly)
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Goals Progress Chart
          if (_goals.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goals Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildGoalsChart(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Skills Distribution
          if (_skills.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills Distribution',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildSkillsChart(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Recent Activity Feed with Timeline
          _buildRecentActivityTimeline(),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard(String title, String value, IconData icon, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1500),
                builder: (context, double value, child) {
                  return SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 2,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsChart() {
    if (_goals.isEmpty) return const Center(child: Text('No goals data', style: TextStyle(color: Colors.white70)));
    
    final completedGoals = _goals.where((g) => g.status == 'Completed').length;
    final inProgressGoals = _goals.where((g) => g.status == 'In Progress').length;
    final pendingGoals = _goals.where((g) => g.status == 'Pending').length;
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: AppTheme.successColor,
            value: completedGoals.toDouble(),
            title: '$completedGoals',
            radius: 50,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            color: AppTheme.warningColor,
            value: inProgressGoals.toDouble(),
            title: '$inProgressGoals',
            radius: 45,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            color: AppTheme.primaryColor,
            value: pendingGoals.toDouble(),
            title: '$pendingGoals',
            radius: 40,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsChart() {
    if (_skills.isEmpty) return const Center(child: Text('No skills data', style: TextStyle(color: Colors.white70)));
    
    final skillLevels = List.generate(5, (index) => 
      _skills.where((s) => s.proficiencyLevel == index + 1).length
    );
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: skillLevels.reduce(math.max).toDouble() + 1,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  'L${value.toInt() + 1}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt()) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          skillLevels.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: skillLevels[index].toDouble(),
                color: AppTheme.primaryColor,
                width: 20,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: skillLevels.reduce(math.max).toDouble() + 1,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  Widget _buildRecentActivityTimeline() {
    final activities = <Map<String, dynamic>>[];
    for (var g in _goals) {
      activities.add({
        'type': 'Goal',
        'desc': 'Goal "${g.title}" updated',
        'time': g.updatedAt,
        'icon': Icons.flag,
        'color': AppTheme.primaryColor,
      });
    }
    for (var a in _assessments) {
      activities.add({
        'type': 'Assessment',
        'desc': 'Assessment for ${a.quarter} ${a.year} submitted',
        'time': a.updatedAt,
        'icon': Icons.assessment,
        'color': AppTheme.warningColor,
      });
    }
    for (var s in _skills) {
      activities.add({
        'type': 'Skill',
        'desc': 'Skill "${s.skillName}" updated',
        'time': s.updatedAt,
        'icon': Icons.psychology,
        'color': Colors.teal,
      });
    }
    activities.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: math.min(activities.length, 8),
            itemBuilder: (context, index) {
              final activity = activities[index];
              final isLast = index == math.min(activities.length, 8) - 1;
              
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: activity['color'].withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            activity['icon'],
                            color: activity['color'],
                            size: 16,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.grey.shade800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['desc'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimeAgo(activity['time']),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (!isLast) const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (activities.length > 8)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                '...and ${activities.length - 8} more',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
} 