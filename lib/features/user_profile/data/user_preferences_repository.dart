import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/onboarding_controller.dart';
import '../domain/models/user_preferences.dart';

/// Exposes onboarding selections as the app's canonical UserPreferences.
/// A thin adapter — gives the profile screen a clean shape to read without
/// reaching into the onboarding feature directly.
abstract class UserPreferencesRepository {
  UserPreferences current();
}

class OnboardingBackedPreferencesRepository implements UserPreferencesRepository {
  OnboardingBackedPreferencesRepository(this._ref);
  final Ref _ref;

  @override
  UserPreferences current() {
    final s = _ref.read(onboardingControllerProvider);
    return UserPreferences(
      selectedInterestIds: s.selectedInterestIds,
      selectedMovieIds: s.selectedMovieIds,
    );
  }
}

final userPreferencesRepositoryProvider =
    Provider<UserPreferencesRepository>((ref) {
  return OnboardingBackedPreferencesRepository(ref);
});