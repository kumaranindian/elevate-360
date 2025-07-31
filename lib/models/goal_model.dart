import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String employeeId;
  final String managerId;
  final String? categoryId;
  final String? projectId;
  final String title;
  final String? description;
  final String goalType;
  final String priority;
  final double weightage;
  final double? targetValue;
  final double currentValue;
  final String? unit;
  final String? measurementMethod;
  final DateTime startDate;
  final DateTime dueDate;
  final DateTime? completionDate;
  final String status;
  final double progressPercentage;
  final bool isStretchGoal;
  final String createdBy;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed properties
  bool get isCompleted => status == 'Completed';
  bool get isInProgress => status == 'In Progress';
  bool get isNotStarted => status == 'Not Started';
  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isCompleted;
  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;
  double get progressRatio => progressPercentage / 100.0;

  GoalModel({
    required this.id,
    required this.employeeId,
    required this.managerId,
    this.categoryId,
    this.projectId,
    required this.title,
    this.description,
    required this.goalType,
    required this.priority,
    required this.weightage,
    this.targetValue,
    required this.currentValue,
    this.unit,
    this.measurementMethod,
    required this.startDate,
    required this.dueDate,
    this.completionDate,
    required this.status,
    required this.progressPercentage,
    required this.isStretchGoal,
    required this.createdBy,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? const Uuid().v4(),
      employeeId: json['employee_id'] ?? '',
      managerId: json['manager_id'] ?? '',
      categoryId: json['category_id'],
      projectId: json['project_id'],
      title: json['title'] ?? '',
      description: json['description'],
      goalType: json['goal_type'] ?? 'Quarterly',
      priority: json['priority'] ?? 'Medium',
      weightage: (json['weightage'] ?? 20.0).toDouble(),
      targetValue: json['target_value']?.toDouble(),
      currentValue: (json['current_value'] ?? 0.0).toDouble(),
      unit: json['unit'],
      measurementMethod: json['measurement_method'],
      startDate: _parseDateTime(json['start_date']) ?? DateTime.now(),
      dueDate: _parseDateTime(json['due_date']) ?? DateTime.now(),
      completionDate: _parseDateTime(json['completion_date']),
      status: json['status'] ?? 'Not Started',
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
      isStretchGoal: json['is_stretch_goal'] ?? false,
      createdBy: json['created_by'] ?? '',
      approvedBy: json['approved_by'],
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
      'manager_id': managerId,
      'category_id': categoryId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'goal_type': goalType,
      'priority': priority,
      'weightage': weightage,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'measurement_method': measurementMethod,
      'start_date': startDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'status': status,
      'progress_percentage': progressPercentage,
      'is_stretch_goal': isStretchGoal,
      'created_by': createdBy,
      'approved_by': approvedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GoalModel copyWith({
    String? id,
    String? employeeId,
    String? managerId,
    String? categoryId,
    String? projectId,
    String? title,
    String? description,
    String? goalType,
    String? priority,
    double? weightage,
    double? targetValue,
    double? currentValue,
    String? unit,
    String? measurementMethod,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completionDate,
    String? status,
    double? progressPercentage,
    bool? isStretchGoal,
    String? createdBy,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      managerId: managerId ?? this.managerId,
      categoryId: categoryId ?? this.categoryId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      goalType: goalType ?? this.goalType,
      priority: priority ?? this.priority,
      weightage: weightage ?? this.weightage,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      measurementMethod: measurementMethod ?? this.measurementMethod,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completionDate: completionDate ?? this.completionDate,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isStretchGoal: isStretchGoal ?? this.isStretchGoal,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GoalCategoryModel {
  final String id;
  final String name;
  final String? description;
  final String categoryType;
  final String? colorCode;
  final bool isActive;
  final DateTime createdAt;

  GoalCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.categoryType,
    this.colorCode,
    required this.isActive,
    required this.createdAt,
  });

  factory GoalCategoryModel.fromJson(Map<String, dynamic> json) {
    return GoalCategoryModel(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      description: json['description'],
      categoryType: json['category_type'] ?? 'Technical',
      colorCode: json['color_code'],
      isActive: json['is_active'] ?? true,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
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
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_type': categoryType,
      'color_code': colorCode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 