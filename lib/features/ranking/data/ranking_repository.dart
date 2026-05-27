import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../weekly_test/data/weekly_stats_repository.dart';
import '../domain/models/ranking_entry.dart';

abstract class RankingRepository {
  Future<List<RankingEntry>> fetchWeeklyRanking();
}

class SupabaseRankingRepository implements RankingRepository {
  SupabaseRankingRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<RankingEntry>> fetchWeeklyRanking() async {
    final weekStart = _startOfThisWeek();
    final weekStartStr =
        '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    final currentUserId = _client.auth.currentUser?.id;

    final data = await _client
        .from('weekly_stats')
        .select('user_id, points, profiles(username, avatar_emoji)')
        .eq('week_start', weekStartStr)
        .order('points', ascending: false)
        .limit(50);

    final entries = <RankingEntry>[];
    for (var i = 0; i < data.length; i++) {
      final row = data[i];
      final profile = row['profiles'] as Map<String, dynamic>? ?? {};
      entries.add(RankingEntry(
        userId: row['user_id'] as String,
        username: profile['username'] as String? ?? 'Unknown',
        avatarEmoji: profile['avatar_emoji'] as String? ?? '🙂',
        points: row['points'] as int,
        rank: i + 1,
        isCurrentUser: row['user_id'] == currentUserId,
      ));
    }
    return entries;
  }

  DateTime _startOfThisWeek() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }
}

final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  return SupabaseRankingRepository(ref.watch(supabaseClientProvider));
});

final weeklyRankingProvider = FutureProvider<List<RankingEntry>>((ref) {
  ref.watch(weeklyStatsStreamProvider);
  return ref.watch(rankingRepositoryProvider).fetchWeeklyRanking();
});