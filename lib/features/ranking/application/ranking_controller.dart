import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weekly_test/application/weekly_test_controller.dart';
import '../data/ranking_repository.dart';
import '../domain/models/ranking_entry.dart';

final weeklyRankingProvider = FutureProvider<List<RankingEntry>>((ref) async {
  // Rebuild whenever weekly stats change — keeps the "You" row live.
  ref.watch(weeklyStatsStreamProvider);
  return ref.watch(rankingRepositoryProvider).fetchWeeklyRanking();
});