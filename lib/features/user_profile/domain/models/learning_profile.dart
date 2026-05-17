import 'package:flutter/foundation.dart';

@immutable
class LearningProfile {
  const LearningProfile({
    required this.totalPoints,
    required this.totalQuizzes,
    required this.totalScenesViewed,
    required this.overallAccuracy,
    required this.streakDays,
  });

  final int totalPoints;
  final int totalQuizzes;
  final int totalScenesViewed;
  final double overallAccuracy;
  final int streakDays;
}