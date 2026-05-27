import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cefr_level.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/skill_repository.dart';

/// A windowed sample of a recent answer.
class AnswerSample {
  const AnswerSample({
    required this.correct,
    required this.responseMs,
    required this.levelAtAsk,
    required this.timestampMs,
  });

  final bool correct;
  final int responseMs;
  final CefrLevel levelAtAsk;
  final int timestampMs;
}

class SkillState {
  const SkillState({
    required this.level,
    required this.emaAccuracy,
    required this.recent,
  });
  final CefrLevel level;
  /// Exponentially-weighted moving accuracy in [0, 1].
  final double emaAccuracy;
  /// Rolling window of recent answers (max 30).
  final List<AnswerSample> recent;

  SkillState copyWith({
    CefrLevel? level,
    double? emaAccuracy,
    List<AnswerSample>? recent,
  }) =>
      SkillState(
        level: level ?? this.level,
        emaAccuracy: emaAccuracy ?? this.emaAccuracy,
        recent: recent ?? this.recent,
      );
}

/// A more serious adaptive model than a pure streak counter:
///
/// - Per-answer EMA (alpha=0.25) of accuracy smooths noise.
/// - Response latency contributes to "mastery score": fast+correct > slow+correct.
/// - Promotion requires emaAccuracy ≥ 0.85 AND ≥ 8 samples at current level.
/// - Demotion requires emaAccuracy ≤ 0.45 AND ≥ 6 samples at current level.
/// - Hysteresis: after a level change, samples at the new level must accumulate
///   before another change is allowed — prevents flapping.
/// - Window: last 30 answers, FIFO.
///
/// The EMA history is not persisted across launches (only current level + a
/// "samples since level change" counter). That's intentional — restoring a
/// fragile in-memory EMA from disk would encourage more false confidence.
class SkillTracker extends Notifier<SkillState> {
  static const double _alpha = 0.25;
  static const double _promoteAccuracy = 0.85;
  static const double _demoteAccuracy = 0.45;
  static const int _minSamplesPromote = 8;
  static const int _minSamplesDemote = 6;
  static const int _windowSize = 30;

  @override
  SkillState build() {
    final repo = ref.watch(skillRepositoryProvider);
    return SkillState(
      level: repo.currentLevel(),
      emaAccuracy: 0.6, // neutral starting prior
      recent: const [],
    );
  }

  Future<void> registerAnswer({
    required bool correct,
    int responseMs = 0,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final sample = AnswerSample(
      correct: correct,
      responseMs: responseMs,
      levelAtAsk: state.level,
      timestampMs: now,
    );

    // Update EMA: correct=1.0, wrong=0.0.
    final x = correct ? 1.0 : 0.0;
    final newEma = _alpha * x + (1 - _alpha) * state.emaAccuracy;

    // Append to window.
    final recent = [...state.recent, sample];
    if (recent.length > _windowSize) {
      recent.removeRange(0, recent.length - _windowSize);
    }

    // Compute samples at current level.
    final samplesAtLevel =
        recent.where((s) => s.levelAtAsk == state.level).length;

    CefrLevel nextLevel = state.level;
    if (newEma >= _promoteAccuracy &&
        samplesAtLevel >= _minSamplesPromote &&
        state.level != CefrLevel.c2) {
      nextLevel = state.level.next;
    } else if (newEma <= _demoteAccuracy &&
        samplesAtLevel >= _minSamplesDemote &&
        state.level != CefrLevel.a1) {
      nextLevel = state.level.previous;
    }

    // On level change, reset samples-at-level effectively by dropping old
    // window entries — easier: keep them; hysteresis from _minSamples handles it.
    var nextEma = newEma;
    if (nextLevel != state.level) {
      // Snap EMA to neutral on level change so we don't immediately flip back.
      nextEma = 0.6;
    }

    final repo = ref.read(skillRepositoryProvider);
    if (nextLevel != state.level) {
      await repo.saveLevel(nextLevel);
      _syncLevel(nextLevel);
    }

    state = state.copyWith(
      level: nextLevel,
      emaAccuracy: nextEma,
      recent: recent,
    );
  }

  Future<void> _syncLevel(CefrLevel level) async {
    final uid =
        ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) return;
    try {
      await ref
          .read(supabaseClientProvider)
          .from('profiles')
          .update({'cefr_level': level.name}).eq('id', uid);
    } catch (e) {
      debugPrint('[SkillSync] level sync failed: $e');
    }
  }

  /// Proficiency score in [0, 1] = mastery at current level.
  /// Useful for UI hints ("almost ready to advance").
  double get proficiencyAtLevel {
    final atLevel =
        state.recent.where((s) => s.levelAtAsk == state.level).toList();
    if (atLevel.isEmpty) return 0.5;
    final acc = atLevel.where((s) => s.correct).length / atLevel.length;
    // Latency bonus: faster average → slightly higher score, capped.
    final avgMs = atLevel.map((s) => s.responseMs).fold<int>(0, (a, b) => a + b) /
        atLevel.length;
    final latencyFactor = avgMs <= 0
        ? 1.0
        : (1.0 - math.min(avgMs, 8000) / 16000).clamp(0.5, 1.0);
    return (acc * 0.8 + latencyFactor * 0.2).clamp(0.0, 1.0);
  }
}

final skillTrackerProvider =
    NotifierProvider<SkillTracker, SkillState>(SkillTracker.new);