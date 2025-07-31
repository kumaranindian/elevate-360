import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';
import '../models/employee_model.dart';
import '../services/skill_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';

class ManagerSkillTrackerScreen extends StatefulWidget {
  final UserModel userModel;

  const ManagerSkillTrackerScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ManagerSkillTrackerScreen> createState() => _ManagerSkillTrackerScreenState();
}

class _ManagerSkillTrackerScreenState extends State<ManagerSkillTrackerScreen> {
  bool _isLoading = true;
  String? _error;
  List<SkillModel> _mySkills = [];
  List<EmployeeModel> _reportees = [];
  EmployeeModel? _selectedReportee;
  List<SkillModel> _reporteeSkills = [];
  String _selectedTab = 'My Skills';

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
      // Load manager's own skills
      final manager = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      final mySkills = await SkillService.getSkillsByEmployeeId(manager.id);
      
      // Load reportees from Firebase
      final reportees = await EmployeeService.getReporteesByManagerId(widget.userModel.uid);

      setState(() {
        _mySkills = mySkills;
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



  Future<void> _loadReporteeSkills(String reporteeId) async {
    try {
      final skills = await SkillService.getSkillsByEmployeeId(reporteeId);
      setState(() {
        _reporteeSkills = skills;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading reportee skills: $e'),
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
                'Skill Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add skill
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Skill'),
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
                  child: _buildTabButton('My Skills', _selectedTab == 'My Skills'),
                ),
                Expanded(
                  child: _buildTabButton('Team Skills', _selectedTab == 'Team Skills'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content based on selected tab
          if (_selectedTab == 'My Skills')
            _buildMySkillsContent()
          else
            _buildTeamSkillsContent(),
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

  Widget _buildMySkillsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Skills',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_mySkills.isEmpty)
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
                  Icon(Icons.psychology_outlined, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No skills found',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _mySkills.length,
            itemBuilder: (context, index) {
              final skill = _mySkills[index];
              return Container(
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
                            skill.skillName ?? 'Unknown Skill',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Implement edit skill
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proficiency: ${skill.proficiencyLevel}/5',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (skill.proficiencyLevel ?? 0) / 5,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTeamSkillsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Team Skills',
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
                      _loadReporteeSkills(value.id);
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
                    'Select a reportee to view their skills',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else if (_reporteeSkills.isEmpty)
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
                  Icon(Icons.psychology_outlined, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No skills found for ${_selectedReportee!.firstName}',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              Text(
                '${_selectedReportee!.firstName}\'s Skills',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _reporteeSkills.length,
                itemBuilder: (context, index) {
                  final skill = _reporteeSkills[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.skillName ?? 'Unknown Skill',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Proficiency: ${skill.proficiencyLevel}/5',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (skill.proficiencyLevel ?? 0) / 5,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
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
} 