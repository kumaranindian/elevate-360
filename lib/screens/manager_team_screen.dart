import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../services/goal_service.dart';
import '../services/skill_service.dart';
import '../core/utils/app_theme.dart';

class ManagerTeamScreen extends StatefulWidget {
  final UserModel userModel;

  const ManagerTeamScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ManagerTeamScreen> createState() => _ManagerTeamScreenState();
}

class _ManagerTeamScreenState extends State<ManagerTeamScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'On Leave', 'New'];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;
  List<EmployeeModel> _reportees = [];
  Map<String, dynamic> _reporteeStats = {};

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load reportees from Firebase
      final reportees = await EmployeeService.getReporteesByManagerId(widget.userModel.uid);
      
      // Load stats for each reportee
      final stats = <String, dynamic>{};
      for (final reportee in reportees) {
        final goals = await GoalService.getGoalsByEmployeeId(reportee.id);
        final skills = await SkillService.getSkillsByEmployeeId(reportee.id);
        
        stats[reportee.id] = {
          'goalsCompleted': goals.where((g) => g.status == 'Completed').length,
          'totalGoals': goals.length,
          'skillsCount': skills.length,
          'performance': 4.0, // This would come from performance reviews
        };
      }

      setState(() {
        _reportees = reportees;
        _reporteeStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
              onPressed: _loadTeamData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredMembers = _getFilteredMembers();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'List of direct reports and quick access to each profile',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addTeamMember,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Member'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Team Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Team Size',
                  '${_reportees.length}',
                  Icons.group,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Members',
                  '${_reportees.where((r) => r.employmentStatus == 'Active').length}',
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Avg Performance',
                  '4.1',
                  Icons.trending_up,
                  AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Goals Completed',
                  '${_reporteeStats.values.fold(0, (sum, stats) => sum + (stats['goalsCompleted'] as int))}',
                  Icons.flag,
                  AppTheme.infoColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Search and Filter
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF2A2A2A),
                    items: _filters.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Team Members Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: filteredMembers.length,
            itemBuilder: (context, index) {
              return _buildTeamMemberCard(filteredMembers[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(Map<String, dynamic> member) {
    final statusColor = _getStatusColor(member['status']);
    final performanceColor = _getPerformanceColor(member['performance']);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  member['avatar'],
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
                      member['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      member['position'],
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  member['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Performance
          Row(
            children: [
              Icon(
                Icons.star,
                color: performanceColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${member['performance']}',
                style: TextStyle(
                  color: performanceColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Performance',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Goals Progress
          Row(
            children: [
              Icon(
                Icons.flag,
                color: AppTheme.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${member['goalsCompleted']}/${member['totalGoals']}',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Goals',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Current Project
          Row(
            children: [
              Icon(
                Icons.work,
                color: AppTheme.infoColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  member['currentProject'],
                  style: TextStyle(
                    color: AppTheme.infoColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Skills
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: member['skills'].take(3).map<Widget>((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewProfile(member),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _sendMessage(member),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: BorderSide(color: AppTheme.textSecondary),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppTheme.successColor;
      case 'On Leave':
        return AppTheme.warningColor;
      case 'New':
        return AppTheme.infoColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getPerformanceColor(double performance) {
    if (performance >= 4.0) {
      return AppTheme.successColor;
    } else if (performance >= 3.0) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  List<Map<String, dynamic>> _getFilteredMembers() {
    List<Map<String, dynamic>> filtered = _reportees.map((reportee) {
      final stats = _reporteeStats[reportee.id] ?? {'performance': 4.0, 'goalsCompleted': 0, 'totalGoals': 0};
      return {
        'id': reportee.id,
        'name': '${reportee.firstName} ${reportee.lastName}',
        'position': reportee.roleId,
        'email': reportee.email,
        'avatar': '${reportee.firstName[0]}${reportee.lastName[0]}',
        'status': reportee.employmentStatus,
        'performance': stats['performance'] as double,
        'goalsCompleted': stats['goalsCompleted'] as int,
        'totalGoals': stats['totalGoals'] as int,
        'lastReview': '2024-01-15', // This would come from performance reviews
        'department': reportee.departmentId,
        'joinDate': reportee.hireDate.toString().split(' ')[0],
        'skills': ['Flutter', 'Dart', 'Firebase'], // This would come from skills collection
        'currentProject': 'Project A', // This would come from project assignments
      };
    }).toList();
    
    // Filter by status
    if (_selectedFilter != 'All') {
      filtered = filtered.where((member) => member['status'] == _selectedFilter).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((member) {
        return member['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               member['position'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               member['email'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  void _addTeamMember() {
    // TODO: Implement add team member functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add team member functionality coming soon!'),
        backgroundColor: AppTheme.infoColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewProfile(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          '${member['name']} - Profile',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProfileDetail('Position', member['position']),
              _buildProfileDetail('Email', member['email']),
              _buildProfileDetail('Department', member['department']),
              _buildProfileDetail('Join Date', member['joinDate']),
              _buildProfileDetail('Performance', '${member['performance']}/5.0'),
              _buildProfileDetail('Goals', '${member['goalsCompleted']}/${member['totalGoals']}'),
              _buildProfileDetail('Current Project', member['currentProject']),
              _buildProfileDetail('Last Review', member['lastReview']),
              const SizedBox(height: 16),
              Text(
                'Skills:',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: member['skills'].map<Widget>((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _scheduleReview(member),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Schedule Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(Map<String, dynamic> member) {
    // TODO: Implement message functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${member['name']}...'),
        backgroundColor: AppTheme.infoColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scheduleReview(Map<String, dynamic> member) {
    // TODO: Implement schedule review functionality
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scheduling review for ${member['name']}...'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 