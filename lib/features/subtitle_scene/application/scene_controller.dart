import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/onboarding_controller.dart';
import '../../vocabulary/application/skill_tracker.dart';
import '../../vocabulary/data/mock/mock_words.dart';
import '../data/transcript_corpus.dart';
import '../domain/models/subtitle_scene.dart';
import '../domain/services/scene_matcher.dart';

/// The scored, personalized scene list — the primary feed.
final scoredScenesProvider =
    FutureProvider<List<ScoredScene>>((ref) async {
  final corpus = await ref.watch(transcriptCorpusProvider.future);
  final onboarding = ref.watch(onboardingControllerProvider);
  final level = ref.watch(skillTrackerProvider).level;

  // The vocabulary pool is the full mock bank. The matcher re-ranks by
  // interest + level internally, so we don't need to pre-filter here.
  final pool = mockWords;

  final scored = const SceneMatcher().match(
    corpus: corpus,
    vocabularyPool: pool,
    selectedMovieIds: onboarding.selectedMovieIds,
    selectedInterestIds: onboarding.selectedInterestIds,
    userLevel: level,
    topK: 50,
  );

  return scored;
});

/// Resolves a scored scene by id — backed by an in-memory index of the
/// last-computed scored list. This is how the detail screen finds a scene
/// when the user taps one from the list.
final scoredSceneByIdProvider =
    FutureProvider.family<SubtitleScene?, String>((ref, id) async {
  final list = await ref.watch(scoredScenesProvider.future);
  for (final s in list) {
    if (s.scene.id == id) return s.scene;
  }
  return null;
});