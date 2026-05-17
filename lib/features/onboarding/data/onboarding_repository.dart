import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/interest_category.dart';
import '../domain/models/movie_preference.dart';

/// Supplies onboarding catalog data (interests, movies). Persistence of
/// the *user's selections* lives in OnboardingController (which uses
/// LocalStorage) — this repository is a source of what's *offerable*.
abstract class OnboardingRepository {
  Future<List<InterestCategory>> fetchInterests();
  Future<List<MoviePreference>> fetchMoviePreferences();
}

class MockOnboardingRepository implements OnboardingRepository {
  @override
  Future<List<InterestCategory>> fetchInterests() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return onboardingInterests;
  }

  @override
  Future<List<MoviePreference>> fetchMoviePreferences() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return mockMoviePreferences;
  }
}

final onboardingRepositoryProvider =
    Provider<OnboardingRepository>((ref) => MockOnboardingRepository());