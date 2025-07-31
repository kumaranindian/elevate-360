import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';
import '../services/skill_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class EmployeeSkillTrackerScreen extends StatefulWidget {
  final UserModel userModel;

  const EmployeeSkillTrackerScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<EmployeeSkillTrackerScreen> createState() => _EmployeeSkillTrackerScreenState();
}

class _EmployeeSkillTrackerScreenState extends State<EmployeeSkillTrackerScreen> {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _employeeId;
  List<SkillModel> _skills = [];
  Map<String, dynamic> _skillStatistics = {};

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final employee = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      setState(() {
        _employeeId = employee.id;
      });
      _loadSkills();
    } catch (e) {
      print('Error loading employee data: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading employee data: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
      
      // Fallback: try to use the user ID as employee ID
      setState(() {
        _employeeId = widget.userModel.uid;
      });
      _loadSkills();
    }
  }

  Future<void> _loadSkills() async {
    if (_employeeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final skills = await SkillService.getSkillsByEmployeeId(_employeeId!);
      final statistics = await SkillService.getSkillStatistics(_employeeId!);
      
      setState(() {
        _skills = skills;
        _skillStatistics = statistics;
      });
    } catch (e) {
      print('Error loading skills: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading skills: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewSkill() async {
    final result = await _showSkillDialog();
    if (result != null) {
      await _saveSkill(result);
    }
  }

  Future<void> _editSkill(SkillModel skill) async {
    final result = await _showSkillDialog(skill: skill);
    if (result != null) {
      await _saveSkill(result);
    }
  }

  Future<void> _saveSkill(SkillModel skill) async {
    setState(() {
      _isSaving = true;
    });

    try {
      bool success;
      if (skill.id.isEmpty) {
        // New skill
        success = await SkillService.createSkill(skill);
      } else {
        // Update existing skill
        success = await SkillService.updateSkill(skill);
      }

      if (success) {
        await _loadSkills(); // Reload to get updated data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(skill.id.isEmpty ? 'Skill added successfully!' : 'Skill updated successfully!'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error saving skill: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving skill: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteSkill(SkillModel skill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Delete Skill',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.getSubtitleFontSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${skill.skillName}"?',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.getBodyFontSize(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: ResponsiveUtils.getBodyFontSize(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await SkillService.deleteSkill(skill.id);
        if (success) {
          await _loadSkills();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Skill deleted successfully!'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting skill: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<SkillModel?> _showSkillDialog({SkillModel? skill}) async {
    final skillNameController = TextEditingController(text: skill?.skillName ?? '');
    final descriptionController = TextEditingController(text: skill?.description ?? '');
    int selectedProficiency = skill?.proficiencyLevel ?? 3;

    return showDialog<SkillModel>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            skill == null ? 'Add New Skill' : 'Edit Skill',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.getSubtitleFontSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: ResponsiveUtils.isMobile(context) ? double.infinity : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: skillNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Skill Name',
                    labelStyle: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: ResponsiveUtils.getBodyFontSize(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF333333)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF333333)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: ResponsiveUtils.getBodyFontSize(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF333333)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF333333)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proficiency Level: ${_getProficiencyText(selectedProficiency)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primaryColor,
                        inactiveTrackColor: const Color(0xFF333333),
                        thumbColor: AppTheme.primaryColor,
                        overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                        valueIndicatorColor: AppTheme.primaryColor,
                        valueIndicatorTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.getSmallFontSize(context),
                        ),
                      ),
                      child: Slider(
                        value: selectedProficiency.toDouble(),
                        min: 1.0,
                        max: 5.0,
                        divisions: 4,
                        label: selectedProficiency.toString(),
                        onChanged: (value) {
                          setState(() {
                            selectedProficiency = value.round();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (skillNameController.text.trim().isNotEmpty) {
                  final newSkill = SkillModel(
                    id: skill?.id ?? '',
                    employeeId: _employeeId!,
                    skillName: skillNameController.text.trim(),
                    proficiencyLevel: selectedProficiency,
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                    createdAt: skill?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  Navigator.of(context).pop(newSkill);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                skill == null ? 'Add' : 'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProficiencyText(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Elementary';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.buildResponsiveLayout(
      context: context,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                // Debug info (remove in production)
                if (_employeeId != null)
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                    margin: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      'Debug: Employee ID: $_employeeId, Skills Count: ${_skills.length}',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: ResponsiveUtils.getSmallFontSize(context),
                      ),
                    ),
                  ),
                
                SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                
                // Statistics
                _buildStatistics(),
                
                SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                
                // Skills List
                _buildSkillsList(),
                
                // Retry button if no skills loaded
                if (_skills.isEmpty && !_isLoading && _employeeId != null)
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        ElevatedButton.icon(
                          onPressed: _loadSkills,
                          icon: Icon(Icons.refresh),
                          label: Text('Retry Loading Skills'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                'Skill Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
              Text(
                'Manage and track your skills and proficiency levels',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _addNewSkill,
          icon: Icon(
            Icons.add,
            size: ResponsiveUtils.getSmallIconSize(context),
          ),
          label: Text(
            'Add Skill',
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context),
              vertical: ResponsiveUtils.getSpacing(context) / 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalSkills = _skillStatistics['totalSkills'] ?? 0;
    final avgProficiency = _skillStatistics['averageProficiency'] ?? 0.0;
    final proficiencyDistribution = _skillStatistics['proficiencyDistribution'] ?? <int, int>{};

    final stats = [
      {'label': 'Total Skills', 'value': '$totalSkills', 'color': AppTheme.primaryColor},
      {'label': 'Avg Proficiency', 'value': '${avgProficiency.toStringAsFixed(1)}/5.0', 'color': AppTheme.successColor},
      {'label': 'Expert Level', 'value': '${proficiencyDistribution[5] ?? 0}', 'color': AppTheme.successColor},
      {'label': 'Beginner Level', 'value': '${proficiencyDistribution[1] ?? 0}', 'color': AppTheme.warningColor},
    ];

    return ResponsiveUtils.buildResponsiveSection(
      context: context,
      title: 'Skill Statistics',
      icon: Icons.analytics,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;
            
            return Wrap(
              spacing: ResponsiveUtils.getSpacing(context),
              runSpacing: ResponsiveUtils.getSpacing(context),
              children: stats.map((stat) {
                final cardWidth = isSmallScreen
                    ? constraints.maxWidth
                    : isMediumScreen
                        ? (constraints.maxWidth - ResponsiveUtils.getSpacing(context)) / 2
                        : (constraints.maxWidth - ResponsiveUtils.getSpacing(context) * 3) / 4;

                return SizedBox(
                  width: cardWidth,
                  child: Container(
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
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkillsList() {
    return ResponsiveUtils.buildResponsiveSection(
      context: context,
      title: 'My Skills',
      icon: Icons.psychology,
      children: [
        if (_skills.isEmpty)
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
                  'No skills added yet',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),
                Text(
                  'Click "Add Skill" to get started',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              final isMediumScreen = constraints.maxWidth < 900;
              
              return Wrap(
                spacing: ResponsiveUtils.getSpacing(context),
                runSpacing: ResponsiveUtils.getSpacing(context),
                children: _skills.map((skill) {
                  final cardWidth = isSmallScreen
                      ? constraints.maxWidth
                      : isMediumScreen
                          ? (constraints.maxWidth - ResponsiveUtils.getSpacing(context)) / 2
                          : (constraints.maxWidth - ResponsiveUtils.getSpacing(context) * 2) / 3;

                  return SizedBox(
                    width: cardWidth,
                    child: _buildSkillCard(skill),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSkillCard(SkillModel skill) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.skillName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppTheme.textSecondary,
                  size: ResponsiveUtils.getSmallIconSize(context),
                ),
                color: const Color(0xFF2A2A2A),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: AppTheme.primaryColor,
                          size: ResponsiveUtils.getSmallIconSize(context),
                        ),
                        SizedBox(width: ResponsiveUtils.getSpacing(context) / 2),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: AppTheme.errorColor,
                          size: ResponsiveUtils.getSmallIconSize(context),
                        ),
                        SizedBox(width: ResponsiveUtils.getSpacing(context) / 2),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _editSkill(skill);
                  } else if (value == 'delete') {
                    _deleteSkill(skill);
                  }
                },
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Proficiency level
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getSpacing(context) / 2,
                  vertical: ResponsiveUtils.getSpacing(context) / 3,
                ),
                decoration: BoxDecoration(
                  color: skill.proficiencyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  skill.proficiencyText,
                  style: TextStyle(
                    color: skill.proficiencyColor,
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Level ${skill.proficiencyLevel}/5',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: ResponsiveUtils.getSmallFontSize(context),
                ),
              ),
            ],
          ),
          
          if (skill.description != null) ...[
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            Text(
              skill.description!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: ResponsiveUtils.getSmallFontSize(context),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          
          // Progress bar
          LinearProgressIndicator(
            value: skill.proficiencyLevel / 5,
            backgroundColor: const Color(0xFF333333),
            valueColor: AlwaysStoppedAnimation<Color>(skill.proficiencyColor),
          ),
        ],
      ),
    );
  }
} 