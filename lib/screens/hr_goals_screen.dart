import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import '../models/employee_model.dart';
import '../services/goal_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import '../core/providers/auth_provider.dart' show currentUserProvider;

class HRGoalsScreen extends ConsumerStatefulWidget {
  const HRGoalsScreen({super.key});

  @override
  ConsumerState<HRGoalsScreen> createState() => _HRGoalsScreenState();
}

class _HRGoalsScreenState extends ConsumerState<HRGoalsScreen> {
  Map<String, List<GoalModel>> _goalsByManager = {};
  List<GoalModel> _filteredGoals = [];
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _managers = [];
  List<GoalCategoryModel> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All Statuses';
  String _selectedDateFilter = 'Due Date';
  String _selectedTab = 'Manager Goals';
  String? _selectedManagerId;
  
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
    'Manager Goals',
    'My Goals',
    'All Goals',
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
      // Load data from Firebase
      final employees = await EmployeeService.getAllEmployees();
      final categories = await GoalService.getGoalCategories();
      final goalsByManager = await GoalService.getAllGoalsGroupedByManager();
      
      // Filter managers from employees
      final managers = employees.where((emp) => 
        employees.any((e) => e.managerId == emp.id)
      ).toList();
      
      setState(() {
        _goalsByManager = goalsByManager;
        _employees = employees;
        _managers = managers;
        _categories = categories;
        _filteredGoals = _selectedManagerId != null && goalsByManager.containsKey(_selectedManagerId)
          ? goalsByManager[_selectedManagerId]!
          : goalsByManager.values.expand((goals) => goals).toList();
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
      var allGoals = _selectedManagerId != null && _goalsByManager.containsKey(_selectedManagerId)
          ? _goalsByManager[_selectedManagerId]!
          : _goalsByManager.values.expand((goals) => goals).toList();

      _filteredGoals = allGoals.where((goal) {
        final matchesSearch = goal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (goal.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        final matchesStatusFilter = _selectedFilter == 'All Statuses' || 
            goal.status == _selectedFilter;

        final matchesTab = _selectedTab == 'All Goals' ||
            (_selectedTab == 'Manager Goals' && _selectedManagerId != null && goal.managerId == _selectedManagerId) ||
            (_selectedTab == 'My Goals' && goal.employeeId == ref.read(currentUserProvider)?.uid);
        
        return matchesSearch && matchesStatusFilter && matchesTab;
      }).toList();

      // Sort goals based on the selected date filter
      _filteredGoals.sort((a, b) {
        switch (_selectedDateFilter) {
          case 'Due Date':
            return a.dueDate.compareTo(b.dueDate);
          case 'Created Date':
            return a.createdAt.compareTo(b.createdAt);
          case 'Updated Date':
            return a.updatedAt.compareTo(b.updatedAt);
          default:
            return 0;
        }
      });
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
                  onPressed: () => _showCreateGoalDialog(),
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
            child: Column(
              children: [
                Row(
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
                if (_selectedTab == 'Manager Goals') ...[
                  const SizedBox(height: 16),
                  // Manager Selection
                  DropdownButtonFormField<String>(
                    value: _selectedManagerId,
                    onChanged: (value) {
                      setState(() {
                        _selectedManagerId = value;
                      });
                      _filterGoals();
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Manager',
                      labelStyle: TextStyle(color: Colors.grey[400]),
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
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Managers', style: TextStyle(color: Colors.white)),
                      ),
                      ..._managers.map((manager) {
                        return DropdownMenuItem(
                          value: manager.id,
                          child: Text(
                            '${manager.firstName} ${manager.lastName}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
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
    final managerName = _getEmployeeName(goal.managerId);
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
              Icon(Icons.supervisor_account, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Text(
                managerName,
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

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showEditGoalDialog(goal),
                icon: Icon(Icons.edit, color: Colors.grey[400]),
                tooltip: 'Edit Goal',
              ),
              IconButton(
                onPressed: () => _showAssignGoalDialog(goal),
                icon: Icon(Icons.assignment_ind, color: Colors.grey[400]),
                tooltip: 'Assign Goal',
              ),
              IconButton(
                onPressed: () => _showDeleteGoalDialog(goal),
                icon: Icon(Icons.delete, color: Colors.grey[400]),
                tooltip: 'Delete Goal',
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

  Future<void> _showEditGoalDialog(GoalModel goal) async {
    final formKey = GlobalKey<FormState>();
    String title = goal.title;
    String? description = goal.description;
    String priority = goal.priority;
    String goalType = goal.goalType;
    double weightage = goal.weightage;
    double? targetValue = goal.targetValue;
    String? unit = goal.unit;
    DateTime startDate = goal.startDate;
    DateTime dueDate = goal.dueDate;
    String? categoryId = goal.categoryId;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Goal'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) => title = value,
                ),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  onChanged: (value) => description = value,
                ),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['High', 'Medium', 'Low'].map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) priority = value;
                  },
                ),
                TextFormField(
                  initialValue: weightage.toString(),
                  decoration: const InputDecoration(labelText: 'Weightage'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final number = double.tryParse(value);
                    if (number == null) return 'Invalid number';
                    if (number < 0 || number > 100) return 'Must be between 0 and 100';
                    return null;
                  },
                  onChanged: (value) {
                    final number = double.tryParse(value);
                    if (number != null) weightage = number;
                  },
                ),
                // Add more fields as needed
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final updatedGoal = GoalModel(
                  id: goal.id,
                  employeeId: goal.employeeId,
                  managerId: goal.managerId,
                  categoryId: categoryId,
                  projectId: goal.projectId,
                  title: title,
                  description: description,
                  goalType: goalType,
                  priority: priority,
                  weightage: weightage,
                  targetValue: targetValue,
                  currentValue: goal.currentValue,
                  unit: unit,
                  measurementMethod: goal.measurementMethod,
                  startDate: startDate,
                  dueDate: dueDate,
                  completionDate: goal.completionDate,
                  status: goal.status,
                  progressPercentage: goal.progressPercentage,
                  isStretchGoal: goal.isStretchGoal,
                  createdBy: goal.createdBy,
                  approvedBy: goal.approvedBy,
                  createdAt: goal.createdAt,
                  updatedAt: DateTime.now(),
                );

                try {
                  await GoalService.updateGoal(updatedGoal);
                  _loadData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating goal: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssignGoalDialog(GoalModel goal) async {
    final selectedEmployees = <String>{};
    final employeesUnderManager = _employees
        .where((emp) => emp.managerId == goal.managerId)
        .toList();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Goal'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select employees to assign this goal to:'),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: employeesUnderManager.length,
                  itemBuilder: (context, index) {
                    final employee = employeesUnderManager[index];
                    return CheckboxListTile(
                      title: Text('${employee.firstName} ${employee.lastName}'),
                      value: selectedEmployees.contains(employee.id),
                      onChanged: (checked) {
                        setState(() {
                          if (checked ?? false) {
                            selectedEmployees.add(employee.id);
                          } else {
                            selectedEmployees.remove(employee.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedEmployees.isNotEmpty) {
                try {
                  await GoalService.assignGoalToEmployees(
                    goal,
                    selectedEmployees.toList(),
                  );
                  _loadData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal assigned successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error assigning goal: $e')),
                  );
                }
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteGoalDialog(GoalModel goal) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await GoalService.deleteGoal(goal.id);
                _loadData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting goal: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateGoalDialog() async {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String? description;
    String priority = 'Medium';
    String goalType = 'Performance';
    double weightage = 0;
    double? targetValue;
    String? unit;
    DateTime startDate = DateTime.now();
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));
    String? categoryId;
    String? selectedManagerId;
    List<String> selectedEmployees = [];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Goal'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) => title = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  onChanged: (value) => description = value,
                ),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['High', 'Medium', 'Low'].map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) priority = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: goalType,
                  decoration: const InputDecoration(labelText: 'Goal Type'),
                  items: ['Performance', 'Development', 'Project', 'Learning'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) goalType = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Weightage'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final number = double.tryParse(value);
                    if (number == null) return 'Invalid number';
                    if (number < 0 || number > 100) return 'Must be between 0 and 100';
                    return null;
                  },
                  onChanged: (value) {
                    final number = double.tryParse(value);
                    if (number != null) weightage = number;
                  },
                ),
                // Manager Selection
                DropdownButtonFormField<String>(
                  value: selectedManagerId,
                  decoration: const InputDecoration(labelText: 'Select Manager'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Select a Manager')),
                    ..._managers.map((manager) {
                      return DropdownMenuItem(
                        value: manager.id,
                        child: Text('${manager.firstName} ${manager.lastName}'),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedManagerId = value;
                      selectedEmployees.clear(); // Reset selected employees when manager changes
                    });
                  },
                ),
                // Employee Selection (shown only when manager is selected)
                if (selectedManagerId != null) ...[
                  const SizedBox(height: 16),
                  const Text('Select Employees:'),
                  const SizedBox(height: 8),
                  ...(_employees
                      .where((emp) => emp.managerId == selectedManagerId)
                      .map((employee) {
                    return CheckboxListTile(
                      title: Text('${employee.firstName} ${employee.lastName}'),
                      value: selectedEmployees.contains(employee.id),
                      onChanged: (checked) {
                        setState(() {
                          if (checked ?? false) {
                            selectedEmployees.add(employee.id);
                          } else {
                            selectedEmployees.remove(employee.id);
                          }
                        });
                      },
                    );
                  }).toList()),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  // Create base goal model
                  final goalTemplate = GoalModel(
                    id: '', // Will be set by Firebase
                    employeeId: '', // Will be set for each employee
                    managerId: selectedManagerId ?? '',
                    categoryId: categoryId,
                    projectId: null,
                    title: title,
                    description: description,
                    goalType: goalType,
                    priority: priority,
                    weightage: weightage,
                    targetValue: targetValue,
                    currentValue: 0,
                    unit: unit,
                    measurementMethod: null,
                    startDate: startDate,
                    dueDate: dueDate,
                    completionDate: null,
                    status: 'Not Started',
                    progressPercentage: 0,
                    isStretchGoal: false,
                    createdBy: ref.read(currentUserProvider)?.uid ?? '',
                    approvedBy: null,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  // Assign goal to selected employees
                  if (selectedEmployees.isNotEmpty) {
                    await GoalService.assignGoalToEmployees(
                      goalTemplate,
                      selectedEmployees,
                    );
                  }

                  _loadData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal created and assigned successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating goal: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
} 