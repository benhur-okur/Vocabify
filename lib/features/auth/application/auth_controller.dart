import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../vocabulary/application/skill_tracker.dart';
import '../data/auth_repository.dart';
import '../domain/models/app_user.dart';

/// Resolves the current user on startup, null when not authenticated.
class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final repo = ref.read(authRepositoryProvider);
    final user = repo.currentAuthUser;
    if (user == null) return null;
    final profile = await repo.fetchProfile(user.id);
    _syncProfileData(user.id);
    return profile;
  }

  /// Pushes local level + interests to Supabase on each startup so public
  /// profiles always reflect up-to-date data, even for pre-existing accounts.
  Future<void> _syncProfileData(String userId) async {
    try {
      final level = ref.read(skillTrackerProvider).level;
      final interests =
          ref.read(localStorageProvider).getStringList(StorageKeys.selectedInterests) ??
              const [];
      await ref.read(supabaseClientProvider).from('profiles').update({
        'cefr_level': level.name,
        'interests': interests,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('[AuthSync] profile data sync failed: $e');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            username: username,
          ),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  /// Called by [OnboardingController] after the user finishes onboarding.
  /// Updates the in-memory user immediately so the router re-evaluates
  /// without waiting for a full re-fetch.
  void markOnboardingComplete() {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(onboardingCompleted: true));
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

/// Synchronous check backed by the live Supabase session.
/// Safe to read in GoRouter redirect (no async).
final isAuthenticatedProvider = Provider<bool>((ref) {
  ref.watch(authControllerProvider);
  return Supabase.instance.client.auth.currentSession != null;
});

/// The current user — non-null only when authenticated.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});
