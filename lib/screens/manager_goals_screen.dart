import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/goal_model.dart';
import '../models/employee_model.dart';
import '../services/goal_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';

class ManagerGoalsScreen extends StatefulWidget {
  final UserModel userModel;

  const ManagerGoalsScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ManagerGoalsScreen> createState() => _ManagerGoalsScreenState();
}

class _ManagerGoalsScreenState extends State<ManagerGoalsScreen> {
  bool _isLoading = true;
  String? _error;
  List<GoalModel> _myGoals = [];
  List<EmployeeModel> _reportees = [];
  EmployeeModel? _selectedReportee;
  List<GoalModel> _reporteeGoals = [];
  String _selectedTab = 'My Goals';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load manager's own goals
      final manager = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      final myGoals = await GoalService.getGoalsByEmployeeId(manager.id);
      
      // Load reportees from Firebase
      final reportees = await EmployeeService.getReporteesByManagerId(widget.userModel.uid);

      setState(() {
        _myGoals = myGoals;
        _reportees = reportees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }



  Future<void> _loadReporteeGoals(String reporteeId) async {
    try {
      final goals = await GoalService.getGoalsByEmployeeId(reporteeId);
      setState(() {
        _reporteeGoals = goals;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading reportee goals: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: _loadData,
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
          // Header
          Row(
            children: [
              Text(
                'Goals Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add goal
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Goal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('My Goals', _selectedTab == 'My Goals'),
                ),
                Expanded(
                  child: _buildTabButton('Team Goals', _selectedTab == 'Team Goals'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content based on selected tab
          if (_selectedTab == 'My Goals')
            _buildMyGoalsContent()
          else
            _buildTeamGoalsContent(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMyGoalsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Goals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_myGoals.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No goals found',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _myGoals.length,
            itemBuilder: (context, index) {
              final goal = _myGoals[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.title ?? 'Untitled Goal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(goal.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            goal.status,
                            style: TextStyle(
                              color: _getStatusColor(goal.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      goal.description ?? 'No description available',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (goal.progressPercentage as num) / 100,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${goal.progressPercentage}% Complete',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTeamGoalsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Team Goals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Reportee Dropdown
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<EmployeeModel>(
                  value: _selectedReportee,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  hint: const Text('Select Reportee', style: TextStyle(color: Colors.white70)),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  items: _reportees.map((reportee) {
                    return DropdownMenuItem<EmployeeModel>(
                      value: reportee,
                      child: Text(
                        '${reportee.firstName} ${reportee.lastName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (EmployeeModel? value) {
                    setState(() {
                      _selectedReportee = value;
                    });
                    if (value != null) {
                      _loadReporteeGoals(value.id);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_selectedReportee == null)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.group_outlined, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Select a reportee to view their goals',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else if (_reporteeGoals.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No goals found for ${_selectedReportee!.firstName}',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement assign goal
                    },
                    child: Text('Assign Goal'),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Text(
                    '${_selectedReportee!.firstName}\'s Goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement assign goal
                    },
                    child: Text('Assign Goal'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reporteeGoals.length,
                itemBuilder: (context, index) {
                  final goal = _reporteeGoals[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal.title ?? 'Untitled Goal',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(goal.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                goal.status,
                                style: TextStyle(
                                  color: _getStatusColor(goal.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          goal.description ?? 'No description available',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (goal.progressPercentage as num) / 100,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${goal.progressPercentage}% Complete',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'not started':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 