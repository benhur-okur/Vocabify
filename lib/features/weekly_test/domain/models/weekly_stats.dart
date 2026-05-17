import 'package:flutter/foundation.dart';

@immutable
class WeeklyStats {
  const WeeklyStats({
    required this.weekStart,
    required this.quizzesCompleted,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.scenesCompleted,
    required this.pointsEarned,
  });

  final DateTime weekStart;
  final int quizzesCompleted;
  final int correctAnswers;
  final int totalAnswers;
  final int scenesCompleted;
  final int pointsEarned;

  double get accuracy =>
      totalAnswers == 0 ? 0 : correctAnswers / totalAnswers;

  WeeklyStats copyWith({
    int? quizzesCompleted,
    int? correctAnswers,
    int? totalAnswers,
    int? scenesCompleted,
    int? pointsEarned,
  }) =>
      WeeklyStats(
        weekStart: weekStart,
        quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        totalAnswers: totalAnswers ?? this.totalAnswers,
        scenesCompleted: scenesCompleted ?? this.scenesCompleted,
        pointsEarned: pointsEarned ?? this.pointsEarned,
      );

  static WeeklyStats empty(DateTime weekStart) => WeeklyStats(
        weekStart: weekStart,
        quizzesCompleted: 0,
        correctAnswers: 0,
        totalAnswers: 0,
        scenesCompleted: 0,
        pointsEarned: 0,
      );
}