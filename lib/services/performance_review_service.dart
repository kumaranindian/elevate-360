import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance_review_model.dart';

class PerformanceReviewService {
  static final CollectionReference _reviewsCollection =
      FirebaseFirestore.instance.collection('performanceReviews');

  // Helper method to create index creation links
  static String _getIndexCreationLink(String collection, List<String> fields) {
    final projectId = FirebaseFirestore.instance.app.options.projectId;
    final fieldsParam = fields.join(',');
    return 'https://console.firebase.google.com/project/$projectId/firestore/indexes?create_composite=ClJwcm9qZWN0cy8k{$projectId}/databases/(default)/collections/$collection&query_id=index_query&field_path=$fieldsParam';
  }

  // Helper method to handle index errors with fallback
  static Future<List<PerformanceReviewModel>> _handleIndexError(
    Future<List<PerformanceReviewModel>> Function() primaryQuery,
    Future<List<PerformanceReviewModel>> Function() fallbackQuery,
    String indexName,
    List<String> requiredFields,
  ) async {
    try {
      return await primaryQuery();
    } catch (e) {
      if (e.toString().contains('index') || e.toString().contains('Index')) {
        print('⚠️ Index not found for $indexName. Creating index...');
        print('🔗 Create index manually: ${_getIndexCreationLink('performanceReviews', requiredFields)}');
        
        // Try fallback query
        try {
          final results = await fallbackQuery();
          print('✅ Fallback query successful for $indexName');
          return results;
        } catch (fallbackError) {
          print('❌ Fallback query also failed: $fallbackError');
          rethrow;
        }
      }
      rethrow;
    }
  }

  // Create a new performance review
  static Future<PerformanceReviewModel> createReview({
    required String employeeId,
    required String quarter,
    required int year,
  }) async {
    final now = DateTime.now();
    final reviewData = {
      'id': _reviewsCollection.doc().id,
      'employee_id': employeeId,
      'quarter': quarter,
      'year': year,
      'status': PerformanceReviewModel.STATUS_AWAITING_SELF_REVIEW,
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    };

    final docRef = _reviewsCollection.doc(reviewData['id'] as String);
    await docRef.set(reviewData);

    return PerformanceReviewModel.fromJson(reviewData);
  }

  // Get all reviews for an employee with index fallback
  static Future<List<PerformanceReviewModel>> getReviewsByEmployeeId(String employeeId) async {
    return _handleIndexError(
      () async {
        final querySnapshot = await _reviewsCollection
            .where('employee_id', isEqualTo: employeeId)
            .orderBy('year', descending: true)
            .orderBy('quarter', descending: true)
            .get();

        return querySnapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      },
      () async {
        // Fallback: Get all reviews and filter locally
        final querySnapshot = await _reviewsCollection
            .where('employee_id', isEqualTo: employeeId)
            .get();

        final reviews = querySnapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort locally
        reviews.sort((a, b) {
          if (a.year != b.year) return b.year.compareTo(a.year);
          return b.quarter.compareTo(a.quarter);
        });

        return reviews;
      },
      'employee_reviews_with_ordering',
      ['employee_id', 'year', 'quarter'],
    );
  }

  // Get reviews by status with index fallback
  static Future<List<PerformanceReviewModel>> getReviewsByStatus(String status) async {
    return _handleIndexError(
      () async {
        final querySnapshot = await _reviewsCollection
            .where('status', isEqualTo: status)
            .orderBy('updated_at', descending: true)
            .get();

        return querySnapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      },
      () async {
        // Fallback: Get all reviews and filter locally
        final querySnapshot = await _reviewsCollection
            .where('status', isEqualTo: status)
            .get();

        final reviews = querySnapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort locally
        reviews.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return reviews;
      },
      'status_reviews_with_ordering',
      ['status', 'updated_at'],
    );
  }

  // Get a specific review by ID
  static Future<PerformanceReviewModel?> getReviewById(String reviewId) async {
    final docSnapshot = await _reviewsCollection.doc(reviewId).get();
    if (!docSnapshot.exists) return null;

    return PerformanceReviewModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
  }

