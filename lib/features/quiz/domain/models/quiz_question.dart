import 'package:flutter/foundation.dart';

@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.wordId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String wordId;
  final String prompt;
  final List<String> options;
  final int correctIndex;
}