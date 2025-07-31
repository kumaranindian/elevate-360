import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String id;
  final String employeeId;
  final String? userAccountId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final DateTime? dateOfBirth;
  final DateTime hireDate;
  final String departmentId;
  final String roleId;
  final String? teamId;
  final String? managerId;
  final String employmentStatus;
  final String employeeType;
  final String workLocation;
  final double? currentSalary;
  final String? githubUsername;
  final String? linkedinProfile;
  final String? profilePictureUrl;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? emergencyContact;
  final double? joiningBonus;
  final DateTime? probationEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get displayName => '$firstName $lastName';
  bool get isActive => employmentStatus == 'Active';
  bool get isOnLeave => employmentStatus == 'On Leave';
  bool get isProbation => employmentStatus == 'Probation';

  EmployeeModel({
    required this.id,
    required this.employeeId,
    this.userAccountId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.dateOfBirth,
    required this.hireDate,
    required this.departmentId,
    required this.roleId,
    this.teamId,
    this.managerId,
    required this.employmentStatus,
    required this.employeeType,
    required this.workLocation,
    this.currentSalary,
    this.githubUsername,
    this.linkedinProfile,
    this.profilePictureUrl,
    this.address,
    this.emergencyContact,
    this.joiningBonus,
    this.probationEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? const Uuid().v4(),
      employeeId: json['employee_id'] ?? '',
      userAccountId: json['user_account_id'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
      dateOfBirth: _parseDateTime(json['date_of_birth']),
      hireDate: _parseDateTime(json['hire_date']) ?? DateTime.now(),
      departmentId: json['department_id'] ?? '',
      roleId: json['role_id'] ?? '',
      teamId: json['team_id'],
      managerId: json['manager_id'],
      employmentStatus: json['employment_status'] ?? 'Active',
      employeeType: json['employee_type'] ?? 'Full-time',
      workLocation: json['work_location'] ?? 'Office',
      currentSalary: json['current_salary']?.toDouble(),
      githubUsername: json['github_username'],
      linkedinProfile: json['linkedin_profile'],
      profilePictureUrl: json['profile_picture_url'],
      address: json['address'] != null 
          ? Map<String, dynamic>.from(json['address']) 
          : null,
      emergencyContact: json['emergency_contact'] != null 
          ? Map<String, dynamic>.from(json['emergency_contact']) 
          : null,
      joiningBonus: json['joining_bonus']?.toDouble(),
      probationEndDate: _parseDateTime(json['probation_end_date']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  // Helper method to parse DateTime from various formats (String, Timestamp, DateTime)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date string: $value');
        return null;
      }
    }
    
    print('Unknown date format: ${value.runtimeType} - $value');
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'user_account_id': userAccountId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'hire_date': hireDate.toIso8601String(),
      'department_id': departmentId,
      'role_id': roleId,
      'team_id': teamId,
      'manager_id': managerId,
      'employment_status': employmentStatus,
      'employee_type': employeeType,
      'work_location': workLocation,
      'current_salary': currentSalary,
      'github_username': githubUsername,
      'linkedin_profile': linkedinProfile,
      'profile_picture_url': profilePictureUrl,
      'address': address,
      'emergency_contact': emergencyContact,
      'joining_bonus': joiningBonus,
      'probation_end_date': probationEndDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? employeeId,
    String? userAccountId,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    DateTime? hireDate,
    String? departmentId,
    String? roleId,
    String? teamId,
    String? managerId,
    String? employmentStatus,
    String? employeeType,
    String? workLocation,
    double? currentSalary,
    String? githubUsername,
    String? linkedinProfile,
    String? profilePictureUrl,
    Map<String, dynamic>? address,
    Map<String, dynamic>? emergencyContact,
    double? joiningBonus,
    DateTime? probationEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      userAccountId: userAccountId ?? this.userAccountId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hireDate: hireDate ?? this.hireDate,
      departmentId: departmentId ?? this.departmentId,
      roleId: roleId ?? this.roleId,
      teamId: teamId ?? this.teamId,
      managerId: managerId ?? this.managerId,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      employeeType: employeeType ?? this.employeeType,
      workLocation: workLocation ?? this.workLocation,
      currentSalary: currentSalary ?? this.currentSalary,
      githubUsername: githubUsername ?? this.githubUsername,
      linkedinProfile: linkedinProfile ?? this.linkedinProfile,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      joiningBonus: joiningBonus ?? this.joiningBonus,
      probationEndDate: probationEndDate ?? this.probationEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 