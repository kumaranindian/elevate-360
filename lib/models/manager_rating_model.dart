import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ManagerRatingModel {
  final String id;
  final String employeeId;
  final String managerId;
  final String quarter;
  final int year;
  final Map<String, double> kpiRatings;
  final String feedback;
  final double overallRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'Draft', 'Submitted', 'Reviewed'

  ManagerRatingModel({
    required this.id,
    required this.employeeId,
    required this.managerId,
    required this.quarter,
    required this.year,
    required this.kpiRatings,
    required this.feedback,
    required this.overallRating,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'Draft',
  });

  factory ManagerRatingModel.fromJson(Map<String, dynamic> json) {
    return ManagerRatingModel(
      id: json['id'] ?? const Uuid().v4(),
      employeeId: json['employee_id'] ?? '',
      managerId: json['manager_id'] ?? '',
      quarter: json['quarter'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      kpiRatings: Map<String, double>.from(json['kpi_ratings'] ?? {}),
      feedback: json['feedback'] ?? '',
      overallRating: (json['overall_rating'] ?? 0.0).toDouble(),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      status: json['status'] ?? 'Draft',
    );
  }

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
      'quarter': quarter,
      'year': year,
      'kpi_ratings': kpiRatings,
      'feedback': feedback,
      'overall_rating': overallRating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
    };
  }

  ManagerRatingModel copyWith({
    String? id,
    String? employeeId,
    String? managerId,
    String? quarter,
    int? year,
    Map<String, double>? kpiRatings,
    String? feedback,
    double? overallRating,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return ManagerRatingModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      managerId: managerId ?? this.managerId,
      quarter: quarter ?? this.quarter,
      year: year ?? this.year,
      kpiRatings: kpiRatings ?? Map<String, double>.from(this.kpiRatings),
      feedback: feedback ?? this.feedback,
      overallRating: overallRating ?? this.overallRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ManagerRatingModel(id: $id, employeeId: $employeeId, managerId: $managerId, quarter: $quarter, year: $year, overallRating: $overallRating, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ManagerRatingModel &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.managerId == managerId &&
        other.quarter == quarter &&
        other.year == year;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        managerId.hashCode ^
        quarter.hashCode ^
        year.hashCode;
  }

  /// Get performance level based on overall rating
  String get performanceLevel {
    if (overallRating >= 4.5) return 'Exceptional';
    if (overallRating >= 4.0) return 'Exceeds Expectations';
    if (overallRating >= 3.0) return 'Meets Expectations';
    if (overallRating >= 2.0) return 'Below Expectations';
    return 'Needs Improvement';
  }

  /// Get color associated with performance level
  String get performanceColor {
    if (overallRating >= 4.5) return '#4CAF50'; // Green
    if (overallRating >= 4.0) return '#8BC34A'; // Light Green
    if (overallRating >= 3.0) return '#FF9800'; // Orange
    if (overallRating >= 2.0) return '#FF5722'; // Deep Orange
    return '#F44336'; // Red
  }

  /// Check if rating is complete (has feedback and ratings)
  bool get isComplete {
    return feedback.isNotEmpty && 
           kpiRatings.isNotEmpty && 
           overallRating > 0;
  }

  /// Get the most recent KPI categories that need improvement (rating < 3.0)
  List<String> get improvementAreas {
    return kpiRatings.entries
        .where((entry) => entry.value < 3.0)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get the strongest KPI categories (rating >= 4.0)
  List<String> get strengths {
    return kpiRatings.entries
        .where((entry) => entry.value >= 4.0)
        .map((entry) => entry.key)
        .toList();
  }
}
