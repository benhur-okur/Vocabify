import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/onboarding_controller.dart';
import '../../weekly_test/data/weekly_stats_repository.dart';
import '../domain/models/learning_profile.dart';
import '../domain/models/user_preferences.dart';

final userPreferencesProvider = Provider<UserPreferences>((ref) {
  final s = ref.watch(onboardingControllerProvider);
  return UserPreferences(
    selectedInterestIds: s.selectedInterestIds,
    selectedMovieIds: s.selectedMovieIds,
  );
});

final learningProfileProvider = Provider<LearningProfile>((ref) {
  final statsAsync = ref.watch(weeklyStatsStreamProvider);
  return statsAsync.when(
    data: (s) => LearningProfile(
      totalPoints: s.pointsEarned,
      totalQuizzes: s.quizzesCompleted,
      totalScenesViewed: s.scenesCompleted,
      overallAccuracy: s.accuracy,
      streakDays: 0,
    ),
    loading: () => const LearningProfile(
      totalPoints: 0,
      totalQuizzes: 0,
      totalScenesViewed: 0,
      overallAccuracy: 0,
      streakDays: 0,
    ),
    error: (_, __) => const LearningProfile(
      totalPoints: 0,
      totalQuizzes: 0,
      totalScenesViewed: 0,
      overallAccuracy: 0,
      streakDays: 0,
    ),
  );
});