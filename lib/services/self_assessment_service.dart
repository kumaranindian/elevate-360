import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/self_assessment_model.dart';

class SelfAssessmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get self assessment by employee ID and quarter
  static Future<SelfAssessmentModel?> getSelfAssessmentByEmployeeAndQuarter(
    String employeeId, 
    String quarter, 
    int year
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('self_assessments')
          .where('employee_id', isEqualTo: employeeId)
          .where('quarter', isEqualTo: quarter)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return SelfAssessmentModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to load self assessment: $e');
    }
  }

  // Get all self assessments by employee ID
  static Future<List<SelfAssessmentModel>> getSelfAssessmentsByEmployeeId(String employeeId) async {
    try {
      // First attempt with the intended query (requires composite index)
      try {
        final QuerySnapshot snapshot = await _firestore
            .collection('self_assessments')
            .where('employee_id', isEqualTo: employeeId)
            .orderBy('year', descending: true)
            .orderBy('quarter', descending: true)
            .get();
        
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return SelfAssessmentModel.fromJson({...data, 'id': doc.id});
        }).toList();
      } catch (indexError) {
        // If index doesn't exist yet, fall back to basic query and sort in memory
        print('Composite index not ready yet. Falling back to memory sort.');
        print('Please create the index using this link:');
        print(indexError.toString());
        
        final QuerySnapshot snapshot = await _firestore
            .collection('self_assessments')
            .where('employee_id', isEqualTo: employeeId)
            .get();
        
        final assessments = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return SelfAssessmentModel.fromJson({...data, 'id': doc.id});
        }).toList();
        
        // Sort in memory
        assessments.sort((a, b) {
          final yearCompare = b.year.compareTo(a.year); // descending
          if (yearCompare != 0) return yearCompare;
          // Q4 > Q3 > Q2 > Q1
          return b.quarter.compareTo(a.quarter); // descending
        });
        
        return assessments;
      }
    } catch (e) {
      throw Exception('Failed to load employee self assessments: $e');
    }
  }

  // Create new self assessment
  static Future<bool> createSelfAssessment(SelfAssessmentModel assessment) async {
    try {
      final assessmentData = assessment.toJson();
      assessmentData['created_at'] = FieldValue.serverTimestamp();
      assessmentData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('self_assessments').add(assessmentData);
      return true;
    } catch (e) {
      throw Exception('Failed to create self assessment: $e');
    }
  }

  // Update self assessment
  static Future<bool> updateSelfAssessment(SelfAssessmentModel assessment) async {
    try {
      final assessmentData = assessment.toJson();
      assessmentData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('self_assessments')
          .doc(assessment.id)
          .update(assessmentData);

      return true;
    } catch (e) {
      throw Exception('Failed to update self assessment: $e');
    }
  }

  // Submit self assessment (update status to 'awaiting manager review')
  static Future<bool> submitSelfAssessment(String assessmentId) async {
    try {
      await _firestore
          .collection('self_assessments')
          .doc(assessmentId)
          .update({
        'status': 'awaiting manager review',
        'submitted_date': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to submit self assessment: $e');
    }
  }

  // Get self assessments by status
  static Future<List<SelfAssessmentModel>> getSelfAssessmentsByStatus(String status) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('self_assessments')
          .where('status', isEqualTo: status)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SelfAssessmentModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load self assessments by status: $e');
    }
  }

  // Get current quarter based on fiscal year (April to March)
  static String getCurrentQuarter() {
    final now = DateTime.now();
    final month = now.month;
    
    print('Current month: $month'); // Debug print
    
    // Fiscal year quarters:
    // Q1: April (4) - June (6)
    // Q2: July (7) - September (9) 
    // Q3: October (10) - December (12)
    // Q4: January (1) - March (3)
    
    if (month >= 4 && month <= 6) return 'Q1';
    if (month >= 7 && month <= 9) return 'Q2';
    if (month >= 10 && month <= 12) return 'Q3';
    return 'Q4'; // January to March
  }

  // Get current year
  static int getCurrentYear() {
    final year = DateTime.now().year;
    print('Current year detected: $year'); // Debug print
    return year;
  }

  // Check if quarter is current or previous (editable)
  static bool isCurrentQuarter(String quarter, int year) {
    final currentQuarter = getCurrentQuarter();
    final currentYear = getCurrentYear();
    
    // Allow current quarter and previous quarter to be editable
    if (quarter == currentQuarter && year == currentYear) {
      return true; // Current quarter
    }
    
    // Check if it's the previous quarter
    final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
    final currentQuarterIndex = quarters.indexOf(currentQuarter);
    final previousQuarterIndex = (currentQuarterIndex - 1 + 4) % 4; // Handle wrap-around
    final previousQuarter = quarters[previousQuarterIndex];
    
    // Calculate previous quarter year
    int previousQuarterYear = currentYear;
    if (currentQuarterIndex == 0 && previousQuarterIndex == 3) {
      // Q1 -> Q4 of previous year
      previousQuarterYear = currentYear - 1;
    }
    
    if (quarter == previousQuarter && year == previousQuarterYear) {
      return true; // Previous quarter
    }
    
    return false; // All other quarters are read-only
  }

  // Get available quarters for dropdown (fiscal year based)
  static List<String> getAvailableQuarters() {
    final currentYear = getCurrentYear();
    final currentQuarter = getCurrentQuarter();
    // Fiscal year quarters in order: Q1, Q2, Q3, Q4
    final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
    
    print('getAvailableQuarters - Current year: $currentYear, Current quarter: $currentQuarter'); // Debug print
    
    List<String> availableQuarters = [];
    
    // Calculate the last 3 quarters plus current quarter
    List<String> targetQuarters = [];
    
    // Start from current quarter and go back 3 quarters
    int currentQuarterIndex = quarters.indexOf(currentQuarter);
    int currentYearForQuarter = currentYear;
    
    for (int i = 0; i < 4; i++) { // Get 4 quarters total (last 3 + current)
      int quarterIndex = currentQuarterIndex - i;
      int yearForQuarter = currentYearForQuarter;
      
      // Adjust year if quarter index goes negative
      while (quarterIndex < 0) {
        quarterIndex += 4;
        yearForQuarter--;
      }
      
      String quarter = quarters[quarterIndex];
      targetQuarters.add('$quarter $yearForQuarter');
    }
    
    // Add the target quarters to available quarters
    for (String quarter in targetQuarters) {
      availableQuarters.add(quarter);
      print('Added quarter: $quarter'); // Debug print
    }
    
    print('Final available quarters: $availableQuarters'); // Debug print
    return availableQuarters;
  }
} 