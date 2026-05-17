import 'package:flutter/foundation.dart';
import 'media_source.dart';
import 'scene_word.dart';

/// A playable scene derived from a transcript segment. This is what the UI
/// renders: a video window [startMs, endMs] with a focus word + subtitle.
@immutable
class SubtitleScene {
  const SubtitleScene({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.source,
    required this.subtitle,
    required this.focusWord,
    required this.startMs,
    required this.endMs,
    required this.timestampLabel,
    this.matchedWordIds = const [],
    this.topicTags = const [],
  });

  final String id;
  final String movieId;
  final String movieTitle;
  final MediaSource source;
  final String subtitle;
  final SceneWord focusWord;
  final int startMs;
  final int endMs;
  final String timestampLabel;

  /// Vocabulary word IDs the matcher found in this scene's subtitle.
  /// Populated at runtime by the matching pipeline (no manual tagging).
  final List<String> matchedWordIds;

  /// Topic tags (e.g. ['travel', 'airport']) inherited from the title.
  final List<String> topicTags;

  int get durationMs => endMs - startMs;
  int get durationSeconds => (durationMs / 1000).round().clamp(1, 60);
}