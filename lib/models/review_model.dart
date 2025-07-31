import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String employeeId;
  final String reviewerId;
  final String reviewType;
  final String quarter;
  final int year;
  final double rating;
  final double overallRating;
  final String comments;
  final String status;
  final DateTime? submittedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.employeeId,
    required this.reviewerId,
    required this.reviewType,
    required this.quarter,
    required this.year,
    required this.rating,
    required this.overallRating,
    required this.comments,
    required this.status,
    this.submittedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewType: json['review_type'] as String,
      quarter: json['quarter'] as String,
      year: json['year'] as int,
      rating: (json['rating'] as num).toDouble(),
      overallRating: (json['overall_rating'] as num).toDouble(),
      comments: json['comments'] as String,
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
      'reviewer_id': reviewerId,
      'review_type': reviewType,
      'quarter': quarter,
      'year': year,
      'rating': rating,
      'overall_rating': overallRating,
      'comments': comments,
      'status': status,
      'submitted_date': submittedDate != null 
          ? Timestamp.fromDate(submittedDate!)
          : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? employeeId,
    String? reviewerId,
    String? reviewType,
    String? quarter,
    int? year,
    double? rating,
    double? overallRating,
    String? comments,
    String? status,
    DateTime? submittedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewType: reviewType ?? this.reviewType,
      quarter: quarter ?? this.quarter,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      overallRating: overallRating ?? this.overallRating,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, employeeId: $employeeId, reviewerId: $reviewerId, reviewType: $reviewType, quarter: $quarter, year: $year, rating: $rating, overallRating: $overallRating, comments: $comments, status: $status, submittedDate: $submittedDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.reviewerId == reviewerId &&
        other.reviewType == reviewType &&
        other.quarter == quarter &&
        other.year == year &&
        other.rating == rating &&
        other.overallRating == overallRating &&
        other.comments == comments &&
        other.status == status &&
        other.submittedDate == submittedDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        reviewerId.hashCode ^
        reviewType.hashCode ^
        quarter.hashCode ^
        year.hashCode ^
        rating.hashCode ^
        overallRating.hashCode ^
        comments.hashCode ^
        status.hashCode ^
        submittedDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 