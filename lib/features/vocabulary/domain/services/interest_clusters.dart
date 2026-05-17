/// A curated mapping from interest id → high-value vocabulary lemmas.
/// This supplements the sparse mock word bank so the matcher can still
/// find relevant transcript segments for a chosen interest even when that
/// interest only has a handful of entries in VocabularyWord.tags.
///
/// Lemmas here are expected to be lowercased and lemmatized form
/// (e.g. "runs"/"running" normalize to "run" — add "run", not "running").
class InterestClusters {
  InterestClusters._();

  static const Map<String, List<String>> _clusters = {
    'tech': [
      'app', 'device', 'code', 'server', 'upload', 'download', 'software',
      'hardware', 'connection', 'network', 'bug', 'system', 'data', 'file',
      'database', 'interface', 'screen', 'click', 'internet', 'website',
      'browser', 'cloud', 'sync', 'install', 'update', 'plugin', 'feature',
      'build', 'deploy', 'release', 'crash', 'cache', 'memory', 'processor',
    ],
    'business': [
      'revenue', 'profit', 'margin', 'customer', 'market', 'strategy',
      'meeting', 'team', 'project', 'deadline', 'budget', 'invest', 'sale',
      'client', 'contract', 'deal', 'growth', 'metric', 'goal', 'launch',
      'acquire', 'merge', 'forecast', 'quarter', 'stakeholder',
    ],
    'travel': [
      'airport', 'flight', 'board', 'boarding', 'customs', 'passport',
      'ticket', 'layover', 'luggage', 'baggage', 'hotel', 'reservation',
      'destination', 'trip', 'journey', 'tour', 'visa', 'embassy',
      'currency', 'exchange', 'map', 'route', 'detour', 'itinerary',
      'souvenir', 'local', 'guide', 'station', 'platform', 'arrival',
      'departure',
    ],
    'daily': [
      'morning', 'breakfast', 'lunch', 'dinner', 'coffee', 'walk', 'drive',
      'commute', 'errand', 'chore', 'grocery', 'laundry', 'receipt',
      'neighbor', 'weekend', 'appointment', 'deadline', 'leftover',
      'kitchen', 'bedroom', 'bathroom', 'laundry', 'weather', 'family',
    ],
    'cinema': [
      'movie', 'film', 'scene', 'plot', 'character', 'actor', 'actress',
      'director', 'producer', 'cast', 'sequel', 'prequel', 'trailer',
      'premiere', 'release', 'script', 'dialogue', 'soundtrack', 'camera',
      'shot', 'frame', 'cut', 'edit', 'protagonist', 'antagonist',
      'villain', 'hero', 'twist', 'spoiler', 'cameo',
    ],
    'science': [
      'experiment', 'hypothesis', 'theory', 'evidence', 'research',
      'discover', 'molecule', 'atom', 'particle', 'gene', 'genome',
      'evolution', 'species', 'gravity', 'orbit', 'planet', 'star',
      'galaxy', 'universe', 'energy', 'matter', 'reaction', 'element',
      'cell', 'tissue', 'organism', 'vaccine', 'virus', 'bacteria',
      'ecosystem', 'climate',
    ],
    'sports': [
      'team', 'match', 'game', 'player', 'coach', 'score', 'goal', 'win',
      'lose', 'season', 'league', 'championship', 'trophy', 'stadium',
      'training', 'practice', 'injury', 'referee', 'foul', 'penalty',
      'tournament', 'medal', 'record', 'fan', 'ball', 'court', 'field',
    ],
    'music': [
      'song', 'album', 'track', 'artist', 'band', 'singer', 'guitar',
      'drums', 'piano', 'concert', 'tour', 'stage', 'lyrics', 'melody',
      'chord', 'rhythm', 'beat', 'genre', 'record', 'studio', 'producer',
      'release', 'single', 'remix',
    ],
    'food': [
      'recipe', 'ingredient', 'dish', 'meal', 'cuisine', 'flavor', 'spice',
      'taste', 'fresh', 'cook', 'bake', 'grill', 'fry', 'boil', 'roast',
      'chop', 'serve', 'plate', 'menu', 'restaurant', 'chef', 'kitchen',
      'vegetable', 'fruit', 'meat', 'dairy',
    ],
    'gaming': [
      'game', 'player', 'level', 'quest', 'boss', 'mission', 'score',
      'achievement', 'controller', 'console', 'pc', 'multiplayer',
      'single-player', 'character', 'avatar', 'inventory', 'weapon',
      'armor', 'skill', 'tutorial', 'checkpoint', 'difficulty', 'stream',
      'lobby', 'match', 'patch', 'update',
    ],
  };

  /// Returns the lemma cluster for an interest id, or an empty list.
  static List<String> lemmasFor(String interestId) =>
      _clusters[interestId] ?? const [];

  /// Collects every lemma across the given interest ids, deduplicated.
  static Set<String> lemmasForAll(Iterable<String> interestIds) {
    final out = <String>{};
    for (final id in interestIds) {
      out.addAll(lemmasFor(id));
    }
    return out;
  }

  /// A loose reverse lookup: which interests mention this lemma?
  /// Used by the matcher to attribute a segment hit to an interest.
  static List<String> interestsForLemma(String lemma) {
    final out = <String>[];
    _clusters.forEach((interest, lemmas) {
      if (lemmas.contains(lemma)) out.add(interest);
    });
    return out;
  }
}