import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/self_assessment_model.dart';
import '../models/employee_model.dart';
import '../services/self_assessment_service.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';

class ManagerAssessmentsScreen extends StatefulWidget {
  final UserModel userModel;

  const ManagerAssessmentsScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ManagerAssessmentsScreen> createState() => _ManagerAssessmentsScreenState();
}

class _ManagerAssessmentsScreenState extends State<ManagerAssessmentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<SelfAssessmentModel> _myAssessments = [];
  List<EmployeeModel> _reportees = [];
  EmployeeModel? _selectedReportee;
  List<SelfAssessmentModel> _reporteeAssessments = [];
  String _selectedTab = 'My Assessments';
  String _selectedQuarter = '';

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
      // Load manager's own assessments
      final manager = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      final myAssessments = await SelfAssessmentService.getSelfAssessmentsByEmployeeId(manager.id);
      
      // Load reportees from Firebase
      final reportees = await EmployeeService.getReporteesByManagerId(widget.userModel.uid);

      setState(() {
        _myAssessments = myAssessments;
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



  Future<void> _loadReporteeAssessments(String reporteeId) async {
    try {
      final assessments = await SelfAssessmentService.getSelfAssessmentsByEmployeeId(reporteeId);
      setState(() {
        _reporteeAssessments = assessments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading reportee assessments: $e'),
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
                'Assessments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement create assessment
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Assessment'),
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
                  child: _buildTabButton('My Assessments', _selectedTab == 'My Assessments'),
                ),
                Expanded(
                  child: _buildTabButton('Team Reviews', _selectedTab == 'Team Reviews'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content based on selected tab
          if (_selectedTab == 'My Assessments')
            _buildMyAssessmentsContent()
          else
            _buildTeamReviewsContent(),
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

  Widget _buildMyAssessmentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'My Self-Assessments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Quarter Dropdown
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedQuarter.isEmpty ? null : _selectedQuarter,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  hint: const Text('Select Quarter', style: TextStyle(color: Colors.white70)),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  items: SelfAssessmentService.getAvailableQuarters().map((quarter) {
                    return DropdownMenuItem<String>(
                      value: quarter,
                      child: Text(
                        quarter,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedQuarter = value ?? '';
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_myAssessments.isEmpty)
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
                  Icon(Icons.assessment_outlined, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No assessments found',
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
            itemCount: _myAssessments.length,
            itemBuilder: (context, index) {
              final assessment = _myAssessments[index];
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
                            '${assessment.quarter} ${assessment.year}',
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
                            color: _getStatusColor(assessment.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            assessment.status,
                            style: TextStyle(
                              color: _getStatusColor(assessment.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submitted: ${assessment.submittedDate?.toString().split(' ')[0] ?? 'Not submitted'}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildAssessmentCriterion('Communication', assessment.kpiRatings['communication']?.toInt()),
                        const SizedBox(width: 16),
                        _buildAssessmentCriterion('Technical Skills', assessment.kpiRatings['technical_skills']?.toInt()),
                        const SizedBox(width: 16),
                        _buildAssessmentCriterion('Initiative', assessment.kpiRatings['initiative']?.toInt()),
                        const SizedBox(width: 16),
                        _buildAssessmentCriterion('Collaboration', assessment.kpiRatings['collaboration']?.toInt()),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTeamReviewsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Team Reviews',
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
                      _loadReporteeAssessments(value.id);
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
                    'Select a reportee to review their assessments',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else if (_reporteeAssessments.isEmpty)
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
                  Icon(Icons.assessment_outlined, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No assessments found for ${_selectedReportee!.firstName}',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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
                    '${_selectedReportee!.firstName}\'s Assessments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      _showReviewDialog(_reporteeAssessments.first);
                    },
                    child: Text('Submit Review'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reporteeAssessments.length,
                itemBuilder: (context, index) {
                  final assessment = _reporteeAssessments[index];
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
                                '${assessment.quarter} ${assessment.year}',
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
                                color: _getStatusColor(assessment.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                assessment.status,
                                style: TextStyle(
                                  color: _getStatusColor(assessment.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Submitted: ${assessment.submittedDate?.toString().split(' ')[0] ?? 'Not submitted'}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildAssessmentCriterion('Communication', assessment.kpiRatings['communication']?.toInt()),
                            const SizedBox(width: 16),
                            _buildAssessmentCriterion('Technical Skills', assessment.kpiRatings['technical_skills']?.toInt()),
                            const SizedBox(width: 16),
                            _buildAssessmentCriterion('Initiative', assessment.kpiRatings['initiative']?.toInt()),
                            const SizedBox(width: 16),
                            _buildAssessmentCriterion('Collaboration', assessment.kpiRatings['collaboration']?.toInt()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Self Comments: ${assessment.feedback}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
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

  Widget _buildAssessmentCriterion(String label, int? rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < (rating ?? 0) ? Icons.star : Icons.star_border,
              color: index < (rating ?? 0) ? Colors.amber : Colors.grey,
              size: 16,
            );
          }),
        ),
      ],
    );
  }

  void _showReviewDialog(SelfAssessmentModel assessment) {
    final TextEditingController managerCommentsController = TextEditingController();
    int managerRating = 3;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Submit Manager Review',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Review for ${assessment.quarter} ${assessment.year}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: managerCommentsController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Manager Comments',
                  labelStyle: TextStyle(color: Color(0xFF888888)),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF333333)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Rating: ',
                    style: const TextStyle(color: Colors.white),
                  ),
                  ...List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          managerRating = index + 1;
                        });
                      },
                      child: Icon(
                        index < managerRating ? Icons.star : Icons.star_border,
                        color: index < managerRating ? Colors.amber : Colors.grey,
                        size: 24,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Submit review to Firestore
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review submitted successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'awaiting manager review':
        return Colors.orange;
      case 'awaiting hr review':
        return Colors.blue;
      case 'review completed':
        return Colors.green;
      case 'awaiting self review':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
} 