import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../../../../core/models/cefr_level.dart';
import '../../../../core/text/lemmatizer.dart';
import '../../../vocabulary/domain/models/vocabulary_word.dart';
import '../../../vocabulary/domain/services/interest_clusters.dart';
import '../../data/transcript_corpus.dart';
import '../models/scene_word.dart';
import '../models/subtitle_scene.dart';

class ScoredScene {
  const ScoredScene(this.scene, this.score, this.reasons);
  final SubtitleScene scene;
  final double score;
  final List<String> reasons;
}

/// Timestamp-retrieval engine. For each transcript segment, compute a
/// composite score combining:
///
///   1. Vocabulary word matches (tf-idf-ish, with CEFR proximity)
///   2. Interest cluster lemma matches (user interests → curated lemma lists)
///   3. Title-level interest overlap (title's topic tags ∩ interests)
///   4. Title bonus if the title is explicitly selected
///   5. Clarity heuristic (duration + length penalties)
///
/// Only segments that have at least one hit (vocabulary or cluster) are
/// returned. This biases the feed toward teachable moments, not random
/// transcript lines.
class SceneMatcher {
  const SceneMatcher({
    this.wVocab = 2.5,
    this.wLevel = 3.0,
    this.wInterest = 2.0,
    this.wCluster = 1.75,
    this.wClarity = 1.0,
    this.wTitle = 4.0,
    this.idealMinMs = 5000,
    this.idealMaxMs = 10000,
  });

  final double wVocab;
  final double wLevel;
  final double wInterest;
  final double wCluster;
  final double wClarity;
  final double wTitle;
  final int idealMinMs;
  final int idealMaxMs;

