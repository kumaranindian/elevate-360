import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';
import 'team_member_details.dart';

class ManagerProfileContent extends StatelessWidget {
  final EmployeeModel manager;
  final Map<String, dynamic>? departmentDetails;
  final Map<String, dynamic>? roleDetails;
  final Map<String, dynamic>? teamSummary;
  final List<EmployeeModel> reportees;
  final EmployeeModel? selectedReportee;
  final Map<String, Map<String, dynamic>> reporteeStats;
  final bool isEditing;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController githubController;
  final TextEditingController linkedinController;
  final TextEditingController addressController;
  final TextEditingController emergencyContactController;
  final TextEditingController emergencyPhoneController;
  final Function(EmployeeModel) onReporteeSelected;

  const ManagerProfileContent({
    super.key,
    required this.manager,
    this.departmentDetails,
    this.roleDetails,
    this.teamSummary,
    required this.reportees,
    this.selectedReportee,
    required this.reporteeStats,
    required this.isEditing,
    required this.formKey,
    required this.phoneController,
    required this.githubController,
    required this.linkedinController,
    required this.addressController,
    required this.emergencyContactController,
    required this.emergencyPhoneController,
    required this.onReporteeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Manager's Information
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _buildInfoSection(
                      'Basic Details',
                      [
                        _buildInfoRow('Full Name', '${manager.firstName} ${manager.lastName}', false),
                        _buildInfoRow('Email', manager.email, false),
                        _buildInfoRow('Employee ID', manager.employeeId, false),
                        _buildInfoRow('Department', departmentDetails?['name'] ?? manager.departmentId, false),
                        _buildInfoRow('Position', roleDetails?['title'] ?? manager.roleId, false),
                        _buildInfoRow('Join Date', manager.hireDate.toString().split(' ')[0], false),
                      ],
                      width: isDesktop ? null : double.infinity,
                    ),
                    _buildInfoSection(
                      'Contact Information',
                      [
                        _buildEditableRow('Phone', phoneController, Icons.phone),
                        _buildEditableRow('GitHub', githubController, Icons.code),
                        _buildEditableRow('LinkedIn', linkedinController, Icons.link),
                        _buildEditableRow('Address', addressController, Icons.location_on),
                      ],
                      width: isDesktop ? null : double.infinity,
                    ),
                    _buildInfoSection(
                      'Emergency Contact',
                      [
                        _buildEditableRow('Contact Name', emergencyContactController, Icons.person),
                        _buildEditableRow('Contact Phone', emergencyPhoneController, Icons.phone),
                      ],
                      width: isDesktop ? null : double.infinity,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Team Members Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Team Members',
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
                      '${reportees.length} Members',
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
              // Team Members Grid/List
              if (isDesktop)
                _buildTeamMembersGrid()
              else
                _buildTeamMembersList(),
              if (selectedReportee != null) ...[
                const SizedBox(height: 24),
                TeamMemberDetails(
                  member: selectedReportee!,
                  stats: reporteeStats[selectedReportee!.id],
                ),
              ],
            ],
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

  Widget _buildInfoRow(String label, String value, bool isEditable) {
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

  Widget _buildEditableRow(String label, TextEditingController controller, IconData icon) {
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
            child: TextFormField(
              controller: controller,
              enabled: isEditing,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppTheme.textSecondary),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMembersGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2,
      ),
      itemCount: reportees.length,
      itemBuilder: (context, index) {
        final reportee = reportees[index];
        final stats = reporteeStats[reportee.id];
        
        return InkWell(
          onTap: () => onReporteeSelected(reportee),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedReportee?.id == reportee.id
                    ? AppTheme.primaryColor
                    : Colors.transparent,
              ),
            ),
            child: Row(
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${reportee.firstName} ${reportee.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reportee.roleId,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.warningColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${(stats?['rating'] ?? 0.0).toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamMembersList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reportees.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reportee = reportees[index];
        final stats = reporteeStats[reportee.id];
        
        return InkWell(
          onTap: () => onReporteeSelected(reportee),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedReportee?.id == reportee.id
                    ? AppTheme.primaryColor
                    : Colors.transparent,
              ),
            ),
            child: Row(
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
                const SizedBox(width: 16),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.warningColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${(stats?['rating'] ?? 0.0).toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reportee.employmentStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reportee.employmentStatus,
                        style: TextStyle(
                          color: _getStatusColor(reportee.employmentStatus),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successColor;
      case 'on leave':
        return AppTheme.warningColor;
      default:
        return Colors.grey;
    }
  }
}