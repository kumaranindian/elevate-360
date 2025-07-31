import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  ConsumerState<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();

  DateTime? _dateOfBirth;
  DateTime? _hireDate;
  DateTime? _probationEndDate;
  String? _selectedDepartmentId;
  String? _selectedRoleId;
  String? _selectedTeamId;
  String? _selectedManagerId;
  String _employmentStatus = 'Active';
  String _employeeType = 'Full-time';
  String _workLocation = 'Office';
  bool _isLoading = false;

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _teams = [];
  List<EmployeeModel> _managers = [];

  // Responsive breakpoints
  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  // Get responsive spacing
  double _getPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    return 24.0; // Desktop
  }

  double _getSpacing(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 16.0;
    return 16.0; // Desktop
  }

  double _getSectionSpacing(BuildContext context) {
    if (_isMobile(context)) return 20.0;
    if (_isTablet(context)) return 24.0;
    return 20.0; // Desktop - reduced section spacing
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final futures = await Future.wait([
        EmployeeService.getDepartments(),
        EmployeeService.getRoles(),
        EmployeeService.getTeams(),
        EmployeeService.getAllEmployees(),
      ]);

      setState(() {
        _departments = futures[0] as List<Map<String, dynamic>>;
        _roles = futures[1] as List<Map<String, dynamic>>;
        _teams = futures[2] as List<Map<String, dynamic>>;
        _managers = futures[3] as List<EmployeeModel>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2A2A2A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _dateOfBirth = picked;
        } else {
          _hireDate = picked;
        }
      });
    }
  }

  Future<void> _selectProbationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2A2A2A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _probationEndDate = picked;
      });
    }
  }

  String _generateDefaultPassword() {
    if (_dateOfBirth != null && _phoneController.text.isNotEmpty) {
      final birthYear = _dateOfBirth!.year.toString();
      final last4Digits = _phoneController.text.substring(_phoneController.text.length - 4);
      return last4Digits + birthYear;
    }
    return 'password123';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartmentId == null || _selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select department and role'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate employee ID
      final employeeId = await EmployeeService.generateEmployeeId();

      // Create employee model
      final employee = EmployeeModel(
        id: '', // Will be set by Firestore
        employeeId: employeeId,
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth,
        hireDate: _hireDate ?? DateTime.now(),
        departmentId: _selectedDepartmentId!,
        roleId: _selectedRoleId!,
        teamId: _selectedTeamId,
        managerId: _selectedManagerId,
        employmentStatus: _employmentStatus,
        employeeType: _employeeType,
        workLocation: _workLocation,
        currentSalary: double.tryParse(_salaryController.text) ?? 0.0,
        githubUsername: _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
        linkedinProfile: _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
        probationEndDate: _probationEndDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create employee
      await EmployeeService.createEmployee(employee);

      if (mounted) {
        final defaultPassword = _generateDefaultPassword();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Employee created successfully!'),
                const SizedBox(height: 4),
                Text('Default password: $defaultPassword'),
                const SizedBox(height: 4),
                const Text('Please share this password with the employee.', style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 8),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating employee: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);
    final isDesktop = _isDesktop(context);
    final padding = _getPadding(context);
    final spacing = _getSpacing(context);
    final sectionSpacing = _getSectionSpacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Add New Employee',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 600 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information Section
                        _buildSectionTitle('Personal Information', context),
                        SizedBox(height: spacing),
                        
                        _buildResponsiveRow(context, [
                          Expanded(
                            child: _buildTextFormField(
                              controller: _firstNameController,
                              label: 'First Name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'First name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildTextFormField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Last name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ]),
                        SizedBox(height: spacing),
                        
                        _buildTextFormField(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: spacing),
                        
                        _buildTextFormField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: spacing),
                        
                        _buildResponsiveRow(context, [
                          Expanded(
                            child: _buildDateField(
                              label: 'Date of Birth',
                              value: _dateOfBirth,
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildDateField(
                              label: 'Hire Date',
                              value: _hireDate,
                              onTap: () => _selectDate(context, false),
                            ),
                          ),
                        ]),
                        SizedBox(height: sectionSpacing),

                        // Employment Information Section
                        _buildSectionTitle('Employment Information', context),
                        SizedBox(height: spacing),
                        
                        _buildResponsiveRow(context, [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Department',
                              value: _selectedDepartmentId,
                              items: _departments.map((dept) {
                                return DropdownMenuItem(
                                  value: dept['id'],
                                  child: Text(dept['name'] ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartmentId = value;
                                  _selectedRoleId = null; // Reset role when department changes
                                });
                              },
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Role',
                              value: _selectedRoleId,
                              items: _roles
                                  .where((role) => role['department_id'] == _selectedDepartmentId)
                                  .map((role) {
                                return DropdownMenuItem(
                                  value: role['id'],
                                  child: Text(role['title'] ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoleId = value;
                                });
                              },
                            ),
                          ),
                        ]),
                        SizedBox(height: spacing),
                        
                        _buildResponsiveRow(context, [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Team',
                              value: _selectedTeamId,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('No Team'),
                                ),
                                ..._teams
                                    .where((team) => team['department_id'] == _selectedDepartmentId)
                                    .map((team) {
                                  return DropdownMenuItem(
                                    value: team['id'],
                                    child: Text(team['name'] ?? 'Unknown'),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedTeamId = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Manager',
                              value: _selectedManagerId,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('No Manager'),
                                ),
                                ..._managers.map((manager) {
                                  return DropdownMenuItem(
                                    value: manager.id,
                                    child: Text(manager.fullName),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedManagerId = value;
                                });
                              },
                            ),
                          ),
                        ]),
                        SizedBox(height: spacing),
                        
                        _buildResponsiveRow(context, [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Employment Status',
                              value: _employmentStatus,
                              items: const [
                                DropdownMenuItem(value: 'Active', child: Text('Active')),
                                DropdownMenuItem(value: 'On Leave', child: Text('On Leave')),
                                DropdownMenuItem(value: 'Probation', child: Text('Probation')),
                                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _employmentStatus = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Employee Type',
                              value: _employeeType,
                              items: const [
                                DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                                DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                                DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                                DropdownMenuItem(value: 'Intern', child: Text('Intern')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _employeeType = value!;
                                });
                              },
                            ),
                          ),
                        ]),
                        SizedBox(height: spacing),
                        
                        _buildResponsiveRow(context, [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Work Location',
                              value: _workLocation,
                              items: const [
                                DropdownMenuItem(value: 'Office', child: Text('Office')),
                                DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                                DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _workLocation = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildTextFormField(
                              controller: _salaryController,
                              label: 'Salary',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ]),
                        SizedBox(height: spacing),
                        
                        if (_employmentStatus == 'Probation')
                          _buildDateField(
                            label: 'Probation End Date',
                            value: _probationEndDate,
                            onTap: () => _selectProbationDate(context),
                          ),
                        SizedBox(height: sectionSpacing),

                        // Additional Information Section
                        _buildSectionTitle('Additional Information', context),
                        SizedBox(height: spacing),
                        
                        _buildResponsiveRow(context, [
                          Expanded(
                            child: _buildTextFormField(
                              controller: _githubController,
                              label: 'GitHub Username',
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildTextFormField(
                              controller: _linkedinController,
                              label: 'LinkedIn Profile',
                            ),
                          ),
                        ]),
                        SizedBox(height: sectionSpacing),

                        // Password Information
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Default Password Information',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: isMobile ? 6 : 8),
                              Text(
                                'Default password will be: ${_generateDefaultPassword()}',
                                style: TextStyle(
                                  color: const Color(0xFF888888),
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                              SizedBox(height: isMobile ? 2 : 4),
                              Text(
                                'Format: Last 4 digits of phone + Birth year',
                                style: TextStyle(
                                  color: const Color(0xFF666666),
                                  fontSize: isMobile ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),

                        // Submit Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Create Employee',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    final isMobile = _isMobile(context);
    
    if (isMobile) {
      return Column(
        children: children.where((child) => child is! SizedBox).toList(),
      );
    } else {
      return Row(
        children: children,
      );
    }
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final isMobile = _isMobile(context);
    
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: isMobile ? 16 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF888888)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem> items,
    required void Function(dynamic)? onChanged,
  }) {
    return DropdownButtonFormField(
      value: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF888888)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
      dropdownColor: const Color(0xFF2A2A2A),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null
                        ? '${value.day}/${value.month}/${value.year}'
                        : 'Select date',
                    style: TextStyle(
                      color: value != null ? Colors.white : const Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF888888),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }
} 