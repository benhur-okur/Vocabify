import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../vocabulary/application/skill_tracker.dart';
import '../../vocabulary/data/vocabulary_repository.dart';
import '../../vocabulary/domain/models/vocabulary_word.dart';
import '../../vocabulary/domain/services/word_selector.dart';
import '../../weekly_test/data/weekly_stats_repository.dart';
import '../domain/models/quiz_session.dart';
import '../domain/services/quiz_generator.dart';

class QuizSessionController
    extends AutoDisposeFamilyAsyncNotifier<QuizSession, String> {
  DateTime? _questionStartedAt;

  @override
  Future<QuizSession> build(String categoryId) async {
    final words = await _selectWords(categoryId);
    final questions = QuizGenerator().generate(words: words);
    _questionStartedAt = DateTime.now();
    return QuizSession(
      categoryId: categoryId,
      questions: questions,
      currentIndex: 0,
      answers: List<int?>.filled(questions.length, null),
      startedAt: DateTime.now(),
    );
  }

  Future<List<VocabularyWord>> _selectWords(String categoryId) async {
    // Pull words for the chosen category, then enrich the pool by also
    // pulling words from the user's interests so the selector has
    // something to reorder on. Falls back to category-only if needed.
    final repo = ref.read(vocabularyRepositoryProvider);
    final categoryWords = await repo.fetchWordsForCategory(categoryId);

    final interests =
        ref.read(onboardingControllerProvider).selectedInterestIds;
    final level = ref.read(skillTrackerProvider).level;

    if (categoryWords.length >= 4) {
      // Prefer category words — that's what the user just picked.
      // Re-rank them by level proximity.
      return const WordSelector().pick(
        words: categoryWords,
        interestIds: interests,
        level: level,
        count: 10,
      );
    }

    // Fallback: use whatever we have, don't crash.
    return categoryWords;
  }

  void answer(int optionIndex) {
    final current = state.valueOrNull;
    if (current == null || current.isComplete) return;

    final now = DateTime.now();
    final timeMs = now.difference(_questionStartedAt ?? now).inMilliseconds;

    final updatedAnswers = [...current.answers];
    updatedAnswers[current.currentIndex] = optionIndex;

    final q = current.questions[current.currentIndex];
    final isCorrect = optionIndex == q.correctIndex;

    ref.read(analyticsServiceProvider).track(QuizAnswered(
          categoryId: current.categoryId,
          wordId: q.wordId,
          isCorrect: isCorrect,
          timeToAnswerMs: timeMs,
        ));
    // Adaptive signal — updates per-answer, not per-quiz.
    ref.read(skillTrackerProvider.notifier).registerAnswer(
          correct: isCorrect,
          responseMs: timeMs,
        );
    final isLast = current.currentIndex == current.questions.length - 1;
    if (isLast) {
      final completed = current.copyWith(
        answers: updatedAnswers,
        completedAt: now,
      );
      _finalize(completed);
      state = AsyncValue.data(completed);
    } else {
      _questionStartedAt = now;
      state = AsyncValue.data(current.copyWith(
        answers: updatedAnswers,
        currentIndex: current.currentIndex + 1,
      ));
    }
  }

  void _finalize(QuizSession completed) {
    final correct = completed.correctCount;
    final total = completed.questions.length;
    final durationMs =
        completed.completedAt!.difference(completed.startedAt).inMilliseconds;

    ref
        .read(weeklyStatsRepositoryProvider)
        .recordQuizResult(correct: correct, total: total);

    ref.read(analyticsServiceProvider).track(QuizCompleted(
          categoryId: completed.categoryId,
          correct: correct,
          total: total,
          durationMs: durationMs,
        ));
  }
}

final quizSessionControllerProvider = AsyncNotifierProvider.autoDispose
    .family<QuizSessionController, QuizSession, String>(
  QuizSessionController.new,
);