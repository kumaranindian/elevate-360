import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/app_theme.dart';
import '../models/goal_model.dart';
import '../models/self_assessment_model.dart';
import '../models/review_model.dart';
import '../models/skill_model.dart';
import '../services/goal_service.dart';
import '../services/self_assessment_service.dart';
import '../services/review_service.dart';
import '../services/skill_service.dart';

class ReporteeSummary extends ConsumerStatefulWidget {
  final String reporteeId;

  const ReporteeSummary({super.key, required this.reporteeId});

  @override
  ConsumerState<ReporteeSummary> createState() => _ReporteeSummaryState();
}

class _ReporteeSummaryState extends ConsumerState<ReporteeSummary> {
  bool _isLoading = true;
  String? _error;
  List<GoalModel> _reporteeGoals = [];
  List<SelfAssessmentModel> _reporteeAssessments = [];
  List<ReviewModel> _reporteeFeedback = [];
  List<SkillModel> _reporteeSkills = [];

  @override
  void initState() {
    super.initState();
    _fetchReporteeData();
  }

  @override
  void didUpdateWidget(covariant ReporteeSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reporteeId != widget.reporteeId) {
      _fetchReporteeData();
    }
  }

  Future<void> _fetchReporteeData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // Fetch data from collections for the specific reportee
      final futures = await Future.wait([
        GoalService.getGoalsByEmployeeId(widget.reporteeId),
        SelfAssessmentService.getSelfAssessmentsByEmployeeId(widget.reporteeId),
        ReviewService.getReviewsByEmployeeId(widget.reporteeId),
        SkillService.getSkillsByEmployeeId(widget.reporteeId),
      ]);

      if (mounted) {
        setState(() {
          _reporteeGoals = futures[0] as List<GoalModel>;
          _reporteeAssessments = futures[1] as List<SelfAssessmentModel>;
          _reporteeFeedback = futures[2] as List<ReviewModel>;
          _reporteeSkills = futures[3] as List<SkillModel>;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildAnimatedStatCard(
          'Active Goals',
          '${_reporteeGoals.where((g) => g.status != 'Completed').length}',
          Icons.flag,
          AppTheme.primaryColor,
          _reporteeGoals.where((g) => g.status != 'Completed').length / (_reporteeGoals.isEmpty ? 1 : _reporteeGoals.length),
        ),
        _buildAnimatedStatCard(
          'Completed Goals',
          '${_reporteeGoals.where((g) => g.status == 'Completed').length}',
          Icons.check_circle,
          AppTheme.successColor,
          _reporteeGoals.where((g) => g.status == 'Completed').length / (_reporteeGoals.isEmpty ? 1 : _reporteeGoals.length),
        ),
        _buildAnimatedStatCard(
          'Skills',
          '${_reporteeSkills.length}',
          Icons.psychology,
          AppTheme.infoColor,
          _reporteeSkills.length / 10, // Assuming 10 is a good target for skills
        ),
        _buildAnimatedStatCard(
          'Assessments',
          '${_reporteeAssessments.length}',
          Icons.assessment,
          Colors.teal,
          _reporteeAssessments.length / 4, // Assuming 4 is a good target for assessments (quarterly)
        ),
      ],
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
}
