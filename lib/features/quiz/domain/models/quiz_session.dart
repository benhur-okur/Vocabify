import 'package:flutter/foundation.dart';
import 'quiz_question.dart';

@immutable
class QuizSession {
  const QuizSession({
    required this.categoryId,
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.startedAt,
    this.completedAt,
  });

  final String categoryId;
  final List<QuizQuestion> questions;
  final int currentIndex;
  final List<int?> answers;
  final DateTime startedAt;
  final DateTime? completedAt;

  bool get isComplete => completedAt != null;

  int get correctCount {
    var c = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].correctIndex) c++;
    }
    return c;
  }

  QuizSession copyWith({
    int? currentIndex,
    List<int?>? answers,
    DateTime? completedAt,
  }) {
    return QuizSession(
      categoryId: categoryId,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}