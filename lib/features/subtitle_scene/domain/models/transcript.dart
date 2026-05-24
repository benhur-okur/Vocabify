import 'package:flutter/foundation.dart';

import 'media_source.dart';
import 'transcript_segment.dart';

/// A full transcript for a title (movie or series episode), with the video
/// source needed to play it. Loaded from assets/transcripts/<id>.json.
@immutable
class Transcript {
  const Transcript({
    required this.movieId,
    required this.movieTitle,
    required this.source,
    required this.segments,
    required this.topicTags,
    String? seriesId,
  }) : seriesId = seriesId ?? movieId;

  final String movieId;

  /// The show/movie that this transcript belongs to. Matches the id used in
  /// MoviePreference. When a transcript is a clip or episode of a series,
  /// seriesId is the series id while movieId is the unique per-clip id.
  /// Defaults to movieId when absent from the JSON (backwards compatible).
  final String seriesId;

  final String movieTitle;
  final MediaSource source;
  final List<TranscriptSegment> segments;
  final List<String> topicTags;

  factory Transcript.fromJson(Map<String, dynamic> j) {
    final movieId = j['movieId'] as String;
    return Transcript(
      movieId: movieId,
      seriesId: j['seriesId'] as String? ?? movieId,
      movieTitle: j['movieTitle'] as String,
      source: MediaSource(youtubeVideoId: j['youtubeVideoId'] as String),
      segments: (j['segments'] as List<dynamic>)
          .map((e) => TranscriptSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      topicTags: (j['topicTags'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}