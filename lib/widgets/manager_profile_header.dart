import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../core/utils/app_theme.dart';

class ManagerProfileHeader extends StatelessWidget {
  final EmployeeModel manager;
  final Map<String, dynamic>? departmentDetails;
  final Map<String, dynamic>? roleDetails;
  final Map<String, dynamic>? teamSummary;
  final List<EmployeeModel> reportees;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ManagerProfileHeader({
    super.key,
    required this.manager,
    this.departmentDetails,
    this.roleDetails,
    this.teamSummary,
    required this.reportees,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture and Basic Info
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    '${manager.firstName[0]}${manager.lastName[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
                        '${manager.firstName} ${manager.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleDetails?['title'] ?? manager.roleId,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        departmentDetails?['name'] ?? manager.departmentId,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quick Stats
          if (isDesktop) ...[
            const SizedBox(width: 40),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat('Team Size', '${reportees.length}', Icons.group),
                  _buildQuickStat(
                    'Active Members',
                    '${reportees.where((r) => r.employmentStatus == 'Active').length}',
                    Icons.check_circle,
                  ),
                  _buildQuickStat(
                    'Avg Performance',
                    '${(teamSummary?['averageRating'] ?? 0.0).toStringAsFixed(1)}/5.0',
                    Icons.star,
                  ),
                ],
              ),
            ),
          ],
          // Edit Button
          if (!isEditing)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Profile',
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
        ],
      ),
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
}