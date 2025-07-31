import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PerformanceReviewModel {
  final String id;
  final String employeeId;
  final String quarter;
  final int year;
  final Map<String, dynamic>? selfReviewData;
  final Map<String, dynamic>? managerReviewData;
  final Map<String, dynamic>? hrReviewData;
  final String status;
  final DateTime? selfReviewSubmittedAt;
  final DateTime? managerReviewSubmittedAt;
  final DateTime? hrReviewSubmittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Status constants
  static const String STATUS_AWAITING_SELF_REVIEW = 'awaiting self review';
  static const String STATUS_SELF_REVIEW_COMPLETED = 'self review completed';
  static const String STATUS_MANAGER_REVIEW_COMPLETED = 'manager review completed';
  static const String STATUS_REVIEW_COMPLETED = 'review completed';

  static const List<String> ALL_STATUSES = [
    STATUS_AWAITING_SELF_REVIEW,
    STATUS_SELF_REVIEW_COMPLETED,
    STATUS_MANAGER_REVIEW_COMPLETED,
    STATUS_REVIEW_COMPLETED,
  ];

  PerformanceReviewModel({
    required this.id,
    required this.employeeId,
    required this.quarter,
    required this.year,
    this.selfReviewData,
    this.managerReviewData,
    this.hrReviewData,
    required this.status,
    this.selfReviewSubmittedAt,
    this.managerReviewSubmittedAt,
    this.hrReviewSubmittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PerformanceReviewModel.fromJson(Map<String, dynamic> json) {
    return PerformanceReviewModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      quarter: json['quarter'] as String,
      year: json['year'] as int,
      selfReviewData: json['self_review_data'] as Map<String, dynamic>?,
      managerReviewData: json['manager_review_data'] as Map<String, dynamic>?,
      hrReviewData: json['hr_review_data'] as Map<String, dynamic>?,
      status: json['status'] as String,
      selfReviewSubmittedAt: json['self_review_submitted_at'] != null 
          ? (json['self_review_submitted_at'] as Timestamp).toDate()
          : null,
      managerReviewSubmittedAt: json['manager_review_submitted_at'] != null 
          ? (json['manager_review_submitted_at'] as Timestamp).toDate()
          : null,
      hrReviewSubmittedAt: json['hr_review_submitted_at'] != null 
          ? (json['hr_review_submitted_at'] as Timestamp).toDate()
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
      'self_review_data': selfReviewData,
      'manager_review_data': managerReviewData,
      'hr_review_data': hrReviewData,
      'status': status,
      'self_review_submitted_at': selfReviewSubmittedAt != null 
          ? Timestamp.fromDate(selfReviewSubmittedAt!)
          : null,
      'manager_review_submitted_at': managerReviewSubmittedAt != null 
          ? Timestamp.fromDate(managerReviewSubmittedAt!)
          : null,
      'hr_review_submitted_at': hrReviewSubmittedAt != null 
          ? Timestamp.fromDate(hrReviewSubmittedAt!)
          : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  PerformanceReviewModel copyWith({
    String? id,
    String? employeeId,
    String? quarter,
    int? year,
    Map<String, dynamic>? selfReviewData,
    Map<String, dynamic>? managerReviewData,
    Map<String, dynamic>? hrReviewData,
    String? status,
    DateTime? selfReviewSubmittedAt,
    DateTime? managerReviewSubmittedAt,
    DateTime? hrReviewSubmittedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PerformanceReviewModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      quarter: quarter ?? this.quarter,
      year: year ?? this.year,
      selfReviewData: selfReviewData ?? this.selfReviewData,
      managerReviewData: managerReviewData ?? this.managerReviewData,
      hrReviewData: hrReviewData ?? this.hrReviewData,
      status: status ?? this.status,
      selfReviewSubmittedAt: selfReviewSubmittedAt ?? this.selfReviewSubmittedAt,
      managerReviewSubmittedAt: managerReviewSubmittedAt ?? this.managerReviewSubmittedAt,
      hrReviewSubmittedAt: hrReviewSubmittedAt ?? this.hrReviewSubmittedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for status checks
  bool get isAwaitingSelfReview => status == STATUS_AWAITING_SELF_REVIEW;
  bool get isSelfReviewCompleted => status == STATUS_SELF_REVIEW_COMPLETED;
  bool get isManagerReviewCompleted => status == STATUS_MANAGER_REVIEW_COMPLETED;
  bool get isReviewCompleted => status == STATUS_REVIEW_COMPLETED;

  // Helper method to get status display text
  String get statusDisplayText {
    switch (status) {
      case STATUS_AWAITING_SELF_REVIEW:
        return 'Awaiting Self Review';
      case STATUS_SELF_REVIEW_COMPLETED:
        return 'Self Review Completed';
      case STATUS_MANAGER_REVIEW_COMPLETED:
        return 'Manager Review Completed';
      case STATUS_REVIEW_COMPLETED:
        return 'Review Completed';
      default:
        return 'Unknown Status';
    }
  }

  // Helper method to get status color
  Color getStatusColor() {
    switch (status) {
      case STATUS_AWAITING_SELF_REVIEW:
        return Colors.orange;
      case STATUS_SELF_REVIEW_COMPLETED:
        return Colors.blue;
      case STATUS_MANAGER_REVIEW_COMPLETED:
        return Colors.purple;
      case STATUS_REVIEW_COMPLETED:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}