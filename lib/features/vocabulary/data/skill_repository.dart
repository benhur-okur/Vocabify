import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cefr_level.dart';
import '../../../core/storage/local_storage.dart';

class _Keys {
  static const level = 'skill.level';
  static const correctStreak = 'skill.correctStreak';
  static const wrongStreak = 'skill.wrongStreak';
}

/// Persists the user's current CEFR level plus the short-term streaks
/// that drive adaptive changes.
abstract class SkillRepository {
  CefrLevel currentLevel();
  int correctStreak();
  int wrongStreak();
  Future<void> saveLevel(CefrLevel level);
  Future<void> saveStreaks({required int correct, required int wrong});
}

class LocalSkillRepository implements SkillRepository {
  LocalSkillRepository(this._storage);
  final LocalStorage _storage;

  @override
  CefrLevel currentLevel() {
    final raw = _storage.getString(_Keys.level);
    return raw == null ? CefrLevel.a2 : CefrLevel.fromName(raw);
  }

  @override
  int correctStreak() => _storage.getInt(_Keys.correctStreak) ?? 0;

  @override
  int wrongStreak() => _storage.getInt(_Keys.wrongStreak) ?? 0;

  @override
  Future<void> saveLevel(CefrLevel level) =>
      _storage.setString(_Keys.level, level.name);

  @override
  Future<void> saveStreaks({required int correct, required int wrong}) async {
    await _storage.setInt(_Keys.correctStreak, correct);
    await _storage.setInt(_Keys.wrongStreak, wrong);
  }
}

final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  return LocalSkillRepository(ref.watch(localStorageProvider));
});