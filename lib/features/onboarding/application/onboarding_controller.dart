import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/application/auth_controller.dart';

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
    final user = ref.watch(currentUserProvider);
    final storage = ref.watch(localStorageProvider);

    // isCompleted comes from the user's Supabase profile — always correct
    // regardless of which device or which account is active.
    final isCompleted = user?.onboardingCompleted ?? false;

    // Interests and movies are cached locally, scoped by user ID so that
    // switching accounts never leaks one user's selections to another.
    final uid = user?.id ?? 'anonymous';
    final interestsKey = '${StorageKeys.selectedInterests}_$uid';
    final moviesKey = '${StorageKeys.selectedMovies}_$uid';

    return OnboardingState(
      isCompleted: isCompleted,
      selectedInterestIds:
          (storage.getStringList(interestsKey) ?? const []).toSet(),
      selectedMovieIds:
          (storage.getStringList(moviesKey) ?? const []).toSet(),
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
    final user = ref.read(currentUserProvider);
    final uid = user?.id ?? 'anonymous';
    final interests = state.selectedInterestIds.toList();
    final movies = state.selectedMovieIds.toList();

    // Persist selections locally (user-scoped).
    final storage = ref.read(localStorageProvider);
    await storage.setStringList('${StorageKeys.selectedInterests}_$uid', interests);
    await storage.setStringList('${StorageKeys.selectedMovies}_$uid', movies);

    ref.read(analyticsServiceProvider).track(OnboardingCompleted(
          interestIds: interests,
          movieIds: movies,
        ));

    // Mark complete in Supabase and sync interests in one round-trip.
    await _syncCompletion(uid: uid, interests: interests);

    // Update the in-memory AppUser so the router re-evaluates immediately
    // without waiting for a full auth re-fetch.
    ref.read(authControllerProvider.notifier).markOnboardingComplete();
  }

  /// Persists the current in-memory selections without touching isCompleted.
  /// Used by the edit-preferences screens after onboarding is done.
  Future<void> saveSelections() async {
    final user = ref.read(currentUserProvider);
    final uid = user?.id ?? 'anonymous';
    final interests = state.selectedInterestIds.toList();

    final storage = ref.read(localStorageProvider);
    await storage.setStringList('${StorageKeys.selectedInterests}_$uid', interests);
    await storage.setStringList(
        '${StorageKeys.selectedMovies}_$uid', state.selectedMovieIds.toList());

    _syncInterests(uid: uid, interests: interests);
  }

  Future<void> _syncCompletion({
    required String uid,
    required List<String> interests,
  }) async {
    if (uid == 'anonymous') return;
    try {
      await ref.read(supabaseClientProvider).from('profiles').update({
        'onboarding_completed': true,
        'interests': interests,
      }).eq('id', uid);
    } catch (e) {
      debugPrint('[OnboardingSync] completion sync failed: $e');
    }
  }

  Future<void> _syncInterests({
    required String uid,
    required List<String> interests,
  }) async {
    if (uid == 'anonymous') return;
    try {
      await ref
          .read(supabaseClientProvider)
          .from('profiles')
          .update({'interests': interests}).eq('id', uid);
    } catch (e) {
      debugPrint('[OnboardingSync] interests sync failed: $e');
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
