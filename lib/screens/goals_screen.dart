import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import '../models/employee_model.dart';
import '../services/goal_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  List<GoalModel> _goals = [];
  List<GoalModel> _filteredGoals = [];
  List<EmployeeModel> _employees = [];
  List<GoalCategoryModel> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All Statuses';
  String _selectedDateFilter = 'Due Date';
  String _selectedTab = 'My Goals';
  
  final List<String> _filterOptions = [
    'All Statuses',
    'Not Started',
    'In Progress',
    'Completed',
    'Overdue',
  ];

  final List<String> _dateFilterOptions = [
    'Due Date',
    'Created Date',
    'Updated Date',
  ];

  final List<String> _tabOptions = [
    'My Goals',
    'Team Goals',
    'Company Initiatives',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load goals from Firebase
      final goals = await GoalService.getAllGoals();
      final employees = await EmployeeService.getAllEmployees();
      final categories = await GoalService.getGoalCategories();
      
      setState(() {
        _goals = goals;
        _filteredGoals = goals;
        _employees = employees;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading goals: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _filterGoals() {
    setState(() {
      _filteredGoals = _goals.where((goal) {
        final matchesSearch = goal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (goal.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        final matchesStatusFilter = _selectedFilter == 'All Statuses' || 
            goal.status == _selectedFilter;
        
        return matchesSearch && matchesStatusFilter;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterGoals();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterGoals();
  }

  void _onDateFilterChanged(String filter) {
    setState(() {
      _selectedDateFilter = filter;
    });
    _filterGoals();
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
    });
    _filterGoals();
  }

  String _getEmployeeName(String employeeId) {
    final employee = _employees.firstWhere(
      (emp) => emp.id == employeeId,
      orElse: () => EmployeeModel(
        id: '',
        employeeId: 'Unknown',
        firstName: 'Unknown',
        lastName: 'Employee',
        email: '',
        departmentId: '',
        roleId: '',
        teamId: '',
        managerId: '',
        employmentStatus: '',
        employeeType: '',
        workLocation: '',
        currentSalary: 0,
        hireDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return '${employee.firstName} ${employee.lastName}';
  }

  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => GoalCategoryModel(
        id: '',
        name: 'Unknown',
        description: '',
        categoryType: '',
        colorCode: '#888888',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
    return category.name;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.successColor;
      case 'In Progress':
        return AppTheme.primaryColor;
      case 'Not Started':
        return AppTheme.warningColor;
      case 'Overdue':
        return AppTheme.errorColor;
      default:
        return AppTheme.infoColor;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppTheme.errorColor;
      case 'Medium':
        return AppTheme.warningColor;
      case 'Low':
        return AppTheme.successColor;
      default:
        return AppTheme.infoColor;
    }
  }

  double _getProgressPercentage(GoalModel goal) {
    if (goal.targetValue != null && goal.targetValue! > 0) {
      return (goal.currentValue / goal.targetValue! * 100).clamp(0.0, 100.0);
    }
    return goal.progressPercentage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF333333), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Goals & Objectives',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track and manage performance goals across the organization',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement add goal functionality
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Goal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Filters and Search
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Search
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search goals...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Status Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    onChanged: (value) {
                      if (value != null) _onFilterChanged(value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF2A2A2A),
                    items: _filterOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Date Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDateFilter,
                    onChanged: (value) {
                      if (value != null) _onDateFilterChanged(value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF2A2A2A),
                    items: _dateFilterOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Tab Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: _tabOptions.map((tab) {
                final isSelected = _selectedTab == tab;
                return GestureDetector(
                  onTap: () => _onTabChanged(tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : const Color(0xFF333333),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Goals List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGoals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No goals found',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filteredGoals.length,
                        itemBuilder: (context, index) {
                          final goal = _filteredGoals[index];
                          return _buildGoalCard(goal);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final progress = _getProgressPercentage(goal);
    final employeeName = _getEmployeeName(goal.employeeId);
    final categoryName = goal.categoryId != null ? _getCategoryName(goal.categoryId!) : 'Uncategorized';
    
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
                      goal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      goal.description ?? 'No description provided',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(goal.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.status,
                      style: TextStyle(
                        color: _getStatusColor(goal.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(goal.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.priority,
                      style: TextStyle(
                        color: _getPriorityColor(goal.priority),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Text(
                employeeName,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 24),
              Icon(Icons.category, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Text(
                categoryName,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 24),
              Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Text(
                'Due: ${_formatDate(goal.dueDate)}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  Text(
                    '${progress.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: const Color(0xFF333333),
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(goal.status)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 