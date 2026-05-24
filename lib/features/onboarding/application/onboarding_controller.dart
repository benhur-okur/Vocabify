import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/storage_keys.dart';

@immutable
class OnboardingState {
  const OnboardingState({
    required this.isCompleted,
    required this.selectedInterestIds,
    required this.selectedMovieIds,
  });

  final bool isCompleted;
  final Set<String> selectedInterestIds;
  final Set<String> selectedMovieIds;

  OnboardingState copyWith({
    bool? isCompleted,
    Set<String>? selectedInterestIds,
    Set<String>? selectedMovieIds,
  }) =>
      OnboardingState(
        isCompleted: isCompleted ?? this.isCompleted,
        selectedInterestIds: selectedInterestIds ?? this.selectedInterestIds,
        selectedMovieIds: selectedMovieIds ?? this.selectedMovieIds,
      );
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final storage = ref.watch(localStorageProvider);
    return OnboardingState(
      isCompleted: storage.getBool(StorageKeys.onboardingCompleted) ?? false,
      selectedInterestIds:
          (storage.getStringList(StorageKeys.selectedInterests) ?? const [])
              .toSet(),
      selectedMovieIds:
          (storage.getStringList(StorageKeys.selectedMovies) ?? const [])
              .toSet(),
    );
  }

  void toggleInterest(String id) {
    final next = {...state.selectedInterestIds};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedInterestIds: next);
  }

  void toggleMovie(String id) {
    final next = {...state.selectedMovieIds};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedMovieIds: next);
  }

  bool get canProceedFromInterests =>
      state.selectedInterestIds.length >= AppConstants.minInterestsToProceed;

  bool get canFinishOnboarding =>
      state.selectedMovieIds.length >= AppConstants.minMoviesToFinish;

  Future<void> complete() async {
    final storage = ref.read(localStorageProvider);
    await storage.setStringList(
        StorageKeys.selectedInterests, state.selectedInterestIds.toList());
    await storage.setStringList(
        StorageKeys.selectedMovies, state.selectedMovieIds.toList());
    await storage.setBool(StorageKeys.onboardingCompleted, true);

    ref.read(analyticsServiceProvider).track(OnboardingCompleted(
          interestIds: state.selectedInterestIds.toList(),
          movieIds: state.selectedMovieIds.toList(),
        ));

    state = state.copyWith(isCompleted: true);
  }

  /// Persists the current in-memory selections without touching isCompleted.
  /// Used by the edit-preferences screens after onboarding is done.
  Future<void> saveSelections() async {
    final storage = ref.read(localStorageProvider);
    await storage.setStringList(
        StorageKeys.selectedInterests, state.selectedInterestIds.toList());
    await storage.setStringList(
        StorageKeys.selectedMovies, state.selectedMovieIds.toList());
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);