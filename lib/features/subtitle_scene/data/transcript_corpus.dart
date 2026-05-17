import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/transcript.dart';
import '../domain/models/transcript_segment.dart';

/// A posting: which transcript, which segment, which position in that segment.
class Posting {
  const Posting(this.movieId, this.segmentIndex, this.position);
  final String movieId;
  final int segmentIndex;
  final int position;
}

/// Loads all transcripts under assets/transcripts/ and builds an inverted
/// index from lemma → list of postings. This is the core data structure
/// that makes subtitle search tractable for thousands of segments.
class TranscriptCorpus {
  TranscriptCorpus._(this.transcripts, this._index);

  final Map<String, Transcript> transcripts; // by movieId
  final Map<String, List<Posting>> _index;

  /// Looks up all postings for a single lemma. Constant time.
  List<Posting> postingsFor(String lemma) => _index[lemma] ?? const [];

  /// All segments for one movie (used when user filters to a specific title).
  List<TranscriptSegment>? segmentsFor(String movieId) =>
      transcripts[movieId]?.segments;

  /// Number of segments in the corpus — used for idf.
  int get totalSegments =>
      transcripts.values.fold(0, (n, t) => n + t.segments.length);

  /// Document frequency for a lemma — how many segments contain it.
  int documentFrequency(String lemma) =>
      _index[lemma]?.map((p) => '${p.movieId}:${p.segmentIndex}').toSet().length ?? 0;

  static Future<TranscriptCorpus> load(List<String> manifest) async {
    final transcripts = <String, Transcript>{};
    final index = <String, List<Posting>>{};

    for (final assetPath in manifest) {
      try {
        final raw = await rootBundle.loadString(assetPath);
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final t = Transcript.fromJson(json);
        transcripts[t.movieId] = t;

        for (var si = 0; si < t.segments.length; si++) {
          final seg = t.segments[si];
          for (var pi = 0; pi < seg.lemmas.length; pi++) {
            final lemma = seg.lemmas[pi];
            (index[lemma] ??= []).add(Posting(t.movieId, si, pi));
          }
        }
      } catch (e) {
        // Silently skip malformed transcripts — the app must still run.
        // ignore: avoid_print
        print('[TranscriptCorpus] failed to load $assetPath: $e');
      }
    }
    return TranscriptCorpus._(transcripts, index);
  }
}

/// The manifest lists every transcript asset that ships with the app.
/// Keep this in sync when you add new ones via the ingestion CLI.
const transcriptManifest = <String>[
  'assets/transcripts/demo_travel_vlog.json',
  'assets/transcripts/demo_tech_talk.json',
];

final transcriptCorpusProvider = FutureProvider<TranscriptCorpus>((ref) {
  return TranscriptCorpus.load(transcriptManifest);
});