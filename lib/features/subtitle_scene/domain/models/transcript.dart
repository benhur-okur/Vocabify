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
  });

  final String movieId;
  final String movieTitle;
  final MediaSource source;
  final List<TranscriptSegment> segments;
  final List<String> topicTags; // high-level tags for the whole title

  factory Transcript.fromJson(Map<String, dynamic> j) {
    return Transcript(
      movieId: j['movieId'] as String,
      movieTitle: j['movieTitle'] as String,
      source: MediaSource(youtubeVideoId: j['youtubeVideoId'] as String),
      segments: (j['segments'] as List<dynamic>)
          .map((e) => TranscriptSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      topicTags: (j['topicTags'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}