import 'package:flutter/foundation.dart';

@immutable
abstract class AnalyticsEvent {
  const AnalyticsEvent();
  String get name;
  Map<String, Object?> get properties;
}

class OnboardingCompleted extends AnalyticsEvent {
  const OnboardingCompleted({required this.interestIds, required this.movieIds});
  final List<String> interestIds;
  final List<String> movieIds;
  @override
  String get name => 'onboarding_completed';
  @override
  Map<String, Object?> get properties =>
      {'interests': interestIds, 'movies': movieIds};
}

class QuizAnswered extends AnalyticsEvent {
  const QuizAnswered({
    required this.categoryId,
    required this.wordId,
    required this.isCorrect,
    required this.timeToAnswerMs,
  });
  final String categoryId;
  final String wordId;
  final bool isCorrect;
  final int timeToAnswerMs;
  @override
  String get name => 'quiz_answered';
  @override
  Map<String, Object?> get properties => {
        'categoryId': categoryId,
        'wordId': wordId,
        'correct': isCorrect,
        'timeMs': timeToAnswerMs,
      };
}

class QuizCompleted extends AnalyticsEvent {
  const QuizCompleted({
    required this.categoryId,
    required this.correct,
    required this.total,
    required this.durationMs,
  });
  final String categoryId;
  final int correct;
  final int total;
  final int durationMs;
  @override
  String get name => 'quiz_completed';
  @override
  Map<String, Object?> get properties => {
        'categoryId': categoryId,
        'correct': correct,
        'total': total,
        'durationMs': durationMs,
      };
}

class SceneViewed extends AnalyticsEvent {
  const SceneViewed({required this.sceneId, required this.focusWordId});
  final String sceneId;
  final String focusWordId;
  @override
  String get name => 'scene_viewed';
  @override
  Map<String, Object?> get properties =>
      {'sceneId': sceneId, 'focusWordId': focusWordId};
}

class WordMarkedKnown extends AnalyticsEvent {
  const WordMarkedKnown({required this.wordId, required this.source});
  final String wordId;
  final String source;
  @override
  String get name => 'word_marked_known';
  @override
  Map<String, Object?> get properties =>
      {'wordId': wordId, 'source': source};
}