import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weekly_test/data/weekly_stats_repository.dart';
import '../domain/models/ranking_entry.dart';
import 'mock/mock_ranking.dart';

abstract class RankingRepository {
  Future<List<RankingEntry>> fetchWeeklyRanking();
}

class MockRankingRepository implements RankingRepository {
  MockRankingRepository(this._statsRepo);
  final WeeklyStatsRepository _statsRepo;

  @override
  Future<List<RankingEntry>> fetchWeeklyRanking() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final myPoints = _statsRepo.currentWeek().pointsEarned;

    final combined = <RankingEntry>[];
    for (final e in mockRanking) {
      if (e.isCurrentUser) {
        combined.add(RankingEntry(
          userId: e.userId,
          username: e.username,
          avatarEmoji: e.avatarEmoji,
          points: myPoints,
          rank: 0,
          isCurrentUser: true,
        ));
      } else {
        combined.add(e);
      }
    }
    combined.sort((a, b) => b.points.compareTo(a.points));

    final ranked = <RankingEntry>[];
    for (var i = 0; i < combined.length; i++) {
      final e = combined[i];
      ranked.add(RankingEntry(
        userId: e.userId,
        username: e.username,
        avatarEmoji: e.avatarEmoji,
        points: e.points,
        rank: i + 1,
        isCurrentUser: e.isCurrentUser,
      ));
    }
    return ranked;
  }
}

final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  return MockRankingRepository(ref.watch(weeklyStatsRepositoryProvider));
});

final weeklyRankingProvider = FutureProvider<List<RankingEntry>>((ref) {
  // Rebuild when weekly stats change so the "You" row stays live.
  ref.watch(weeklyStatsStreamProvider);
  return ref.watch(rankingRepositoryProvider).fetchWeeklyRanking();
});