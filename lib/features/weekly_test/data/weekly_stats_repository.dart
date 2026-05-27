import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

import '../../../core/storage/local_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/models/weekly_stats.dart';

abstract class WeeklyStatsRepository {
  WeeklyStats currentWeek();
  Stream<WeeklyStats> watchCurrentWeek();
  Future<void> recordQuizResult({required int correct, required int total});
  Future<void> recordSceneCompletion();
  Future<void> reset();
}

class LocalWeeklyStatsRepository implements WeeklyStatsRepository {
  LocalWeeklyStatsRepository(this._storage, this._userId) {
    _current = _rolloverIfNeeded(_loadOrInit());
  }

  final LocalStorage _storage;
  final String _userId;
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

  String get _key => '${StorageKeys.weeklyScore}_$_userId';

  WeeklyStats _loadOrInit() {
    final raw = _storage.getString(_key);
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
      _key,
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

/// Wraps [LocalWeeklyStatsRepository] and syncs every write to Supabase.
/// The exposed stream emits only AFTER the sync completes so that
/// [weeklyRankingProvider] never re-fetches before the row is in the DB.
class SupabaseBackedWeeklyStatsRepository implements WeeklyStatsRepository {
  SupabaseBackedWeeklyStatsRepository(this._local, this._client);

  final LocalWeeklyStatsRepository _local;
  final SupabaseClient _client;
  final StreamController<WeeklyStats> _controller =
      StreamController<WeeklyStats>.broadcast();

  String? get _uid => _client.auth.currentUser?.id;

  void dispose() => _controller.close();

  @override
  WeeklyStats currentWeek() => _local.currentWeek();

  @override
  Stream<WeeklyStats> watchCurrentWeek() async* {
    yield _local.currentWeek();
    yield* _controller.stream;
  }

  @override
  Future<void> recordQuizResult({
    required int correct,
    required int total,
  }) async {
    await _local.recordQuizResult(correct: correct, total: total);
    await _sync(_local.currentWeek());
    _controller.add(_local.currentWeek());
  }

  @override
  Future<void> recordSceneCompletion() async {
    await _local.recordSceneCompletion();
    await _sync(_local.currentWeek());
    _controller.add(_local.currentWeek());
  }

  @override
  Future<void> reset() async {
    await _local.reset();
    await _sync(_local.currentWeek());
    _controller.add(_local.currentWeek());
  }

  Future<void> _sync(WeeklyStats s) async {
    final uid = _uid;
    if (uid == null) return;
    final ws = s.weekStart;
    final weekStart =
        '${ws.year}-${ws.month.toString().padLeft(2, '0')}-${ws.day.toString().padLeft(2, '0')}';
    try {
      await _client.from('weekly_stats').upsert({
        'user_id': uid,
        'week_start': weekStart,
        'points': s.pointsEarned,
        'quizzes_completed': s.quizzesCompleted,
        'scenes_completed': s.scenesCompleted,
        'correct_answers': s.correctAnswers,
        'total_answers': s.totalAnswers,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,week_start');
    } catch (e) {
      debugPrint('[WeeklyStats] Supabase sync failed: $e');
    }
  }
}

final weeklyStatsRepositoryProvider = Provider<WeeklyStatsRepository>((ref) {
  final userId = ref.watch(currentUserProvider)?.id ?? 'anonymous';
  final local = LocalWeeklyStatsRepository(ref.watch(localStorageProvider), userId);
  final client = ref.watch(supabaseClientProvider);
  final repo = SupabaseBackedWeeklyStatsRepository(local, client);
  ref.onDispose(repo.dispose);
  return repo;
});

final weeklyStatsStreamProvider = StreamProvider<WeeklyStats>((ref) {
  return ref.watch(weeklyStatsRepositoryProvider).watchCurrentWeek();
});