import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/app_theme.dart';
import '../core/widgets/app_logo.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'manager_self_assessment_screen.dart';
import '../models/employee_model.dart';
import '../models/goal_model.dart';
import '../models/self_assessment_model.dart';

import '../models/skill_model.dart';

import '../services/employee_service.dart';
import '../services/goal_service.dart';
import '../services/self_assessment_service.dart';

import '../services/skill_service.dart';
import '../widgets/reportee_summary.dart';
import 'manager_profile_screen.dart';
import 'manager_goals_screen.dart';


import 'manager_skill_tracker_screen.dart';
import 'manager_notifications_screen.dart';
import '../widgets/team_performance_section.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  final UserModel userModel;
  
  const ManagerDashboardScreen({
    super.key,
    required this.userModel,
  });

  @override
  ConsumerState<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends ConsumerState<ManagerDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _managerProfile;
  List<GoalModel> _goals = [];
  List<SelfAssessmentModel> _assessments = [];

  List<SkillModel> _skills = [];
  List<EmployeeModel> _reportees = [];
  Map<String, Map<String, dynamic>> _reporteeStats = {};
  EmployeeModel? _selectedReportee;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final managerId = widget.userModel.uid;
      if (managerId == null || managerId.isEmpty) {
        throw Exception('Manager ID not found');
      }

      // Fetch manager's own data and reportees data in parallel
      final futures = await Future.wait([
        _fetchManagerData(managerId),
        _fetchReporteesData(managerId),
        _fetchManagerGoals(managerId),
        _fetchManagerAssessments(managerId),

        _fetchManagerSkills(managerId),
      ]);

      // Calculate stats for each reportee
      final stats = <String, Map<String, dynamic>>{};
      for (final reportee in _reportees) {
        final reporteeGoals = _goals.where((g) => g.employeeId == reportee.id).toList();
        final reporteeSkills = _skills.where((s) => s.employeeId == reportee.id).toList();
        stats[reportee.id] = {
          'activeGoals': reporteeGoals.where((g) => g.status != 'Completed').length,
          'completedGoals': reporteeGoals.where((g) => g.status == 'Completed').length,
          'skillsCount': reporteeSkills.length,
          'rating': 4.0, // Default rating
        };
      }

      if (mounted) {
        setState(() {
          _reporteeStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchManagerData(String managerId) async {
    try {
      final employee = await EmployeeService.getEmployeeById(managerId);
      if (employee != null && mounted) {
        setState(() {
          _managerProfile = {
            'first_name': employee.firstName,
            'last_name': employee.lastName,
            'email': employee.email,
            'department': employee.departmentId,
            'role': employee.roleId,
          };
        });
      }
    } catch (e) {
      print('Error fetching manager data: $e');
    }
  }

  Future<void> _fetchReporteesData(String managerId) async {
    try {
      final reportees = await EmployeeService.getReporteesByManagerId(managerId);
      if (mounted) {
        setState(() {
          _reportees = reportees;
        });
      }
    } catch (e) {
      print('Error fetching reportees data: $e');
    }
  }

  Future<void> _fetchManagerGoals(String managerId) async {
    try {
      // Fetch manager's own goals
      final managerGoals = await GoalService.getGoalsByEmployeeId(managerId);
      
      // Fetch goals for all reportees
      final reporteeGoals = <GoalModel>[];
      for (final reportee in _reportees) {
        if (reportee.id != null) {
          final goals = await GoalService.getGoalsByEmployeeId(reportee.id!);
          reporteeGoals.addAll(goals);
        }
      }
      
      if (mounted) {
        setState(() {
          _goals = [...managerGoals, ...reporteeGoals];
        });
      }
    } catch (e) {
      print('Error fetching goals data: $e');
    }
  }

  Future<void> _fetchManagerAssessments(String managerId) async {
    try {
      // Fetch manager's own assessments
      final managerAssessments = await SelfAssessmentService.getSelfAssessmentsByEmployeeId(managerId);
      
      // Fetch assessments for all reportees
      final reporteeAssessments = <SelfAssessmentModel>[];
      for (final reportee in _reportees) {
        if (reportee.id != null) {
          final assessments = await SelfAssessmentService.getSelfAssessmentsByEmployeeId(reportee.id!);
          reporteeAssessments.addAll(assessments);
        }
      }
      
      if (mounted) {
        setState(() {
          _assessments = [...managerAssessments, ...reporteeAssessments];
        });
      }
    } catch (e) {
      print('Error fetching assessments data: $e');
    }
  }



  Future<void> _fetchManagerSkills(String managerId) async {
    try {
      // Fetch manager's own skills
      final managerSkills = await SkillService.getSkillsByEmployeeId(managerId);
      
      // Fetch skills for all reportees
      final reporteeSkills = <SkillModel>[];
      for (final reportee in _reportees) {
        if (reportee.id != null) {
          final skills = await SkillService.getSkillsByEmployeeId(reportee.id!);
          reporteeSkills.addAll(skills);
        }
      }
      
      if (mounted) {
        setState(() {
          _skills = [...managerSkills, ...reporteeSkills];
        });
      }
    } catch (e) {
      print('Error fetching skills data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: isSmallScreen
          ? AppBar(
              title: const Text('Manager Dashboard'),
              backgroundColor: const Color(0xFF2A2A2A),
              foregroundColor: Colors.white,
            )
          : null,
      body: Row(
        children: [
          // Sidebar for desktop
          if (!isSmallScreen)
            _buildSidebar(),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top navigation bar
                _buildTopNavigation(),
                
                // Main content
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _buildDashboardContent(),
                      ManagerProfileScreen(userModel: widget.userModel),
                      ManagerGoalsScreen(userModel: widget.userModel),
                      ManagerSelfAssessmentScreen(userModel: widget.userModel),
                      Container(), // Feedback screen removed
                      ManagerSkillTrackerScreen(userModel: widget.userModel),
                      ManagerNotificationsScreen(userModel: widget.userModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation for mobile
      bottomNavigationBar: isSmallScreen
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
                _buildNavItem(Icons.person, 'Profile', 1),
                _buildNavItem(Icons.flag, 'Goals', 2),
                _buildNavItem(Icons.assessment, 'Assessments', 3),

                _buildNavItem(Icons.psychology, 'Skills', 5),
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
                    _managerProfile?['first_name']?[0] ?? 'M',
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
                        '${_managerProfile?['first_name'] ?? 'Manager'} ${_managerProfile?['last_name'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _managerProfile?['role_title'] ?? 'Manager',
                        style: const TextStyle(
                          color: Color(0xFF888888),
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
        // Reload data when switching tabs
        _reloadDataForCurrentTab();
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
          label: 'Assessments',
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

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Profile';
      case 2:
        return 'Goals';
      case 3:
        return 'Assessments';
      case 4:
        return 'Feedback';
      case 5:
        return 'Skills';
      case 6:
        return 'Notifications';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
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
          // Welcome Section
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
                  'Welcome, ${_managerProfile?['first_name'] ?? 'Manager'}!',
                  style: const TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manager Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Performance Overview
          Text(
            'My Performance Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 6
                  : constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 600
                          ? 3
                          : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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

          // Team Performance Section
          TeamPerformanceSection(
            reportees: _reportees,
            reporteeStats: _reporteeStats,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'Team Overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildReporteeSelector(),
          const SizedBox(height: 16),
          if (_selectedReportee != null)
            ReporteeSummary(reporteeId: _selectedReportee!.id!)
          else
            const Center(
              child: Text(
                'Select a reportee to view their summary.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReporteeSelector() {
    return DropdownButton<EmployeeModel>(
      value: _selectedReportee,
      hint: const Text('Select a Reportee', style: TextStyle(color: Colors.white70)),
      isExpanded: true,
      dropdownColor: const Color(0xFF2A2A2A),
      onChanged: (EmployeeModel? newValue) {
        setState(() {
          _selectedReportee = newValue;
        });
      },
      items: _reportees.map<DropdownMenuItem<EmployeeModel>>((EmployeeModel reportee) {
        return DropdownMenuItem<EmployeeModel>(
          value: reportee,
          child: Text('${reportee.firstName} ${reportee.lastName}', style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
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

  void _reloadDataForCurrentTab() async {
    // Reload dashboard data for all tabs to ensure fresh data
    // This ensures all performance review data is refreshed
    await _fetchDashboardData();
  }

  void _logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }
}
