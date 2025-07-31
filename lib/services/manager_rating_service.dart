import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manager_rating_model.dart';

class ManagerRatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'manager_ratings';

  /// Create a new manager rating for an employee
  static Future<String> createManagerRating(ManagerRatingModel rating) async {
    try {
      final docRef = await _firestore.collection(_collection).add(rating.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create manager rating: $e');
    }
  }

  /// Update an existing manager rating
  static Future<void> updateManagerRating(ManagerRatingModel rating) async {
    try {
      await _firestore.collection(_collection).doc(rating.id).update(rating.toJson());
    } catch (e) {
      throw Exception('Failed to update manager rating: $e');
    }
  }

  /// Get manager ratings by employee ID
  static Future<List<ManagerRatingModel>> getManagerRatingsByEmployeeId(String employeeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('employee_id', isEqualTo: employeeId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ManagerRatingModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get manager ratings: $e');
    }
  }

  /// Get manager ratings by manager ID
  static Future<List<ManagerRatingModel>> getManagerRatingsByManagerId(String managerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('manager_id', isEqualTo: managerId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ManagerRatingModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get manager ratings: $e');
    }
  }

  /// Get manager rating for specific employee, quarter, and year
  static Future<ManagerRatingModel?> getManagerRating(
    String employeeId,
    String managerId,
    String quarter,
    int year,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('employee_id', isEqualTo: employeeId)
          .where('manager_id', isEqualTo: managerId)
          .where('quarter', isEqualTo: quarter)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return ManagerRatingModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to get manager rating: $e');
    }
  }

  /// Delete a manager rating
  static Future<void> deleteManagerRating(String ratingId) async {
    try {
      await _firestore.collection(_collection).doc(ratingId).delete();
    } catch (e) {
      throw Exception('Failed to delete manager rating: $e');
    }
  }

  /// Get all manager ratings for a specific quarter and year
  static Future<List<ManagerRatingModel>> getManagerRatingsByPeriod(
    String quarter,
    int year,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('quarter', isEqualTo: quarter)
          .where('year', isEqualTo: year)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ManagerRatingModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get manager ratings by period: $e');
    }
  }

  /// Get average ratings for an employee across all periods
  static Future<Map<String, double>> getEmployeeAverageRatings(String employeeId) async {
    try {
      final ratings = await getManagerRatingsByEmployeeId(employeeId);
      
      if (ratings.isEmpty) {
        return {};
      }

      final Map<String, List<double>> categoryRatings = {};
      
      for (final rating in ratings) {
        rating.kpiRatings.forEach((category, score) {
          categoryRatings.putIfAbsent(category, () => []).add(score);
        });
      }

      final Map<String, double> averages = {};
      categoryRatings.forEach((category, scores) {
        averages[category] = scores.reduce((a, b) => a + b) / scores.length;
      });

      return averages;
    } catch (e) {
      throw Exception('Failed to calculate average ratings: $e');
    }
  }

  /// Get team performance summary for a manager
  static Future<Map<String, dynamic>> getTeamPerformanceSummary(String managerId) async {
    try {
      final ratings = await getManagerRatingsByManagerId(managerId);
      
      if (ratings.isEmpty) {
        return {
          'total_ratings': 0,
          'average_overall_rating': 0.0,
          'top_performers': <String>[],
          'improvement_needed': <String>[],
        };
      }

      final Map<String, List<double>> employeeRatings = {};
      
      for (final rating in ratings) {
        employeeRatings.putIfAbsent(rating.employeeId, () => []).add(rating.overallRating);
      }

      final Map<String, double> employeeAverages = {};
      employeeRatings.forEach((employeeId, ratings) {
        employeeAverages[employeeId] = ratings.reduce((a, b) => a + b) / ratings.length;
      });

      final topPerformers = employeeAverages.entries
          .where((entry) => entry.value >= 4.0)
          .map((entry) => entry.key)
          .toList();

      final improvementNeeded = employeeAverages.entries
          .where((entry) => entry.value < 3.0)
          .map((entry) => entry.key)
          .toList();

      final overallAverage = employeeAverages.values.isEmpty
          ? 0.0
          : employeeAverages.values.reduce((a, b) => a + b) / employeeAverages.values.length;

      return {
        'total_ratings': ratings.length,
        'average_overall_rating': overallAverage,
        'top_performers': topPerformers,
        'improvement_needed': improvementNeeded,
        'employee_averages': employeeAverages,
      };
    } catch (e) {
      throw Exception('Failed to get team performance summary: $e');
    }
  }
}
