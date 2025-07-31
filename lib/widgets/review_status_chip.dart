import 'package:flutter/material.dart';
import '../models/performance_review_model.dart';


class ReviewStatusChip extends StatelessWidget {
  final PerformanceReviewModel review;

  const ReviewStatusChip({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: review.getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: review.getStatusColor(),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            color: review.getStatusColor(),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            review.statusDisplayText,
            style: TextStyle(
              color: review.getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (review.status) {
      case PerformanceReviewModel.STATUS_AWAITING_SELF_REVIEW:
        return Icons.pending;
      case PerformanceReviewModel.STATUS_SELF_REVIEW_COMPLETED:
        return Icons.person;
      case PerformanceReviewModel.STATUS_MANAGER_REVIEW_COMPLETED:
        return Icons.supervisor_account;
      case PerformanceReviewModel.STATUS_REVIEW_COMPLETED:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}