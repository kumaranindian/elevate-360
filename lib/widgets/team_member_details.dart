import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../core/utils/app_theme.dart';

class TeamMemberDetails extends StatelessWidget {
  final EmployeeModel member;
  final Map<String, dynamic>? stats;

  const TeamMemberDetails({
    super.key,
    required this.member,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Quick Stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  '${member.firstName[0]}${member.lastName[0]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${member.firstName} ${member.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.roleId,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(member.employmentStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(member.employmentStatus).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            member.employmentStatus,
                            style: TextStyle(
                              color: _getStatusColor(member.employmentStatus),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Joined ${member.hireDate.toString().split(' ')[0]}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (stats != null) ...[
                const SizedBox(width: 40),
                _buildQuickStats(),
              ],
            ],
          ),
          const SizedBox(height: 24),
          
          // Information Sections in Grid
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              // Personal & Contact Info
              _buildInfoSection(
                'Personal & Contact',
                [
                  _buildInfoRow('Email', member.email),
                  _buildInfoRow('Phone', member.phone ?? 'Not provided'),
                  _buildInfoRow('Department', member.departmentId),
                  _buildInfoRow('Employee ID', member.employeeId),
                  if (member.address?['full_address'] != null)
                    _buildInfoRow('Address', member.address!['full_address']),
                ],
                width: isWide ? null : double.infinity,
              ),
              
              // Work Info
              _buildInfoSection(
                'Work Information',
                [
                  _buildInfoRow('Employment Type', member.employeeType),
                  _buildInfoRow('Work Location', member.workLocation),
                  _buildInfoRow('Current Salary', '\$${member.currentSalary?.toStringAsFixed(2) ?? 'Not provided'}'),
                  if (member.probationEndDate != null)
                    _buildInfoRow('Probation End', member.probationEndDate!.toString().split(' ')[0]),
                ],
                width: isWide ? null : double.infinity,
              ),
              
              // Emergency Contact
              if (member.emergencyContact != null)
                _buildInfoSection(
                  'Emergency Contact',
                  [
                    _buildInfoRow('Name', member.emergencyContact!['name'] ?? 'Not provided'),
                    _buildInfoRow('Phone', member.emergencyContact!['phone'] ?? 'Not provided'),
                    _buildInfoRow('Relationship', member.emergencyContact!['relationship'] ?? 'Not provided'),
                  ],
                  width: isWide ? null : double.infinity,
                ),
              
              // Professional Links
              _buildInfoSection(
                'Professional Links',
                [
                  _buildInfoRow('GitHub', member.githubUsername ?? 'Not provided'),
                  _buildInfoRow('LinkedIn', member.linkedinProfile ?? 'Not provided'),
                ],
                width: isWide ? null : double.infinity,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildQuickStat(
          'Goals',
          '${stats?['goalsCompleted'] ?? 0}/${stats?['totalGoals'] ?? 0}',
          Icons.flag,
        ),
        const SizedBox(width: 24),
        _buildQuickStat(
          'Skills',
          '${stats?['skillsCount'] ?? 0}',
          Icons.psychology,
        ),
        const SizedBox(width: 24),
        _buildQuickStat(
          'Rating',
          '${(stats?['performance'] ?? 0.0).toStringAsFixed(1)}/5.0',
          Icons.star,
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildInfoSection(String title, List<Widget> children, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successColor;
      case 'on leave':
        return AppTheme.warningColor;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}