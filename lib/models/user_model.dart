import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final DateTime? passwordChangedAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
    this.passwordChangedAt,
    this.updatedAt,
  });

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      isActive: data['is_active'] ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      lastLogin: data['last_login'] != null 
          ? (data['last_login'] as Timestamp).toDate() 
          : null,
      passwordChangedAt: data['password_changed_at'] != null 
          ? (data['password_changed_at'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updated_at'] != null 
          ? (data['updated_at'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'last_login': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'password_changed_at': passwordChangedAt != null 
          ? Timestamp.fromDate(passwordChangedAt!) 
          : null,
      'updated_at': Timestamp.fromDate(DateTime.now()),
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? passwordChangedAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if user is super admin
  bool get isSuperAdmin => role == 'super_admin';
  
  // Check if user is HR admin
  bool get isHrAdmin => role == 'hr_admin';
  
  // Check if user is manager
  bool get isManager => role == 'manager';
  
  // Check if user is employee
  bool get isEmployee => role == 'employee';

  @override
  String toString() {
    return 'UserModel(uid: $uid, username: $username, email: $email, role: $role, isActive: $isActive)';
  }
} 