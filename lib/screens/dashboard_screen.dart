import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/employee_model.dart';
import '../models/goal_model.dart';
import '../models/review_model.dart';
import '../services/employee_service.dart';
import '../services/goal_service.dart';
import '../services/review_service.dart';
import '../core/utils/app_theme.dart';
import '../core/services/auth_service.dart';
import '../core/providers/auth_provider.dart';
import '../core/widgets/app_logo.dart';
import 'employees_screen.dart';
import 'goals_screen.dart';
import 'hr_goals_screen.dart';
import 'master_data_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final UserModel userModel;

  const DashboardScreen({
    super.key,
    required this.userModel,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  
  // Data from Firebase
  List<EmployeeModel> _employees = [];
  List<GoalModel> _goals = [];
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load data from Firebase based on user role
      if (widget.userModel.isHrAdmin || widget.userModel.isSuperAdmin) {
        // HR and Admin can see all data
        final employees = await EmployeeService.getAllEmployees();
        final goals = await GoalService.getAllGoals();
        final reviews = await ReviewService.getAllReviews();
        
        setState(() {
          _employees = employees;
          _goals = goals;
          _reviews = reviews;
          _isLoading = false;
        });
      } else if (widget.userModel.role == 'manager') {
        // Managers can see their team data
        final employees = await EmployeeService.getAllEmployees();
        final goals = await GoalService.getAllGoals();
        final reviews = await ReviewService.getAllReviews();
        
        // Filter for manager's team (simplified - in real app, filter by manager_id)
        setState(() {
          _employees = employees;
          _goals = goals;
          _reviews = reviews;
          _isLoading = false;
        });
      } else {
        // Employees can see their own data
        final goals = await GoalService.getGoalsByEmployeeId(widget.userModel.uid);
        final reviews = await ReviewService.getReviewsByEmployeeId(widget.userModel.uid);
        
        setState(() {
          _goals = goals;
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading dashboard data: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Row(
        children: [
          // Sidebar
          if (MediaQuery.of(context).size.width > 768) _buildSidebar(),
          
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
                _buildSidebarItem(Icons.dashboard, 'Dashboard', 0),
                _buildSidebarItem(Icons.people, 'Employees', 1),
                _buildSidebarItem(Icons.flag, 'Goals', 2),
                _buildSidebarItem(Icons.rate_review, 'Reviews', 3),
                _buildSidebarItem(Icons.assessment, 'Reports', 4),
              ],
            ),
          ),
          
          const Divider(color: Color(0xFF333333), height: 1),
          
          // User profile section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        widget.userModel.username.isNotEmpty 
                            ? widget.userModel.username[0].toUpperCase()
                            : 'U',
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
                            widget.userModel.role.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final authService = ref.read(authServiceProvider);
                      await authService.signOut();
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF888888),
                      side: const BorderSide(color: Color(0xFF333333)),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
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
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Mobile menu button
          if (MediaQuery.of(context).size.width <= 768)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Show mobile menu
                _showMobileMenu();
              },
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
          
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              widget.userModel.username.isNotEmpty 
                  ? widget.userModel.username[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0F0F0F),
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: const Color(0xFF888888),
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
        BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: 'Reviews'),
        BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Reports'),
      ],
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const EmployeesScreen();
      case 2:
        return const HRGoalsScreen();
      case 3:
        return _buildReviewsContent();
      case 4:
        return _buildReportsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final padding = isDesktop ? 16.0 : 24.0;
    final spacing = isDesktop ? 16.0 : 32.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${widget.userModel.username}!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${widget.userModel.role.replaceAll('_', ' ').toUpperCase()}',
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: isDesktop ? 14 : 16,
                  ),
                ),
                SizedBox(height: isDesktop ? 16 : 20),
                
                // User info card
                Container(
                  padding: EdgeInsets.all(isDesktop ? 16 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333), width: 1),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: isDesktop ? 24 : 30,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: isDesktop ? 24 : 30,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userModel.username,
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.userModel.email,
                              style: const TextStyle(
                                color: Color(0xFF888888),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.userModel.isActive 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.userModel.isActive ? 'Active' : 'Pending',
                                style: TextStyle(
                                  color: widget.userModel.isActive 
                                      ? Colors.green 
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF888888),
                            size: 16,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Joined: ${_formatDate(widget.userModel.createdAt)}',
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: spacing),
          
          // Dashboard modules
          const Text(
            'Your Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isDesktop ? 12 : 20),
          
          // Module cards
          if (widget.userModel.isSuperAdmin) ...[
            _buildModuleCard(
              Icons.people,
              'User Management',
              'Manage all user accounts and permissions',
              isDesktop,
            ),
            _buildModuleCard(
              Icons.admin_panel_settings,
              'HR Approval',
              'Review and approve pending HR signups',
              isDesktop,
            ),
            _buildModuleCard(
              Icons.analytics,
              'System Analytics',
              'View system-wide performance metrics',
              isDesktop,
            ),
          ] else if (widget.userModel.isHrAdmin) ...[
            _buildModuleCard(
              Icons.people,
              'Employee Management',
              'Manage employee profiles and data',
              isDesktop,
            ),
            _buildModuleCard(
              Icons.rate_review,
              'Performance Reviews',
              'Conduct and manage performance reviews',
              isDesktop,
            ),
            _buildModuleCard(
              Icons.business,
              'Department Management',
              'Manage departments and teams',
              isDesktop,
            ),
            _buildModuleCard(
              Icons.storage,
              'Master Data Management',
              'Insert master data from SQL schema',
              isDesktop,
              onTap: () => _navigateToMasterData(),
            ),
          ] else ...[
            _buildModuleCard(
              Icons.person,
              'My Profile',
              'View and update your profile information',
              isDesktop,
            ),
            _buildModuleCard(
              Icons.flag,
              'My Goals',
              'Track your performance goals',
              isDesktop,
            ),
            _buildModuleCard(
              Icons.history,
              'My Reviews',
              'View your performance reviews',
              isDesktop,
            ),
          ],
          
          SizedBox(height: spacing),
          
          // Data Overview Section
          if (!_isLoading) ...[
            const Text(
              'Data Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 12 : 20),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Employees',
                    _employees.length.toString(),
                    Icons.people,
                    AppTheme.primaryColor,
                    isDesktop,
                  ),
                ),
                SizedBox(width: isDesktop ? 12 : 16),
                Expanded(
                  child: _buildStatCard(
                    'Goals',
                    _goals.length.toString(),
                    Icons.flag,
                    AppTheme.successColor,
                    isDesktop,
                  ),
                ),
                SizedBox(width: isDesktop ? 12 : 16),
                Expanded(
                  child: _buildStatCard(
                    'Reviews',
                    _reviews.length.toString(),
                    Icons.rate_review,
                    AppTheme.warningColor,
                    isDesktop,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isDesktop ? 20 : 24),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: isDesktop ? 24 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: isDesktop ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(IconData icon, String title, String description, bool isDesktop, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isDesktop ? 12 : 16),
        padding: EdgeInsets.all(isDesktop ? 16 : 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: isDesktop ? 40 : 50,
              height: isDesktop ? 40 : 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: isDesktop ? 20 : 24,
              ),
            ),
            SizedBox(width: isDesktop ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: const Color(0xFF888888),
                      fontSize: isDesktop ? 13 : 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF888888),
              size: isDesktop ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesContent() {
    return const Center(
      child: Text(
        'Employees Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildGoalsContent() {
    return const Center(
      child: Text(
        'Goals Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildReviewsContent() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _reviews.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews found',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  return _buildReviewCard(review);
                },
              );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${review.reviewType} - ${review.quarter} ${review.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comments,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getReviewStatusColor(review.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  review.status,
                  style: TextStyle(
                    color: _getReviewStatusColor(review.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(Icons.star, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Text(
                'Rating: ${review.rating}/5',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 24),
              Icon(Icons.assessment, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Text(
                'Overall: ${review.overallRating}/5',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
    return const Center(
      child: Text(
        'Reports & Analytics',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Color _getReviewStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.successColor;
      case 'In Review':
        return AppTheme.primaryColor;
      case 'Pending':
        return AppTheme.warningColor;
      case 'Approved':
        return AppTheme.successColor;
      default:
        return AppTheme.infoColor;
    }
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Employees';
      case 2:
        return 'Goals & Objectives';
      case 3:
        return 'Reviews';
      case 4:
        return 'Reports';
      default:
        return 'Dashboard';
    }
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.white),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.white),
              title: const Text('Employees', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.white),
              title: const Text('Goals', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review, color: Colors.white),
              title: const Text('Reviews', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment, color: Colors.white),
              title: const Text('Reports', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMasterData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MasterDataScreen()),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}