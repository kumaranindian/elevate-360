import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final UserModel userModel;

  const EmployeeProfileScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  late EmployeeModel _employee;
  
  // Controllers for editable fields
  final _phoneController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      // Get employee data using user account ID
      final employeeSnapshot = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      
      setState(() {
        _employee = employeeSnapshot;
        _isLoading = false;
        
        // Initialize controllers with employee data
        _phoneController.text = _employee.phone ?? '';
        _githubController.text = _employee.githubUsername ?? '';
        _linkedinController.text = _employee.linkedinProfile ?? '';
        _addressController.text = _employee.address?['full_address'] ?? '';
        _emergencyContactController.text = _employee.emergencyContact?['name'] ?? '';
        _emergencyPhoneController.text = _employee.emergencyContact?['phone'] ?? '';
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.buildResponsiveLayout(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
          
          // Profile Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Personal Information Section
                ResponsiveUtils.buildResponsiveSection(
                  context: context,
                  title: 'Personal Information',
                  icon: Icons.person,
                  children: [
                    _buildInfoRow('Full Name', widget.userModel.username, false),
                    _buildInfoRow('Email', widget.userModel.email, false),
                    _buildInfoRow('Employee ID', 'EMP-${widget.userModel.uid.substring(0, 8)}', false),
                    _buildInfoRow('Department', 'Engineering', false),
                    _buildInfoRow('Position', 'Software Engineer', false),
                    _buildInfoRow('Join Date', 'January 15, 2023', false),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                
                // Contact Information Section
                ResponsiveUtils.buildResponsiveSection(
                  context: context,
                  title: 'Contact Information',
                  icon: Icons.contact_phone,
                  children: [
                    _buildEditableRow('Phone', _phoneController, Icons.phone),
                    _buildEditableRow('Address', _addressController, Icons.location_on),
                    _buildInfoRow('Work Email', widget.userModel.email, false),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                
                // Emergency Contact Section
                ResponsiveUtils.buildResponsiveSection(
                  context: context,
                  title: 'Emergency Contact',
                  icon: Icons.emergency,
                  children: [
                    _buildEditableRow('Contact Name', _emergencyContactController, Icons.person),
                    _buildEditableRow('Contact Phone', _emergencyPhoneController, Icons.phone),
                    _buildInfoRow('Relationship', 'Spouse', false),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                
                // Work Information Section
                ResponsiveUtils.buildResponsiveSection(
                  context: context,
                  title: 'Work Information',
                  icon: Icons.work,
                  children: [
                    _buildInfoRow('Manager', 'Sarah Wilson', false),
                    _buildInfoRow('Team', 'Development Team A', false),
                    _buildInfoRow('Location', 'Office - Floor 3', false),
                    _buildInfoRow('Work Schedule', 'Monday - Friday, 9:00 AM - 6:00 PM', false),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
                
                // Performance Summary Section
                ResponsiveUtils.buildResponsiveSection(
                  context: context,
                  title: 'Performance Summary',
                  icon: Icons.assessment,
                  children: [
                    _buildInfoRow('Current Rating', '4.2/5.0', false),
                    _buildInfoRow('Last Review', 'December 15, 2023', false),
                    _buildInfoRow('Goals Completed', '8/10', false),
                    _buildInfoRow('Skills Level', 'Intermediate', false),
                  ],
                ),
              ],
            ),
          ),
          
          if (_isEditing) ...[
            SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: ResponsiveUtils.isMobile(context) ? 30 : 40,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            widget.userModel.username[0].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.isMobile(context) ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userModel.username,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
              Text(
                'Employee',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
              Wrap(
                spacing: 8,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getSpacing(context) / 2,
                      vertical: ResponsiveUtils.getSpacing(context) / 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: ResponsiveUtils.getSmallFontSize(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getSpacing(context) / 2,
                      vertical: ResponsiveUtils.getSpacing(context) / 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Full Time',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: ResponsiveUtils.getSmallFontSize(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          icon: Icon(
            _isEditing ? Icons.save : Icons.edit,
            color: AppTheme.primaryColor,
            size: ResponsiveUtils.getSmallIconSize(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isEditable) {
    return ResponsiveUtils.buildResponsiveInfoRow(
      context: context,
      label: label,
      value: value,
      isEditable: isEditable,
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context) / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtils.isMobile(context) ? 80 : 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: ResponsiveUtils.getSmallFontSize(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context)),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: ResponsiveUtils.getSmallIconSize(context)),
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
                      fillColor: const Color(0xFF1A1A1A),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getSpacing(context) / 2,
                        vertical: ResponsiveUtils.getSpacing(context) / 2,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Icon(icon, color: AppTheme.textSecondary, size: ResponsiveUtils.getSmallIconSize(context)),
                      SizedBox(width: ResponsiveUtils.getSpacing(context) / 2),
                      Expanded(
                        child: Text(
                          controller.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: ResponsiveUtils.getButtonPadding(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context)),
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelChanges,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.textSecondary),
              padding: ResponsiveUtils.getButtonPadding(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodyFontSize(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        // Create updated employee model
        final updatedEmployee = EmployeeModel(
          id: _employee.id,
          employeeId: _employee.employeeId,
          userAccountId: _employee.userAccountId,
          email: _employee.email,
          firstName: _employee.firstName,
          lastName: _employee.lastName,
          phone: _phoneController.text,
          dateOfBirth: _employee.dateOfBirth,
          hireDate: _employee.hireDate,
          departmentId: _employee.departmentId,
          roleId: _employee.roleId,
          teamId: _employee.teamId,
          managerId: _employee.managerId,
          employmentStatus: _employee.employmentStatus,
          employeeType: _employee.employeeType,
          workLocation: _employee.workLocation,
          currentSalary: _employee.currentSalary,
          githubUsername: _githubController.text,
          linkedinProfile: _linkedinController.text,
          profilePictureUrl: _employee.profilePictureUrl,
          address: {
            ..._employee.address ?? {},
            'full_address': _addressController.text,
          },
          emergencyContact: {
            'name': _emergencyContactController.text,
            'phone': _emergencyPhoneController.text,
          },
          joiningBonus: _employee.joiningBonus,
          probationEndDate: _employee.probationEndDate,
          createdAt: _employee.createdAt,
          updatedAt: DateTime.now(),
        );

        // Update employee in Firebase
        await EmployeeService.updateEmployee(updatedEmployee);

        setState(() {
          _employee = updatedEmployee;
          _isEditing = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _cancelChanges() {
    setState(() {
      _isEditing = false;
    });
    
    // Reset controllers to original values
    _phoneController.text = _employee.phone ?? '';
    _githubController.text = _employee.githubUsername ?? '';
    _linkedinController.text = _employee.linkedinProfile ?? '';
    _addressController.text = _employee.address?['full_address'] ?? '';
    _emergencyContactController.text = _employee.emergencyContact?['name'] ?? '';
    _emergencyPhoneController.text = _employee.emergencyContact?['phone'] ?? '';
  }
} 