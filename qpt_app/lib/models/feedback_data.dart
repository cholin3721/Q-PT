// lib/models/feedback_data.dart

class FeedbackMetrics {
  final int workoutConsistency;
  final int nutritionScore;
  final int progressRate;

  FeedbackMetrics({
    required this.workoutConsistency,
    required this.nutritionScore,
    required this.progressRate,
  });
}

class FeedbackHistory {
  final int id;
  final String type;
  final DateTime date;
  final String analysis;
  final List<String> recommendations;
  final FeedbackMetrics metrics;

  FeedbackHistory({
    required this.id,
    required this.type,
    required this.date,
    required this.analysis,
    required this.recommendations,
    required this.metrics,
  });
}