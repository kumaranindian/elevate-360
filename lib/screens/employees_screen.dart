import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../core/utils/app_theme.dart';
import 'add_employee_screen.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  final List<String> _filterOptions = [
    'All',
    'Active',
    'On Leave',
    'Probation',
    'Inactive',
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final employees = await EmployeeService.getAllEmployees();
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading employees: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _filterEmployees() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        final matchesSearch = employee.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesFilter = _selectedFilter == 'All' || 
            employee.employmentStatus == _selectedFilter;
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterEmployees();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterEmployees();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppTheme.successColor;
      case 'On Leave':
        return AppTheme.warningColor;
      case 'Probation':
        return AppTheme.infoColor;
      case 'Inactive':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getDepartmentName(String departmentId) {
    switch (departmentId) {
      case 'ENG':
        return 'Engineering';
      case 'MKT':
        return 'Marketing';
      case 'HR':
        return 'Human Resources';
      case 'DES':
        return 'Design';
      case 'DATA':
        return 'Data & Analytics';
      case 'SALES':
        return 'Sales';
      case 'FIN':
        return 'Finance';
      case 'DEVOPS':
        return 'DevOps';
      case 'QA':
        return 'Quality Assurance';
      default:
        return 'Unknown';
    }
  }

  String _getRoleName(String roleId) {
    switch (roleId) {
      case 'SE':
        return 'Software Engineer';
      case 'MM':
        return 'Marketing Manager';
      case 'HR':
        return 'HR Specialist';
      case 'PD':
        return 'Product Designer';
      case 'DA':
        return 'Data Analyst';
      case 'SE':
        return 'Sales Executive';
      case 'UXR':
        return 'UX Researcher';
      case 'DE':
        return 'DevOps Engineer';
      case 'CW':
        return 'Content Writer';
      case 'FA':
        return 'Financial Analyst';
      default:
        return 'Unknown Role';
    }
  }

  // Responsive breakpoints
  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  // Get responsive grid configuration
  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (_isMobile(context)) return 2;
    if (_isTablet(context)) {
      // More responsive tablet configuration
      if (width < 900) return 3;
      if (width < 1100) return 4;
      return 5;
    }
    if (_isDesktop(context)) return 6;
    return 8; // Large desktop
  }

  double _getGridChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (_isMobile(context)) return 0.8;
    if (_isTablet(context)) {
      // Adjust aspect ratio based on tablet width
      if (width < 900) return 0.9;
      if (width < 1100) return 1.0;
      return 0.95;
    }
    return 0.9; // Desktop
  }

  double _getPadding(BuildContext context) {
    if (_isMobile(context)) return 8.0;
    if (_isTablet(context)) return 12.0;
    return 16.0; // Desktop - much reduced padding
  }

  double _getSpacing(BuildContext context) {
    if (_isMobile(context)) return 6.0;
    if (_isTablet(context)) return 8.0;
    return 10.0; // Desktop - much reduced spacing
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);
    final isDesktop = _isDesktop(context);
    final padding = _getPadding(context);
    final spacing = _getSpacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Responsive Header
          Container(
            padding: EdgeInsets.all(padding),
            child: isMobile 
                ? _buildMobileHeader(padding)
                : _buildDesktopHeader(padding),
          ),

          // Responsive Search and Filter Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
            child: isMobile 
                ? _buildMobileSearchFilter(padding, spacing)
                : _buildDesktopSearchFilter(padding, spacing),
          ),

          // Employee Cards Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : _filteredEmployees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: isMobile ? 48 : 64,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            Text(
                              'No employees found',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(padding),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getGridCrossAxisCount(context),
                          childAspectRatio: _getGridChildAspectRatio(context),
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                        ),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return _buildEmployeeCard(employee, context);
                        },
                      ),
          ),

          // Responsive Pagination
          if (_filteredEmployees.isNotEmpty)
            Container(
              padding: EdgeInsets.all(padding),
              child: _buildResponsivePagination(context),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Employees',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Container(
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
            child: ElevatedButton.icon(
              onPressed: () => _navigateToAddEmployee(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(double padding) {
    return Row(
      children: [
        Icon(
          Icons.people,
          color: AppTheme.primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          'Employees',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
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
          child: ElevatedButton.icon(
            onPressed: () => _navigateToAddEmployee(),
            icon: const Icon(Icons.add),
            label: const Text('Add Employee'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSearchFilter(double padding, double spacing) {
    return Column(
      children: [
        // Filter and View Options Row
        Row(
          children: [
            // Filter Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: PopupMenuButton<String>(
                  onSelected: _onFilterChanged,
                  color: const Color(0xFF2A2A2A),
                  itemBuilder: (context) => _filterOptions.map((option) {
                    return PopupMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(
                          color: _selectedFilter == option 
                              ? AppTheme.primaryColor 
                              : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list, color: Color(0xFF888888), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Filter by',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // View Options
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.grid_view, color: Color(0xFF888888), size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopSearchFilter(double padding, double spacing) {
    return Row(
      children: [
        // Search Field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: TextField(
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search employees...',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF888888)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Filter Button
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: PopupMenuButton<String>(
            onSelected: _onFilterChanged,
            color: const Color(0xFF2A2A2A),
            itemBuilder: (context) => _filterOptions.map((option) {
              return PopupMenuItem(
                value: option,
                child: Text(
                  option,
                  style: TextStyle(
                    color: _selectedFilter == option 
                        ? AppTheme.primaryColor 
                        : Colors.white,
                  ),
                ),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list, color: Color(0xFF888888)),
                  const SizedBox(width: 8),
                  Text(
                    'Filter by',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // View Options
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.grid_view, color: Color(0xFF888888)),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsivePagination(BuildContext context) {
    final isMobile = _isMobile(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _currentPage > 1 ? () {
            setState(() {
              _currentPage--;
            });
          } : null,
          child: Text(
            '< Previous',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ),
        const SizedBox(width: 16),
        ...List.generate(
          (_filteredEmployees.length / _itemsPerPage).ceil(),
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _currentPage = index + 1;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: _currentPage == index + 1 
                    ? AppTheme.primaryColor 
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(isMobile ? 32 : 40, isMobile ? 32 : 40),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: _currentPage == index + 1 
                      ? Colors.white 
                      : Colors.white,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: _currentPage < (_filteredEmployees.length / _itemsPerPage).ceil() 
              ? () {
                setState(() {
                  _currentPage++;
                });
              } 
              : null,
          child: Text(
            'Next >',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee, BuildContext context) {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: isMobile ? 18 : 20,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                employee.firstName[0] + employee.lastName[0],
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 4 : 6),
            
            // Employee Name
            Text(
              employee.fullName,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 11 : 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            
            // Job Title and Department
            Text(
              '${_getRoleName(employee.roleId)}',
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: isMobile ? 8 : 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _getDepartmentName(employee.departmentId),
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: isMobile ? 8 : 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            
            // Performance Score (Mock)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: isMobile ? 8 : 10,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 2),
                Text(
                  '${85 + (employee.id.hashCode % 15)}/100',
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: isMobile ? 7 : 8,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 4 : 6),
            
            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 4 : 5, 
                vertical: isMobile ? 1 : 2
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(employee.employmentStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getStatusColor(employee.employmentStatus).withOpacity(0.3),
                ),
              ),
              child: Text(
                employee.employmentStatus,
                style: TextStyle(
                  color: _getStatusColor(employee.employmentStatus),
                  fontSize: isMobile ? 7 : 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddEmployee() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEmployeeScreen(),
      ),
    );
    
    // Reload employees if a new employee was added
    if (result == true) {
      _loadEmployees();
    }
  }
} 