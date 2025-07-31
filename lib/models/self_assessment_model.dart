import 'package:cloud_firestore/cloud_firestore.dart';

class SelfAssessmentModel {
  final String id;
  final String employeeId;
  final String quarter;
  final int year;
  final Map<String, double> kpiRatings;
  final String achievements;
  final String challenges;
  final String goals;
  final String feedback;
  final String status;
  final DateTime? submittedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SelfAssessmentModel({
    required this.id,
    required this.employeeId,
    required this.quarter,
    required this.year,
    required this.kpiRatings,
    required this.achievements,
    required this.challenges,
    required this.goals,
    required this.feedback,
    required this.status,
    this.submittedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SelfAssessmentModel.fromJson(Map<String, dynamic> json) {
    return SelfAssessmentModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      quarter: json['quarter'] as String,
      year: json['year'] as int,
      kpiRatings: Map<String, double>.from(json['kpi_ratings'] as Map),
      achievements: json['achievements'] as String,
      challenges: json['challenges'] as String,
      goals: json['goals'] as String,
      feedback: json['feedback'] as String,
      status: json['status'] as String,
      submittedDate: json['submitted_date'] != null 
          ? (json['submitted_date'] as Timestamp).toDate()
          : null,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'quarter': quarter,
      'year': year,
      'kpi_ratings': kpiRatings,
      'achievements': achievements,
      'challenges': challenges,
      'goals': goals,
      'feedback': feedback,
      'status': status,
      'submitted_date': submittedDate != null 
          ? Timestamp.fromDate(submittedDate!)
          : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  SelfAssessmentModel copyWith({
    String? id,
    String? employeeId,
    String? quarter,
    int? year,
    Map<String, double>? kpiRatings,
    String? achievements,
    String? challenges,
    String? goals,
    String? feedback,
    String? status,
    DateTime? submittedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SelfAssessmentModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      quarter: quarter ?? this.quarter,
      year: year ?? this.year,
      kpiRatings: kpiRatings ?? this.kpiRatings,
      achievements: achievements ?? this.achievements,
      challenges: challenges ?? this.challenges,
      goals: goals ?? this.goals,
      feedback: feedback ?? this.feedback,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SelfAssessmentModel(id: $id, employeeId: $employeeId, quarter: $quarter, year: $year, kpiRatings: $kpiRatings, achievements: $achievements, challenges: $challenges, goals: $goals, feedback: $feedback, status: $status, submittedDate: $submittedDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelfAssessmentModel &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.quarter == quarter &&
        other.year == year &&
        other.kpiRatings == kpiRatings &&
        other.achievements == achievements &&
        other.challenges == challenges &&
        other.goals == goals &&
        other.feedback == feedback &&
        other.status == status &&
        other.submittedDate == submittedDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        quarter.hashCode ^
        year.hashCode ^
        kpiRatings.hashCode ^
        achievements.hashCode ^
        challenges.hashCode ^
        goals.hashCode ^
        feedback.hashCode ^
        status.hashCode ^
        submittedDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 