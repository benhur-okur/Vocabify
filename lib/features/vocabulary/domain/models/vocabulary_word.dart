import 'package:flutter/foundation.dart';

import '../../../../core/models/cefr_level.dart';

/// Legacy coarse difficulty. Kept for backwards compatibility with any
/// earlier code, but new selection logic uses [cefrLevel].
enum WordDifficulty { easy, medium, hard }

@immutable
class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.term,
    required this.meaning,
    required this.exampleSentence,
    required this.categoryId,
    required this.difficulty,
    this.cefrLevel = CefrLevel.a2,
    this.tags = const [],
  });

  final String id;
  final String term;
  final String meaning;
  final String exampleSentence;
  final String categoryId;
  final WordDifficulty difficulty;
  final CefrLevel cefrLevel;

  /// Free-form topic tags (e.g. ['airport', 'travel']) used by the scene
  /// matcher to connect vocabulary → scenes.
  final List<String> tags;
}