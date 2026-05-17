import 'package:flutter/foundation.dart';

/// One line/segment of a transcript, typically 3–10 seconds of speech.
@immutable
class TranscriptSegment {
  const TranscriptSegment({
    required this.startMs,
    required this.endMs,
    required this.text,
    required this.lemmas,
  });

  final int startMs;
  final int endMs;
  final String text;        // original (possibly cased, punctuated) line
  final List<String> lemmas; // precomputed lowercased lemmas

  int get durationMs => endMs - startMs;

  factory TranscriptSegment.fromJson(Map<String, dynamic> j) {
    return TranscriptSegment(
      startMs: j['startMs'] as int,
      endMs: j['endMs'] as int,
      text: j['text'] as String,
      lemmas: (j['lemmas'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'startMs': startMs,
        'endMs': endMs,
        'text': text,
        'lemmas': lemmas,
      };
}