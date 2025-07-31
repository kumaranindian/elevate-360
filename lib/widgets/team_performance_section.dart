import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../core/utils/app_theme.dart';

class TeamPerformanceSection extends StatelessWidget {
  final List<EmployeeModel> reportees;
  final Map<String, Map<String, dynamic>> reporteeStats;

  const TeamPerformanceSection({
    super.key,
    required this.reportees,
    required this.reporteeStats,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Team Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${reportees.length} Team Members',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Team Performance Table/List
          if (isDesktop)
            _buildTeamPerformanceTable()
          else
            _buildTeamPerformanceList(),
        ],
      ),
    );
  }

  Widget _buildTeamPerformanceTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF2A2A2A)),
          columns: const [
            DataColumn(label: Text('Team Member', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Role', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Active Goals', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Completed', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Skills', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Rating', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Status', style: TextStyle(color: Colors.white))),
          ],
          rows: reportees.map((reportee) {
            final stats = reporteeStats[reportee.id] ?? {
              'activeGoals': 0,
              'completedGoals': 0,
              'skillsCount': 0,
              'rating': 0.0,
            };
            
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          '${reportee.firstName[0]}${reportee.lastName[0]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reportee.firstName} ${reportee.lastName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(reportee.roleId, style: const TextStyle(color: Colors.white))),
                DataCell(Text('${stats['activeGoals']}', style: const TextStyle(color: Colors.white))),
                DataCell(Text('${stats['completedGoals']}', style: const TextStyle(color: Colors.white))),
                DataCell(Text('${stats['skillsCount']}', style: const TextStyle(color: Colors.white))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: AppTheme.warningColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${(stats['rating'] as double).toStringAsFixed(1)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                DataCell(_buildStatusChip(reportee.employmentStatus)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTeamPerformanceList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reportees.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reportee = reportees[index];
        final stats = reporteeStats[reportee.id] ?? {
          'activeGoals': 0,
          'completedGoals': 0,
          'skillsCount': 0,
          'rating': 0.0,
        };

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      '${reportee.firstName[0]}${reportee.lastName[0]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                          '${reportee.firstName} ${reportee.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reportee.roleId,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(reportee.employmentStatus),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('Active Goals', '${stats['activeGoals']}', Icons.flag),
                  _buildMetricItem('Completed', '${stats['completedGoals']}', Icons.check_circle),
                  _buildMetricItem('Skills', '${stats['skillsCount']}', Icons.psychology),
                  _buildMetricItem(
                    'Rating',
                    '${(stats['rating'] as double).toStringAsFixed(1)}',
                    Icons.star,
                    color: AppTheme.warningColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = AppTheme.successColor;
        break;
      case 'on leave':
        color = AppTheme.warningColor;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}