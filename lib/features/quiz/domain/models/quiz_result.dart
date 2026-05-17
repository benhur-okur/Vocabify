import 'package:flutter/foundation.dart';

@immutable
class QuizResult {
  const QuizResult({
    required this.categoryId,
    required this.correct,
    required this.total,
    required this.durationMs,
    required this.completedAt,
  });

  final String categoryId;
  final int correct;
  final int total;
  final int durationMs;
  final DateTime completedAt;

  double get accuracy => total == 0 ? 0 : correct / total;
}