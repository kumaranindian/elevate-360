import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance_review_model.dart';

class PerformanceReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _reviewsCollection = _firestore.collection('performance_reviews');

  // Generate review ID using the format: year_quarter_employeeid_reviewtype
  static String _generateReviewId({
    required String employeeId,
    required String quarter,
    required int year,
    required int reviewType, // 1=self, 2=manager, 3=HR
  }) {
    // Extract quarter number from quarter string (e.g., "Q1 2025" -> "q1")
    final quarterLower = quarter.toLowerCase().replaceAll(' ', '').replaceAll(year.toString(), '');
    return '${year}_${quarterLower}_${employeeId}_$reviewType';
  }

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

  // Create a new performance review (creates self-review document)
  static Future<PerformanceReviewModel> createReview({
    required String employeeId,
    required String quarter,
    required int year,
  }) async {
    final now = DateTime.now();
    
    // Generate self-review ID using new convention (reviewType = 1 for self)
    final selfReviewId = _generateReviewId(
      employeeId: employeeId,
      quarter: quarter,
      year: year,
      reviewType: 1, // Self review
    );
    
    final reviewData = {
      'id': selfReviewId,
      'employee_id': employeeId,
      'quarter': quarter,
      'year': year,
      'review_type': 'self_review',
      'status': PerformanceReviewModel.STATUS_AWAITING_SELF_REVIEW,
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    };

    final docRef = _reviewsCollection.doc(selfReviewId);
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
    
    // Get the self-review document to extract employee info
    final selfReviewDoc = await _reviewsCollection.doc(reviewId).get();
    if (!selfReviewDoc.exists) {
      throw Exception('Self review not found');
    }
    
    final selfReviewData = selfReviewDoc.data() as Map<String, dynamic>;
    final employeeId = selfReviewData['employee_id'] as String;
    final quarter = selfReviewData['quarter'] as String;
    final year = selfReviewData['year'] as int;
    
    // Generate manager review ID using new convention (reviewType = 2 for manager)
    final managerReviewId = _generateReviewId(
      employeeId: employeeId,
      quarter: quarter,
      year: year,
      reviewType: 2, // Manager review
    );
    
    // Create manager review document
    final managerReviewDocData = {
      'id': managerReviewId,
      'employee_id': employeeId,
      'quarter': quarter,
      'year': year,
      'review_type': 'manager_review',
      'manager_review_data': managerReviewData,
      'status': PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED,
      'manager_review_submitted_at': Timestamp.fromDate(now),
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    };
    
    // Save manager review as separate document
    await _reviewsCollection.doc(managerReviewId).set(managerReviewDocData);
    
    // Update self-review document status
    await _reviewsCollection.doc(reviewId).update({
      'status': PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED,
      'updated_at': Timestamp.fromDate(now),
    });
  }

  // Submit HR review
  static Future<void> submitHRReview({
    required String reviewId,
    required Map<String, dynamic> hrReviewData,
  }) async {
    final now = DateTime.now();
    
    // Get the self-review document to extract employee info
    final selfReviewDoc = await _reviewsCollection.doc(reviewId).get();
    if (!selfReviewDoc.exists) {
      throw Exception('Self review not found');
    }
    
    final selfReviewData = selfReviewDoc.data() as Map<String, dynamic>;
    final employeeId = selfReviewData['employee_id'] as String;
    final quarter = selfReviewData['quarter'] as String;
    final year = selfReviewData['year'] as int;
    
    // Generate HR review ID using new convention (reviewType = 3 for HR)
    final hrReviewId = _generateReviewId(
      employeeId: employeeId,
      quarter: quarter,
      year: year,
      reviewType: 3, // HR review
    );
    
    // Create HR review document
    final hrReviewDocData = {
      'id': hrReviewId,
      'employee_id': employeeId,
      'quarter': quarter,
      'year': year,
      'review_type': 'hr_review',
      'hr_review_data': hrReviewData,
      'status': PerformanceReviewModel.STATUS_REVIEW_COMPLETED,
      'hr_review_submitted_at': Timestamp.fromDate(now),
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    };
    
    // Save HR review as separate document
    await _reviewsCollection.doc(hrReviewId).set(hrReviewDocData);
    
    // Update self-review document status
    await _reviewsCollection.doc(reviewId).update({
      'status': PerformanceReviewModel.STATUS_REVIEW_COMPLETED,
      'updated_at': Timestamp.fromDate(now),
    });
  }

  // Get reviews for manager's reportees with index fallback
  static Future<List<PerformanceReviewModel>> getReporteeReviews(String managerId) async {
    return _handleIndexError(
      () async {
        print('DEBUG: Getting reportees for manager: $managerId');
        // First get all reportees for this manager
        final reporteesSnapshot = await FirebaseFirestore.instance
            .collection('employees')
            .where('manager_id', isEqualTo: managerId)
            .get();

        final reporteeIds = reporteesSnapshot.docs.map((doc) => doc.id).toList();
        print('DEBUG: Found ${reporteeIds.length} reportees: $reporteeIds');

        if (reporteeIds.isEmpty) return [];

        // Get ALL reviews for these reportees (not just self review completed)
        print('DEBUG: Looking for all reviews for reportees');
        final reviewsSnapshot = await _reviewsCollection
            .where('employee_id', whereIn: reporteeIds)
            .orderBy('updated_at', descending: true)
            .get();

        print('DEBUG: Found ${reviewsSnapshot.docs.length} total reviews for reportees');
        final reviews = reviewsSnapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        
        // Log status breakdown for debugging
        final statusCounts = <String, int>{};
        for (final review in reviews) {
          statusCounts[review.status] = (statusCounts[review.status] ?? 0) + 1;
        }
        print('DEBUG: Review status breakdown: $statusCounts');
        
        return reviews;
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
        .where('status', whereIn: [
          PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED,
          PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED
        ])
        .orderBy('updated_at', descending: true)
        .snapshots()
        .handleError((error) {
          print('⚠️ Stream index error for HR reviews. Creating index...');
          print(_getIndexCreationLink('performanceReviews', ['status', 'updated_at']));
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get review counts by status for HR dashboard
  static Future<Map<String, int>> getReviewCountsByStatus() async {
    try {
      final allReviewsSnapshot = await _reviewsCollection.get();
      final allReviews = allReviewsSnapshot.docs
          .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      final counts = <String, int>{
        'awaiting_self_review': 0,
        'self_review_completed': 0,
        'manager_review_completed': 0,
        'review_completed': 0,
      };

      for (final review in allReviews) {
        switch (review.status) {
          case PerformanceReviewModel.STATUS_AWAITING_SELF_REVIEW:
            counts['awaiting_self_review'] = (counts['awaiting_self_review'] ?? 0) + 1;
            break;
          case PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED:
            counts['self_review_completed'] = (counts['self_review_completed'] ?? 0) + 1;
            break;
          case PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED:
            counts['manager_review_completed'] = (counts['manager_review_completed'] ?? 0) + 1;
            break;
          case PerformanceReviewModel.STATUS_REVIEW_COMPLETED:
            counts['review_completed'] = (counts['review_completed'] ?? 0) + 1;
            break;
        }
      }

      return counts;
    } catch (e) {
      print('Error getting review counts: $e');
      return {
        'awaiting_self_review': 0,
        'self_review_completed': 0,
        'manager_review_completed': 0,
        'review_completed': 0,
      };
    }
  }

  // Get reviews pending for HR (manager review completed, waiting for HR)
  static Future<List<PerformanceReviewModel>> getReviewsForHR() async {
    try {
      print('DEBUG getReviewsForHR: Looking for status: "${PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED}"');
      
      QuerySnapshot reviewsSnapshot;
      try {
        // Try with orderBy first
        reviewsSnapshot = await _reviewsCollection
            .where('status', isEqualTo: PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED)
            .orderBy('updated_at', descending: true)
            .get();
        print('DEBUG getReviewsForHR: Query with orderBy succeeded');
      } catch (indexError) {
        print('DEBUG getReviewsForHR: Query with orderBy failed (likely missing index): $indexError');
        print('DEBUG getReviewsForHR: Trying query without orderBy...');
        // Fallback: query without orderBy
        reviewsSnapshot = await _reviewsCollection
            .where('status', isEqualTo: PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED)
            .get();
        print('DEBUG getReviewsForHR: Query without orderBy succeeded');
      }

      print('DEBUG getReviewsForHR: Found ${reviewsSnapshot.docs.length} documents');
      
      // Debug each document found
      for (int i = 0; i < reviewsSnapshot.docs.length; i++) {
        final doc = reviewsSnapshot.docs[i];
        final data = doc.data() as Map<String, dynamic>;
        print('DEBUG getReviewsForHR: Doc $i - ID: ${doc.id}, Status: "${data['status']}", Employee: ${data['employee_id']}');
      }

      final reviews = reviewsSnapshot.docs
          .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      print('DEBUG getReviewsForHR: Returning ${reviews.length} PerformanceReviewModel objects');
      return reviews;
    } catch (e) {
      print('Error getting reviews for HR: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get pending review counts for a manager
  static Future<Map<String, int>> getManagerPendingReviewCounts(String managerId) async {
    try {
      print('DEBUG: Getting pending review counts for manager: $managerId');
      // Get reportee IDs for this manager
      final reporteesSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('manager_id', isEqualTo: managerId)
          .get();
      final reporteeIds = reporteesSnapshot.docs.map((doc) => doc.id).toList();
      print('DEBUG: Found ${reporteeIds.length} reportees for counts: $reporteeIds');
      
      if (reporteeIds.isEmpty) {
        print('DEBUG: No reportees found, returning zero counts');
        return {
          'reportees_pending_self_review': 0,
          'reviews_pending_manager_review': 0,
        };
      }

      // Count reportees with pending self reviews
      final pendingSelfReviewsSnapshot = await _reviewsCollection
          .where('employee_id', whereIn: reporteeIds)
          .where('status', isEqualTo: PerformanceReviewModel.STATUS_AWAITING_SELF_REVIEW)
          .get();
      print('DEBUG: Found ${pendingSelfReviewsSnapshot.docs.length} pending self reviews');

      // Count reviews pending manager review (self review completed)
      final pendingManagerReviewsSnapshot = await _reviewsCollection
          .where('employee_id', whereIn: reporteeIds)
          .where('status', isEqualTo: PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED)
          .get();
      print('DEBUG: Found ${pendingManagerReviewsSnapshot.docs.length} pending manager reviews');

      return {
        'reportees_pending_self_review': pendingSelfReviewsSnapshot.docs.length,
        'reviews_pending_manager_review': pendingManagerReviewsSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting manager pending review counts: $e');
      return {
        'reportees_pending_self_review': 0,
        'reviews_pending_manager_review': 0,
      };
    }
  }

  // Get reportees with pending self reviews for a manager
  static Future<List<Map<String, dynamic>>> getReporteesWithPendingSelfReviews(String managerId) async {
    try {
      // Get reportee IDs for this manager
      final reporteesSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('manager_id', isEqualTo: managerId)
          .get();
      final reporteeIds = reporteesSnapshot.docs.map((doc) => doc.id).toList();
      
      if (reporteeIds.isEmpty) {
        return [];
      }

      // Get reviews with pending self reviews
      final pendingReviewsSnapshot = await _reviewsCollection
          .where('employee_id', whereIn: reporteeIds)
          .where('status', isEqualTo: PerformanceReviewModel.STATUS_AWAITING_SELF_REVIEW)
          .get();

      // Get employee details for each pending review
      final result = <Map<String, dynamic>>[];
      for (final doc in pendingReviewsSnapshot.docs) {
        final reviewData = doc.data() as Map<String, dynamic>;
        final employeeId = reviewData['employee_id'] as String;
        
        // Get employee details
        final employeeDoc = await FirebaseFirestore.instance
            .collection('employees')
            .doc(employeeId)
            .get();
        
        if (employeeDoc.exists) {
          final employeeData = employeeDoc.data() as Map<String, dynamic>;
          print('DEBUG: First location employee data for $employeeId: $employeeData');
          
          String employeeName = 'Unknown Employee';
          if (employeeData['first_name'] != null && employeeData['last_name'] != null) {
            employeeName = '${employeeData['first_name']} ${employeeData['last_name']}';
            print('DEBUG: First location using first_name + last_name: $employeeName');
          } else if (employeeData['name'] != null) {
            employeeName = employeeData['name'] as String;
            print('DEBUG: First location using name field: $employeeName');
          } else if (employeeData['displayName'] != null) {
            employeeName = employeeData['displayName'] as String;
            print('DEBUG: First location using displayName field: $employeeName');
          } else {
            print('DEBUG: First location no name fields found for $employeeId, using Unknown Employee');
          }
          
          result.add({
            'review_id': doc.id,
            'employee_id': employeeId,
            'employee_name': employeeName,
            'quarter': reviewData['quarter'],
            'year': reviewData['year'],
            'status': reviewData['status'],
          });
        }
      }

      return result;
    } catch (e) {
      print('Error getting reportees with pending self reviews: $e');
      return [];
    }
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

  // Get reportee reviews grouped by status for manager dashboard
  static Future<Map<String, List<Map<String, dynamic>>>> getReporteeReviewsByStatus(String managerId) async {
    try {
      print('DEBUG: Getting reportee reviews grouped by status for manager: $managerId');
      
      // First get all reportees for this manager
      final reporteesSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('manager_id', isEqualTo: managerId)
          .get();

      final reporteeIds = reporteesSnapshot.docs.map((doc) => doc.id).toList();
      print('DEBUG: Found ${reporteeIds.length} reportees: $reporteeIds');

      if (reporteeIds.isEmpty) {
        return {
          'self_review_pending': [],
          'manager_review_pending': [],
          'hr_review_pending': [],
          'completed': [],
        };
      }

      // Get all reviews for these reportees
      final reviewsSnapshot = await _reviewsCollection
          .where('employee_id', whereIn: reporteeIds)
          .orderBy('updated_at', descending: true)
          .get();

      print('DEBUG: Found ${reviewsSnapshot.docs.length} total reviews for reportees');

      // Group reviews by status
      final Map<String, List<Map<String, dynamic>>> groupedReviews = {
        'self_review_pending': [],
        'manager_review_pending': [],
        'hr_review_pending': [],
        'completed': [],
      };

      // Create a map to store combined review data for each employee
      final Map<String, Map<String, dynamic>> combinedReviewsByEmployee = {};

      for (final doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final employeeId = data['employee_id'] as String;
        final status = data['status'] as String;
        final docId = doc.id;
        
        print('DEBUG: Processing review document $docId for employee $employeeId with status: $status');
        
        // Get employee details (only once per employee)
        if (!combinedReviewsByEmployee.containsKey(employeeId)) {
          final employeeDoc = await FirebaseFirestore.instance
              .collection('employees')
              .doc(employeeId)
              .get();
              
          String employeeName = 'Unknown Employee';
          if (employeeDoc.exists) {
            final employeeData = employeeDoc.data() as Map<String, dynamic>;
            
            if (employeeData['first_name'] != null && employeeData['last_name'] != null) {
              employeeName = '${employeeData['first_name']} ${employeeData['last_name']}';
            } else if (employeeData['name'] != null) {
              employeeName = employeeData['name'] as String;
            } else if (employeeData['displayName'] != null) {
              employeeName = employeeData['displayName'] as String;
            }
          }
          
          // Initialize combined review data for this employee
          combinedReviewsByEmployee[employeeId] = {
            'review_id': docId,
            'employee_id': employeeId,
            'employee_name': employeeName,
            'quarter': data['quarter'],
            'year': data['year'],
            'status': 'awaiting self review', // Default status
            'self_review_data': null,
            'manager_review_data': null,
            'hr_review_data': null,
            'self_review_submitted_at': null,
            'manager_review_submitted_at': null,
            'hr_review_submitted_at': null,
            'created_at': data['created_at'],
            'updated_at': data['updated_at'],
          };
        }
        
        final combinedData = combinedReviewsByEmployee[employeeId]!;
        
        // Determine review type from document ID (format: year_quarter_employeeid_reviewtype)
        final reviewType = docId.split('_').last;
        print('DEBUG: Review type: $reviewType for document $docId');
        
        // Merge data based on review type
        if (reviewType == '1') {
          // Self review data
          combinedData['self_review_data'] = data['self_review_data'] ?? data;
          combinedData['self_review_submitted_at'] = data['self_review_submitted_at'] ?? data['updated_at'];
          if (status == 'self review completed' || status == 'manager review completed' || status == 'review completed') {
            combinedData['status'] = 'self review completed';
          }
          print('DEBUG: Added self review data for $employeeId');
        } else if (reviewType == '2') {
          // Manager review data
          combinedData['manager_review_data'] = data['manager_review_data'] ?? data;
          combinedData['manager_review_submitted_at'] = data['manager_review_submitted_at'] ?? data['updated_at'];
          if (status == 'manager review completed' || status == 'review completed') {
            combinedData['status'] = 'manager review completed';
          }
          print('DEBUG: Added manager review data for $employeeId');
        } else if (reviewType == '3') {
          // HR review data
          combinedData['hr_review_data'] = data['hr_review_data'] ?? data;
          combinedData['hr_review_submitted_at'] = data['hr_review_submitted_at'] ?? data['updated_at'];
          if (status == 'review completed') {
            combinedData['status'] = 'review completed';
          }
          print('DEBUG: Added HR review data for $employeeId');
        }
        
        // Update the latest timestamp
        if ((data['updated_at'] as Timestamp).toDate().isAfter(
              (combinedData['updated_at'] as Timestamp).toDate()
            )) {
          combinedData['updated_at'] = data['updated_at'];
        }
      }

      // Now group the combined reviews by status
      for (final reviewData in combinedReviewsByEmployee.values) {
        final status = reviewData['status'] as String;
        
        switch (status) {
          case 'awaiting self review':
            groupedReviews['self_review_pending']!.add(reviewData);
            break;
          case 'self review completed':
            groupedReviews['manager_review_pending']!.add(reviewData);
            break;
          case 'manager review completed':
            groupedReviews['hr_review_pending']!.add(reviewData);
            break;
          case 'review completed':
            groupedReviews['completed']!.add(reviewData);
            break;
          default:
            print('DEBUG: Unknown status: $status for employee ${reviewData['employee_id']}');
            break;
        }
      }

      // Add reportees who don't have any reviews yet
      for (final reporteeDoc in reporteesSnapshot.docs) {
        final employeeId = reporteeDoc.id;
        if (!combinedReviewsByEmployee.containsKey(employeeId)) {
          final employeeData = reporteeDoc.data() as Map<String, dynamic>;
          print('DEBUG: Reportee employee data for $employeeId: $employeeData');
          
          String employeeName = 'Unknown Employee';
          if (employeeData['first_name'] != null && employeeData['last_name'] != null) {
            employeeName = '${employeeData['first_name']} ${employeeData['last_name']}';
            print('DEBUG: Reportee using first_name + last_name: $employeeName');
          } else if (employeeData['name'] != null) {
            employeeName = employeeData['name'] as String;
            print('DEBUG: Reportee using name field: $employeeName');
          } else if (employeeData['displayName'] != null) {
            employeeName = employeeData['displayName'] as String;
            print('DEBUG: Reportee using displayName field: $employeeName');
          } else {
            print('DEBUG: Reportee no name fields found for $employeeId, using Unknown Employee');
          }
          
          groupedReviews['self_review_pending']!.add({
            'review_id': null,
            'employee_id': employeeId,
            'employee_name': employeeName,
            'quarter': null,
            'year': null,
            'status': 'No review created',
            'self_review_data': null,
            'manager_review_data': null,
            'hr_review_data': null,
            'self_review_submitted_at': null,
            'manager_review_submitted_at': null,
            'hr_review_submitted_at': null,
            'created_at': null,
            'updated_at': null,
          });
        }
      }

      print('DEBUG: Grouped reviews - Self pending: ${groupedReviews['self_review_pending']!.length}, Manager pending: ${groupedReviews['manager_review_pending']!.length}, HR pending: ${groupedReviews['hr_review_pending']!.length}, Completed: ${groupedReviews['completed']!.length}');

      return groupedReviews;
    } catch (e) {
      print('DEBUG: Error getting reportee reviews by status: $e');
      return {
        'self_review_pending': [],
        'manager_review_pending': [],
        'hr_review_pending': [],
        'completed': [],
      };
    }
  }

  // Debug method to check all reviews in database
  static Future<void> debugAllReviews() async {
    try {
      print('DEBUG: Fetching ALL reviews from performance_reviews collection...');
      final allReviewsSnapshot = await _reviewsCollection.get();
      print('DEBUG: Found ${allReviewsSnapshot.docs.length} total reviews in database');
      
      for (final doc in allReviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('DEBUG: Review ${doc.id} - Employee: ${data['employee_id']}, Status: ${data['status']}, Quarter: ${data['quarter']}, Year: ${data['year']}');
      }
    } catch (e) {
      print('DEBUG: Error fetching all reviews: $e');
    }
  }
}