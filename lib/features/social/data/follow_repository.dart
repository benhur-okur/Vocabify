import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/models/public_profile.dart';

class FollowRepository {
  FollowRepository(this._client);
  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<PublicProfile> fetchPublicProfile(String userId) async {
    final currentUid = _uid;

    final profile = await _client
        .from('profiles')
        .select('id, username, avatar_emoji, cefr_level, interests')
        .eq('id', userId)
        .single();

    final followers = await _client
        .from('follows')
        .select('follower_id')
        .eq('following_id', userId);

    final following = await _client
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId);

    final stats = await _client
        .from('weekly_stats')
        .select('points, quizzes_completed, scenes_completed')
        .eq('user_id', userId)
        .eq('week_start', _currentWeekStart())
        .maybeSingle();

    bool isFollowing = false;
    if (currentUid != null && currentUid != userId) {
      final row = await _client
          .from('follows')
          .select()
          .eq('follower_id', currentUid)
          .eq('following_id', userId)
          .maybeSingle();
      isFollowing = row != null;
    }

    return PublicProfile(
      id: userId,
      username: profile['username'] as String,
      avatarEmoji: profile['avatar_emoji'] as String? ?? '🙂',
      followersCount: (followers as List).length,
      followingCount: (following as List).length,
      isFollowing: isFollowing,
      cefrLevel: profile['cefr_level'] as String? ?? 'A1',
      interests: (profile['interests'] as List?)?.cast<String>() ?? const [],
      weeklyPoints: stats?['points'] as int?,
      weeklyQuizzes: stats?['quizzes_completed'] as int?,
      weeklyScenes: stats?['scenes_completed'] as int?,
    );
  }

  Future<void> follow(String userId) async {
    final uid = _uid;
    if (uid == null || uid == userId) return;
    await _client.from('follows').insert({
      'follower_id': uid,
      'following_id': userId,
    });
  }

  Future<void> unfollow(String userId) async {
    final uid = _uid;
    if (uid == null) return;
    await _client
        .from('follows')
        .delete()
        .eq('follower_id', uid)
        .eq('following_id', userId);
  }

  Future<List<PublicProfile>> fetchFollowing(String userId) async {
    final currentUid = _uid;

    final rows = await _client
        .from('follows')
        .select(
          'following_id, profiles!follows_following_id_fkey(id, username, avatar_emoji)',
        )
        .eq('follower_id', userId);

    Set<String> alreadyFollowing = {};
    if (currentUid != null) {
      final myFollows = await _client
          .from('follows')
          .select('following_id')
          .eq('follower_id', currentUid);
      alreadyFollowing =
          (myFollows as List).map((r) => r['following_id'] as String).toSet();
    }

    return (rows as List).map<PublicProfile>((r) {
      final p = r['profiles'] as Map<String, dynamic>;
      final fid = r['following_id'] as String;
      return PublicProfile(
        id: fid,
        username: p['username'] as String,
        avatarEmoji: p['avatar_emoji'] as String? ?? '🙂',
        followersCount: 0,
        followingCount: 0,
        isFollowing: alreadyFollowing.contains(fid),
        cefrLevel: 'A1',
        interests: const [],
      );
    }).toList();
  }

  String _currentWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final d = DateTime(monday.year, monday.month, monday.day);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

final followRepositoryProvider = Provider<FollowRepository>(
  (ref) => FollowRepository(ref.watch(supabaseClientProvider)),
);

final publicProfileProvider =
    FutureProvider.family<PublicProfile, String>((ref, userId) {
  return ref.watch(followRepositoryProvider).fetchPublicProfile(userId);
});

final followingListProvider =
    FutureProvider.family<List<PublicProfile>, String>((ref, userId) {
  return ref.watch(followRepositoryProvider).fetchFollowing(userId);
});
