import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/models/app_user.dart';

abstract class AuthRepository {
  User? get currentAuthUser;
  Future<AppUser?> fetchProfile(String userId);
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String username,
  });
  Future<AppUser> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);
  final SupabaseClient _client;

  @override
  User? get currentAuthUser => _client.auth.currentUser;

  @override
  Future<AppUser?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select('id, username, avatar_emoji, onboarding_completed')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    final email = _client.auth.currentUser?.email ?? '';
    return AppUser.fromMap(data, email);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    if (response.user == null) throw Exception('Sign up failed');
    // Wait for the DB trigger to create the profile row.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final profile = await fetchProfile(response.user!.id);
    return profile ??
        AppUser(
          id: response.user!.id,
          email: email,
          username: username,
          avatarEmoji: '🙂',
          onboardingCompleted: false,
        );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Sign in failed');
    final profile = await fetchProfile(response.user!.id);
    if (profile == null) throw Exception('Profile not found');
    return profile;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});