  List<ScoredScene> match({
    required TranscriptCorpus corpus,
    required List<VocabularyWord> vocabularyPool,
    required Set<String> selectedMovieIds,
    required Set<String> selectedInterestIds,
    required CefrLevel userLevel,
    int topK = 50,
  }) {
    // --- Build two lookup maps ----------------------------------------------
    // (1) lemma → vocabulary word (primary signal)
    final lemmaToWord = <String, VocabularyWord>{};
    for (final w in vocabularyPool) {
      final l = Lemmatizer.lemma(w.term.toLowerCase());
      lemmaToWord[l] = w;
      lemmaToWord[w.term.toLowerCase()] = w;
    }

    // (2) cluster lemmas → interest ids that own them
    final clusterLemmas = InterestClusters.lemmasForAll(selectedInterestIds);

    // --- idf over the full corpus for vocabulary lemmas --------------------
    final totalSegs = math.max(1, corpus.totalSegments);
    final idf = <String, double>{};
    for (final lemma in lemmaToWord.keys) {
      final df = corpus.documentFrequency(lemma);
      idf[lemma] = math.log((totalSegs + 1) / (df + 1)) + 1.0;
    }

    // --- Accumulate per segment --------------------------------------------
    final perSegment = <String, _SegmentAcc>{};

    // Vocabulary contributions
    for (final entry in lemmaToWord.entries) {
      final lemma = entry.key;
      final word = entry.value;
      final postings = corpus.postingsFor(lemma);
      if (postings.isEmpty) continue;

      for (final p in postings) {
        final key = '${p.movieId}:${p.segmentIndex}';
        final acc = perSegment.putIfAbsent(
          key,
          () => _SegmentAcc(p.movieId, p.segmentIndex),
        );
        acc.matchedWordIds.add(word.id);
        acc.vocabScore += idf[lemma] ?? 1.0;

        final dist = (word.cefrLevel.rank - userLevel.rank).abs();
        acc.levelScore += (1.0 - dist / 5.0).clamp(0.0, 1.0);

        final wordTags = {word.categoryId, ...word.tags};
        acc.interestHits +=
            wordTags.intersection(selectedInterestIds).length;
      }
    }

    // Interest-cluster contributions: segments that contain cluster lemmas
    // even if those lemmas aren't in the vocabulary bank.
    for (final lemma in clusterLemmas) {
      // Skip lemmas we already counted via the vocabulary pool.
      if (lemmaToWord.containsKey(lemma)) continue;
      final postings = corpus.postingsFor(lemma);
      if (postings.isEmpty) continue;

      for (final p in postings) {
        final key = '${p.movieId}:${p.segmentIndex}';
        final acc = perSegment.putIfAbsent(
          key,
          () => _SegmentAcc(p.movieId, p.segmentIndex),
        );
        acc.clusterHits += 1;
        acc.clusterLemmas.add(lemma);
      }
    }

    // --- Convert to scored scenes ------------------------------------------
    final out = <ScoredScene>[];
    for (final acc in perSegment.values) {
      final transcript = corpus.transcripts[acc.movieId];
      if (transcript == null) continue;
      if (acc.segmentIndex >= transcript.segments.length) continue;
      final seg = transcript.segments[acc.segmentIndex];

      final durScore =
          _triangle(seg.durationMs.toDouble(), idealMinMs.toDouble(), idealMaxMs.toDouble());
      final lenTokens = seg.lemmas.length;
      final lenScore = lenTokens <= 3
          ? 0.4
          : (lenTokens <= 18
              ? 1.0
              : (1.0 - (lenTokens - 18) / 20.0).clamp(0.2, 1.0));
      final clarity = (durScore * 0.7) + (lenScore * 0.3);

      final titleBonus =
          selectedMovieIds.contains(acc.movieId) ? wTitle : 0.0;
      final titleInterestOverlap =
          transcript.topicTags.where(selectedInterestIds.contains).length;

      final total = (wVocab * acc.vocabScore) +
          (wLevel * acc.levelScore) +
          (wInterest * (acc.interestHits + titleInterestOverlap * 1.5)) +
          (wCluster * acc.clusterHits) +
          (wClarity * clarity) +
          titleBonus;

      // --- Choose the focus word ------------------------------------------
      // Prefer a matched vocabulary word (we have meaning for it). If there
      // are none, synthesize a focus word from a cluster lemma found in the
      // segment — this keeps the UI populated for segments that only hit
      // interest-cluster lemmas.
      SceneWord? focus;
      VocabularyWord? focusWord;
      if (acc.matchedWordIds.isNotEmpty) {
        double bestIdf = -1;
        String? bestId;
        for (final wid in acc.matchedWordIds) {
          final w = vocabularyPool.firstWhereOrNull((x) => x.id == wid);
          if (w == null) continue;
          final l = Lemmatizer.lemma(w.term.toLowerCase());
          final weight = idf[l] ?? 1.0;
          if (weight > bestIdf) {
            bestIdf = weight;
            bestId = wid;
          }
        }
        focusWord = vocabularyPool.firstWhereOrNull((w) => w.id == bestId);
        if (focusWord != null) {
          focus = SceneWord(
            term: focusWord.term,
            meaning: focusWord.meaning,
            contextExplanation: focusWord.exampleSentence,
          );
        }
      }
      if (focus == null) {
        // Synthesize from first cluster lemma present in the segment.
        final lemma = acc.clusterLemmas.firstWhereOrNull(
          (l) => seg.lemmas.contains(l),
        );
        if (lemma == null) continue;
        focus = SceneWord(
          term: lemma,
          meaning: 'A ${_articleFor(lemma)} related to '
              '${InterestClusters.interestsForLemma(lemma).join(", ")}.',
          contextExplanation: seg.text,
        );
      }

      // --- Human-readable reasons -----------------------------------------
      final reasons = <String>[];
      if (selectedMovieIds.contains(acc.movieId)) {
        reasons.add('from a title you picked');
      }
      if (acc.matchedWordIds.isNotEmpty) {
        reasons.add(acc.matchedWordIds.length == 1
            ? 'teaches "${focusWord?.term ?? focus.term}"'
            : '${acc.matchedWordIds.length} learning words');
      }
      if (acc.clusterHits > 0) {
        reasons.add('${acc.clusterHits} interest words');
      }
      if (titleInterestOverlap > 0) {
        reasons.add('topic: ${transcript.topicTags.take(2).join(", ")}');
      }
      reasons.add('~${(seg.durationMs / 1000).round()}s');

      final scene = SubtitleScene(
        id: '${acc.movieId}_${acc.segmentIndex}',
        movieId: acc.movieId,
        movieTitle: transcript.movieTitle,
        source: transcript.source,
        subtitle: seg.text,
        focusWord: focus,
        startMs: seg.startMs,
        endMs: seg.endMs,
        timestampLabel: _timestampLabel(seg.startMs),
        matchedWordIds: acc.matchedWordIds.toList(),
        topicTags: transcript.topicTags,
      );

      out.add(ScoredScene(scene, total, reasons));
    }

    out.sort((a, b) => b.score.compareTo(a.score));
    return out.take(topK).toList();
  }

  double _triangle(double v, double lo, double hi) {
    final mid = (lo + hi) / 2;
    final halfWidth = (hi - lo) / 2 + lo * 0.2;
    final dist = (v - mid).abs();
    if (dist >= halfWidth) return 0.2;
    return 1.0 - (dist / halfWidth) * 0.8;
  }

  String _timestampLabel(int ms) {
    final s = ms ~/ 1000;
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  String _articleFor(String lemma) {
    if (lemma.isEmpty) return 'word';
    return 'word';
  }
}

class _SegmentAcc {
  _SegmentAcc(this.movieId, this.segmentIndex);
  final String movieId;
  final int segmentIndex;
  final Set<String> matchedWordIds = {};
  final Set<String> clusterLemmas = {};
  double vocabScore = 0;
  double levelScore = 0;
  int interestHits = 0;
  int clusterHits = 0;
}