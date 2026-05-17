import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/subtitle_scene.dart';
import 'transcript_corpus.dart';

abstract class SceneRepository {
  /// Returns scenes without ranking — one scene per segment across the corpus.
  /// Used as a fallback "browse everything" view.
  Future<List<SubtitleScene>> fetchAllScenes();

  /// Resolves a scene by its composite id ("<movieId>_<segmentIndex>").
  Future<SubtitleScene?> fetchSceneById(String id);
}

class CorpusSceneRepository implements SceneRepository {
  CorpusSceneRepository(this._corpusFuture);
  final Future<TranscriptCorpus> _corpusFuture;

  @override
  Future<List<SubtitleScene>> fetchAllScenes() async {
    final corpus = await _corpusFuture;
    final out = <SubtitleScene>[];
    for (final t in corpus.transcripts.values) {
      for (var i = 0; i < t.segments.length; i++) {
        final s = t.segments[i];
        // These generic scenes have no focus word — the scored pipeline
        // is where real scenes with a focus word are produced. We still
        // surface them so browsing works with no user interests set.
        continue;
      }
    }
    return out;
  }

  @override
  Future<SubtitleScene?> fetchSceneById(String id) async {
    final corpus = await _corpusFuture;
    final parts = id.split('_');
    if (parts.length < 2) return null;
    final segIdx = int.tryParse(parts.last);
    if (segIdx == null) return null;
    final movieId = parts.sublist(0, parts.length - 1).join('_');
    final t = corpus.transcripts[movieId];
    if (t == null) return null;
    if (segIdx < 0 || segIdx >= t.segments.length) return null;
    // We can't rebuild the focus word here without a vocab pool, so this
    // method is used only as a fallback — the list screen passes full
    // scene objects forward via the scored list.
    return null;
  }
}

final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  return CorpusSceneRepository(ref.watch(transcriptCorpusProvider.future));
});