import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SkillModel {
  final String id;
  final String employeeId;
  final String skillName;
  final int proficiencyLevel; // 1-5 scale
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  SkillModel({
    required this.id,
    required this.employeeId,
    required this.skillName,
    required this.proficiencyLevel,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      skillName: json['skill_name'] as String,
      proficiencyLevel: json['proficiency_level'] as int,
      description: json['description'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'skill_name': skillName,
      'proficiency_level': proficiencyLevel,
      'description': description,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  SkillModel copyWith({
    String? id,
    String? employeeId,
    String? skillName,
    int? proficiencyLevel,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SkillModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      skillName: skillName ?? this.skillName,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get proficiencyText {
    switch (proficiencyLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Elementary';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  Color get proficiencyColor {
    switch (proficiencyLevel) {
      case 1:
        return const Color(0xFFE74C3C); // Red
      case 2:
        return const Color(0xFFF39C12); // Orange
      case 3:
        return const Color(0xFFF1C40F); // Yellow
      case 4:
        return const Color(0xFF27AE60); // Green
      case 5:
        return const Color(0xFF2ECC71); // Light Green
      default:
        return const Color(0xFF95A5A6); // Gray
    }
  }

  @override
  String toString() {
    return 'SkillModel(id: $id, employeeId: $employeeId, skillName: $skillName, proficiencyLevel: $proficiencyLevel, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkillModel &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.skillName == skillName &&
        other.proficiencyLevel == proficiencyLevel &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        skillName.hashCode ^
        proficiencyLevel.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 