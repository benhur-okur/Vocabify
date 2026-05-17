import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/weekly_stats_repository.dart';
import '../domain/models/weekly_stats.dart';

/// Thin re-export for screens that only need the stream.
/// Kept in application/ so presentation never imports data/ directly.
final weeklyStatsStreamProvider = StreamProvider<WeeklyStats>(
  (ref) => ref.watch(weeklyStatsRepositoryProvider).watchCurrentWeek(),
);