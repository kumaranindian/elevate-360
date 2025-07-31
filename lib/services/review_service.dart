import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all reviews from Firebase
  static Future<List<ReviewModel>> getAllReviews() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('reviews').get();
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return ReviewModel.fromJson({...data, 'id': doc.id});
        } catch (parseError) {
          print('Error parsing review document ${doc.id}: $parseError');
          print('Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // Get reviews by employee ID
  static Future<List<ReviewModel>> getReviewsByEmployeeId(String employeeId) async {
    try {
      try {
        // Try with full query (requires composite index)
        final QuerySnapshot snapshot = await _firestore
            .collection('reviews')
            .where('employee_id', isEqualTo: employeeId)
            .orderBy('year', descending: true)
            .orderBy('quarter', descending: true)
            .get();
        
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ReviewModel.fromJson({...data, 'id': doc.id});
        }).toList();
      } catch (indexError) {
        // If index doesn't exist, fall back to basic query and sort in memory
        print('Composite index not ready for employee reviews. Falling back to memory sort.');
        print('Please create the index using this link:');
        print(indexError.toString());
        
        final QuerySnapshot snapshot = await _firestore
            .collection('reviews')
            .where('employee_id', isEqualTo: employeeId)
            .get();
        
        final reviews = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ReviewModel.fromJson({...data, 'id': doc.id});
        }).toList();
        
        // Sort by year and quarter in memory
        reviews.sort((a, b) {
          final yearCompare = b.year.compareTo(a.year);
          if (yearCompare != 0) return yearCompare;
          // Q4 > Q3 > Q2 > Q1
          return b.quarter.compareTo(a.quarter);
        });
        
        return reviews;
      }
    } catch (e) {
      throw Exception('Failed to load employee reviews: $e');
    }
  }

  // Get reviews by reviewer ID
  static Future<List<ReviewModel>> getReviewsByReviewerId(String reviewerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('reviewer_id', isEqualTo: reviewerId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReviewModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load reviewer reviews: $e');
    }
  }

  // Get reviews by quarter and year
  static Future<List<ReviewModel>> getReviewsByQuarter(String quarter, int year) async {
    try {
      try {
        // Try with full query (requires composite index)
        final QuerySnapshot snapshot = await _firestore
            .collection('reviews')
            .where('quarter', isEqualTo: quarter)
            .where('year', isEqualTo: year)
            .orderBy('created_at', descending: true)  // Add sorting for better UX
            .get();
        
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ReviewModel.fromJson({...data, 'id': doc.id});
        }).toList();
      } catch (indexError) {
        // If index doesn't exist, fall back to basic query and filter in memory
        print('Composite index not ready for quarterly reviews. Falling back to memory filter.');
        print('Please create the index using this link:');
        print(indexError.toString());
        
        // Get reviews for the quarter and filter year in memory
        final QuerySnapshot snapshot = await _firestore
            .collection('reviews')
            .where('quarter', isEqualTo: quarter)
            .get();
        
        final reviews = snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ReviewModel.fromJson({...data, 'id': doc.id});
            })
            .where((review) => review.year == year)
            .toList();
        
        // Sort by created_at in memory
        reviews.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        
        return reviews;
      }
    } catch (e) {
      throw Exception('Failed to load reviews by quarter: $e');
    }
  }

  // Create new review
  static Future<bool> createReview(ReviewModel review) async {
    try {
      final reviewData = review.toJson();
      reviewData['created_at'] = FieldValue.serverTimestamp();
      reviewData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('reviews').add(reviewData);
      return true;
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // Update review
  static Future<bool> updateReview(ReviewModel review) async {
    try {
      final reviewData = review.toJson();
      reviewData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('reviews')
          .doc(review.id)
          .update(reviewData);

      return true;
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  // Delete review
  static Future<bool> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  // Get reviews by status
  static Future<List<ReviewModel>> getReviewsByStatus(String status) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('status', isEqualTo: status)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReviewModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load reviews by status: $e');
    }
  }

  // Get pending reviews
  static Future<List<ReviewModel>> getPendingReviews() async {
    return getReviewsByStatus('Pending');
  }

  // Get completed reviews
  static Future<List<ReviewModel>> getCompletedReviews() async {
    return getReviewsByStatus('Completed');
  }

  // Get reviews by review type
  static Future<List<ReviewModel>> getReviewsByType(String reviewType) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('review_type', isEqualTo: reviewType)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReviewModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load reviews by type: $e');
    }
  }

  // Get self reviews
  static Future<List<ReviewModel>> getSelfReviews() async {
    return getReviewsByType('Self Review');
  }

  // Get manager reviews
  static Future<List<ReviewModel>> getManagerReviews() async {
    return getReviewsByType('Manager Review');
  }

  // Get HR reviews
  static Future<List<ReviewModel>> getHRReviews() async {
    return getReviewsByType('HR Review');
  }
} 