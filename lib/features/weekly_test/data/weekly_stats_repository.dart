import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../domain/models/weekly_stats.dart';

abstract class WeeklyStatsRepository {
  WeeklyStats currentWeek();
  Stream<WeeklyStats> watchCurrentWeek();
  Future<void> recordQuizResult({required int correct, required int total});
  Future<void> recordSceneCompletion();
  Future<void> reset();
}

class LocalWeeklyStatsRepository implements WeeklyStatsRepository {
  LocalWeeklyStatsRepository(this._storage) {
    _current = _rolloverIfNeeded(_loadOrInit());
  }

  final LocalStorage _storage;
  late WeeklyStats _current;
  final StreamController<WeeklyStats> _controller =
      StreamController<WeeklyStats>.broadcast();

  @override
  WeeklyStats currentWeek() {
    _current = _rolloverIfNeeded(_current);
    return _current;
  }

  @override
  Stream<WeeklyStats> watchCurrentWeek() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> recordQuizResult({
    required int correct,
    required int total,
  }) async {
    _current = _rolloverIfNeeded(_current).copyWith(
      quizzesCompleted: _current.quizzesCompleted + 1,
      correctAnswers: _current.correctAnswers + correct,
      totalAnswers: _current.totalAnswers + total,
      pointsEarned: _current.pointsEarned + correct * 10,
    );
    await _save(_current);
    _controller.add(_current);
  }

  @override
  Future<void> recordSceneCompletion() async {
    _current = _rolloverIfNeeded(_current).copyWith(
      scenesCompleted: _current.scenesCompleted + 1,
      pointsEarned: _current.pointsEarned + 5,
    );
    await _save(_current);
    _controller.add(_current);
  }

  @override
  Future<void> reset() async {
    _current = WeeklyStats.empty(_startOfThisWeek());
    await _save(_current);
    _controller.add(_current);
  }

  WeeklyStats _loadOrInit() {
    final raw = _storage.getString(StorageKeys.weeklyScore);
    if (raw == null) return WeeklyStats.empty(_startOfThisWeek());
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return WeeklyStats(
        weekStart: DateTime.parse(m['weekStart'] as String),
        quizzesCompleted: m['quizzesCompleted'] as int,
        correctAnswers: m['correctAnswers'] as int,
        totalAnswers: m['totalAnswers'] as int,
        scenesCompleted: m['scenesCompleted'] as int,
        pointsEarned: m['pointsEarned'] as int,
      );
    } catch (_) {
      return WeeklyStats.empty(_startOfThisWeek());
    }
  }

  WeeklyStats _rolloverIfNeeded(WeeklyStats s) {
    final expected = _startOfThisWeek();
    if (s.weekStart.isBefore(expected)) {
      final fresh = WeeklyStats.empty(expected);
      _save(fresh);
      return fresh;
    }
    return s;
  }

  Future<void> _save(WeeklyStats s) async {
    await _storage.setString(
      StorageKeys.weeklyScore,
      jsonEncode({
        'weekStart': s.weekStart.toIso8601String(),
        'quizzesCompleted': s.quizzesCompleted,
        'correctAnswers': s.correctAnswers,
        'totalAnswers': s.totalAnswers,
        'scenesCompleted': s.scenesCompleted,
        'pointsEarned': s.pointsEarned,
      }),
    );
  }

  DateTime _startOfThisWeek() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1;
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromMonday));
  }
}

final weeklyStatsRepositoryProvider = Provider<WeeklyStatsRepository>((ref) {
  return LocalWeeklyStatsRepository(ref.watch(localStorageProvider));
});

final weeklyStatsStreamProvider = StreamProvider<WeeklyStats>((ref) {
  return ref.watch(weeklyStatsRepositoryProvider).watchCurrentWeek();
});