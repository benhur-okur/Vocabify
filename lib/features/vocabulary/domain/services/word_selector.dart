import '../../../../core/models/cefr_level.dart';
import '../models/vocabulary_word.dart';

class WordSelector {
  const WordSelector();

  /// Ranks candidate words by how well they match the user's interests and
  /// current level. Returns them highest-score first.
  ///
  /// Scoring (transparent, tweakable):
  ///   + 3 if word.categoryId is in [interestIds]
  ///   + 2 per matching tag between word.tags and [interestIds]
  ///   + (3 - |levelDistance|) capped at 0  (perfect match = +3)
  List<VocabularyWord> rank({
    required List<VocabularyWord> words,
    required Set<String> interestIds,
    required CefrLevel level,
  }) {
    final scored = <MapEntry<VocabularyWord, int>>[];
    for (final w in words) {
      var score = 0;
      if (interestIds.contains(w.categoryId)) score += 3;
      for (final t in w.tags) {
        if (interestIds.contains(t)) score += 2;
      }
      final dist = (w.cefrLevel.rank - level.rank).abs();
      score += (3 - dist).clamp(0, 3);
      scored.add(MapEntry(w, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  /// Picks N words: top of the ranked list. Falls back to whatever we have
  /// if the input is smaller than [count].
  List<VocabularyWord> pick({
    required List<VocabularyWord> words,
    required Set<String> interestIds,
    required CefrLevel level,
    required int count,
  }) {
    final ranked = rank(words: words, interestIds: interestIds, level: level);
    return ranked.take(count).toList();
  }
}