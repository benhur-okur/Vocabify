import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/quiz_result.dart';

/// Persists completed quiz results. For MVP: in-memory (rebuilt on app restart).
/// We deliberately do NOT persist results here yet — the single source of
/// truth for cross-feature stats is `weekly_stats_repository`. This repo
/// keeps a short session history for the profile screen's "recent quizzes".
abstract class QuizRepository {
  void recordResult(QuizResult result);
  List<QuizResult> recentResults({int limit = 20});
}

class InMemoryQuizRepository implements QuizRepository {
  final List<QuizResult> _results = [];

  @override
  void recordResult(QuizResult result) {
    _results.add(result);
    if (_results.length > 100) _results.removeAt(0);
  }

  @override
  List<QuizResult> recentResults({int limit = 20}) {
    final reversed = _results.reversed.toList();
    return reversed.take(limit).toList();
  }
}

final quizRepositoryProvider =
    Provider<QuizRepository>((ref) => InMemoryQuizRepository());