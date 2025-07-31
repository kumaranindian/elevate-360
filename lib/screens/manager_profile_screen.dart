import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';
import '../widgets/team_member_details.dart';
import '../widgets/manager_profile_header.dart';
import '../widgets/manager_profile_content.dart';

class ManagerProfileScreen extends StatefulWidget {
  final UserModel userModel;

  const ManagerProfileScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  String? _error;
  EmployeeModel? _managerProfile;
  List<EmployeeModel> _reportees = [];
  EmployeeModel? _selectedReportee;
  Map<String, dynamic>? _teamSummary;
  Map<String, dynamic>? _departmentDetails;
  Map<String, dynamic>? _roleDetails;
  Map<String, Map<String, dynamic>> _reporteeStats = {};
  final _formKey = GlobalKey<FormState>();
  
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
    _loadManagerData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadManagerData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load manager profile
      final manager = await EmployeeService.getEmployeeByUserAccountId(widget.userModel.uid);
      
      // Load reportees from Firebase
      final reportees = await EmployeeService.getReporteesByManagerId(widget.userModel.uid);
      
      // Load team summary
      final teamSummary = await EmployeeService.getManagerTeamSummary(widget.userModel.uid);
      
      // Load department and role details
      final departmentDetails = await EmployeeService.getDepartmentById(manager.departmentId);
      final roleDetails = await EmployeeService.getJobRoleById(manager.roleId);

      setState(() {
        _managerProfile = manager;
        _reportees = reportees;
        _teamSummary = teamSummary;
        _departmentDetails = departmentDetails;
        _roleDetails = roleDetails;
        _isLoading = false;
      });

      // Initialize controllers with manager data
      if (_managerProfile != null) {
        _phoneController.text = _managerProfile!.phone ?? '';
        _githubController.text = _managerProfile!.githubUsername ?? '';
        _linkedinController.text = _managerProfile!.linkedinProfile ?? '';
        _addressController.text = _managerProfile!.address?['full_address'] ?? '';
        _emergencyContactController.text = _managerProfile!.emergencyContact?['name'] ?? '';
        _emergencyPhoneController.text = _managerProfile!.emergencyContact?['phone'] ?? '';
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showReporteeDetails(EmployeeModel reportee) {
    setState(() {
      _selectedReportee = reportee;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        final updatedManager = EmployeeModel(
          id: _managerProfile!.id,
          employeeId: _managerProfile!.employeeId,
          userAccountId: _managerProfile!.userAccountId,
          email: _managerProfile!.email,
          firstName: _managerProfile!.firstName,
          lastName: _managerProfile!.lastName,
          phone: _phoneController.text,
          dateOfBirth: _managerProfile!.dateOfBirth,
          hireDate: _managerProfile!.hireDate,
          departmentId: _managerProfile!.departmentId,
          roleId: _managerProfile!.roleId,
          teamId: _managerProfile!.teamId,
          managerId: _managerProfile!.managerId,
          employmentStatus: _managerProfile!.employmentStatus,
          employeeType: _managerProfile!.employeeType,
          workLocation: _managerProfile!.workLocation,
          currentSalary: _managerProfile!.currentSalary,
          githubUsername: _githubController.text,
          linkedinProfile: _linkedinController.text,
          profilePictureUrl: _managerProfile!.profilePictureUrl,
          address: {
            'full_address': _addressController.text,
            ..._managerProfile!.address ?? {},
          },
          emergencyContact: {
            'name': _emergencyContactController.text,
            'phone': _emergencyPhoneController.text,
            'relationship': _managerProfile!.emergencyContact?['relationship'] ?? 'Not specified',
          },
          joiningBonus: _managerProfile!.joiningBonus,
          probationEndDate: _managerProfile!.probationEndDate,
          createdAt: _managerProfile!.createdAt,
          updatedAt: DateTime.now(),
        );

        await EmployeeService.updateEmployee(updatedManager);

        setState(() {
          _managerProfile = updatedManager;
          _isEditing = false;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  void _cancelChanges() {
    setState(() {
      _isEditing = false;
    });
    _resetControllers();
  }

  void _resetControllers() {
    if (_managerProfile != null) {
      _phoneController.text = _managerProfile!.phone ?? '';
      _githubController.text = _managerProfile!.githubUsername ?? '';
      _linkedinController.text = _managerProfile!.linkedinProfile ?? '';
      _addressController.text = _managerProfile!.address?['full_address'] ?? '';
      _emergencyContactController.text = _managerProfile!.emergencyContact?['name'] ?? '';
      _emergencyPhoneController.text = _managerProfile!.emergencyContact?['phone'] ?? '';
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
              onPressed: _loadManagerData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_managerProfile == null) {
      return const Center(
        child: Text('Manager profile not found', style: TextStyle(color: Colors.white)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manager Profile Header
          ManagerProfileHeader(
            manager: _managerProfile!,
            departmentDetails: _departmentDetails,
            roleDetails: _roleDetails,
            teamSummary: _teamSummary,
            reportees: _reportees,
            isEditing: _isEditing,
            onEdit: () => setState(() => _isEditing = true),
            onSave: _saveChanges,
            onCancel: _cancelChanges,
          ),
          const SizedBox(height: 24),
          
          // Manager Profile Content
          ManagerProfileContent(
            manager: _managerProfile!,
            departmentDetails: _departmentDetails,
            roleDetails: _roleDetails,
            teamSummary: _teamSummary,
            reportees: _reportees,
            selectedReportee: _selectedReportee,
            reporteeStats: _reporteeStats,
            isEditing: _isEditing,
            formKey: _formKey,
            phoneController: _phoneController,
            githubController: _githubController,
            linkedinController: _linkedinController,
            addressController: _addressController,
            emergencyContactController: _emergencyContactController,
            emergencyPhoneController: _emergencyPhoneController,
            onReporteeSelected: _showReporteeDetails,
          ),
        ],
      ),
    );
  }
}