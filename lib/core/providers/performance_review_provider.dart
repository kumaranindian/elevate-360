import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/performance_review_model.dart';
import '../../services/performance_review_service.dart';

// Provider for employee's own reviews
final employeeReviewsProvider = StreamProvider.family<List<PerformanceReviewModel>, String>(
  (ref, employeeId) => PerformanceReviewService.streamReviewsByEmployeeId(employeeId),
);

// Provider for manager's reportee reviews
final reporteeReviewsProvider = StreamProvider.family<List<PerformanceReviewModel>, String>(
  (ref, managerId) => PerformanceReviewService.streamReporteeReviews(managerId),
);

// Provider for HR reviews
final hrReviewsProvider = StreamProvider<List<PerformanceReviewModel>>(
  (ref) => PerformanceReviewService.streamReviewsForHR(),
);

// Provider for a single review
final reviewProvider = FutureProvider.family<PerformanceReviewModel?, String>(
  (ref, reviewId) => PerformanceReviewService.getReviewById(reviewId),
);

// Provider for review submission state
final reviewSubmissionProvider = StateProvider<AsyncValue<void>>((ref) => const AsyncValue.data(null));

// Provider for selected review
final selectedReviewProvider = StateProvider<PerformanceReviewModel?>((ref) => null);

// Provider for review filter
final reviewFilterProvider = StateProvider<String>((ref) => 'all');