  // Submit employee self review
  static Future<void> submitSelfReview({
    required String reviewId,
    required Map<String, dynamic> selfReviewData,
  }) async {
    final now = DateTime.now();
    await _reviewsCollection.doc(reviewId).update({
      'self_review_data': selfReviewData,
      'status': PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED,
      'self_review_submitted_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    });
  }

  // Submit manager review
  static Future<void> submitManagerReview({
    required String reviewId,
    required Map<String, dynamic> managerReviewData,
  }) async {
    final now = DateTime.now();
    await _reviewsCollection.doc(reviewId).update({
      'manager_review_data': managerReviewData,
      'status': PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED,
      'manager_review_submitted_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    });
  }

  // Submit HR review
  static Future<void> submitHRReview({
    required String reviewId,
    required Map<String, dynamic> hrReviewData,
  }) async {
    final now = DateTime.now();
    await _reviewsCollection.doc(reviewId).update({
      'hr_review_data': hrReviewData,
      'status': PerformanceReviewModel.STATUS_REVIEW_COMPLETED,
      'hr_review_submitted_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    });
  }

  // Get reviews for manager's reportees with index fallback
  static Future<List<PerformanceReviewModel>> getReporteeReviews(String managerId) async {
    return _handleIndexError(
      () async {
        // First get all reportees for this manager
        final reporteesSnapshot = await FirebaseFirestore.instance
            .collection('employees')
            .where('manager_id', isEqualTo: managerId)
            .get();

        final reporteeIds = reporteesSnapshot.docs.map((doc) => doc.id).toList();

        if (reporteeIds.isEmpty) return [];

        // Then get all reviews for these reportees
        final reviewsSnapshot = await _reviewsCollection
            .where('employee_id', whereIn: reporteeIds)
            .where('status', isEqualTo: PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED)
            .orderBy('updated_at', descending: true)
            .get();

        return reviewsSnapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      },
      () async {
        // Fallback: Get all reviews and filter locally
        final allReviewsSnapshot = await _reviewsCollection
            .where('status', isEqualTo: PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED)
            .get();

        final allReviews = allReviewsSnapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        // Get reportee IDs
        final reporteesSnapshot = await FirebaseFirestore.instance
            .collection('employees')
            .where('manager_id', isEqualTo: managerId)
            .get();

        final reporteeIds = reporteesSnapshot.docs.map((doc) => doc.id).toSet();

        // Filter and sort locally
        final filteredReviews = allReviews
            .where((review) => reporteeIds.contains(review.employeeId))
            .toList();

        filteredReviews.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return filteredReviews;
      },
      'reportee_reviews_composite',
      ['employee_id', 'status', 'updated_at'],
    );
  }

  // Stream of reviews for real-time updates with index fallback
  static Stream<List<PerformanceReviewModel>> streamReviewsByEmployeeId(String employeeId) {
    return _reviewsCollection
        .where('employee_id', isEqualTo: employeeId)
        .orderBy('year', descending: true)
        .orderBy('quarter', descending: true)
        .snapshots()
        .handleError((error) {
          print('⚠️ Stream index error for employee reviews. Creating index...');
          print('🔗 Create index manually: ${_getIndexCreationLink('performanceReviews', ['employee_id', 'year', 'quarter'])}');
          return Stream.value(<PerformanceReviewModel>[]);
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Stream of reportee reviews for managers with index fallback
  static Stream<List<PerformanceReviewModel>> streamReporteeReviews(String managerId) {
    return _reviewsCollection
        .where('status', isEqualTo: PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .handleError((error) {
          print('⚠️ Stream index error for reportee reviews. Creating index...');
          print('🔗 Create index manually: ${_getIndexCreationLink('performanceReviews', ['status', 'updated_at'])}');
          return Stream.value(<PerformanceReviewModel>[]);
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Stream of reviews for HR with index fallback
  static Stream<List<PerformanceReviewModel>> streamReviewsForHR() {
    return _reviewsCollection
        .where('status', isEqualTo: PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .handleError((error) {
          print('⚠️ Stream index error for HR reviews. Creating index...');
          print('🔗 Create index manually: ${_getIndexCreationLink('performanceReviews', ['status', 'updated_at'])}');
          return Stream.value(<PerformanceReviewModel>[]);
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Method to create all required indexes automatically
  static Future<void> createRequiredIndexes() async {
    print('🔧 Creating required indexes for performance reviews...');
    
    final indexes = [
      {
        'name': 'employee_reviews_with_ordering',
        'fields': ['employee_id', 'year', 'quarter'],
        'description': 'For querying employee reviews with ordering'
      },
      {
        'name': 'status_reviews_with_ordering',
        'fields': ['status', 'updated_at'],
        'description': 'For querying reviews by status with ordering'
      },
      {
        'name': 'reportee_reviews_composite',
        'fields': ['employee_id', 'status', 'updated_at'],
        'description': 'For querying reportee reviews with composite conditions'
      }
    ];

    for (final index in indexes) {
      final link = _getIndexCreationLink('performanceReviews', index['fields'] as List<String>);
      print('📋 ${index['name']}: ${index['description']}');
      print('🔗 Create: $link');
    }
    
    print('✅ Index creation links generated. Please create these indexes manually in Firebase Console.');
  }
}