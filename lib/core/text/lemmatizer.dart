/// Lightweight English lemmatizer for subtitle search. Rule-based, not a
/// linguistic tool — but robust enough to match "running" with "run" and
/// "bought" with "buy". Far better than raw string equality.
class Lemmatizer {
  Lemmatizer._();

  static const Set<String> _stopWords = {
    'a', 'an', 'the', 'and', 'or', 'but', 'if', 'so', 'of', 'to', 'in',
    'on', 'at', 'by', 'for', 'with', 'as', 'is', 'am', 'are', 'was',
    'were', 'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does',
    'did', 'will', 'would', 'can', 'could', 'should', 'may', 'might',
    'must', 'it', 'its', "it's", 'this', 'that', 'these', 'those',
    'i', 'you', 'he', 'she', 'we', 'they', 'me', 'him', 'her', 'us',
    'them', 'my', 'your', 'his', 'their', 'our', 'not', "n't", "'s",
    "'re", "'ve", "'ll", "'d", "'m", 'there', 'here',
  };

  // Irregular verbs / nouns — partial but covers the common ones.
  static const Map<String, String> _irregular = {
    'went': 'go', 'gone': 'go',
    'was': 'be', 'were': 'be', 'been': 'be',
    'had': 'have', 'has': 'have',
    'did': 'do', 'done': 'do',
    'said': 'say',
    'made': 'make',
    'took': 'take', 'taken': 'take',
    'came': 'come',
    'saw': 'see', 'seen': 'see',
    'got': 'get', 'gotten': 'get',
    'gave': 'give', 'given': 'give',
    'found': 'find',
    'thought': 'think',
    'told': 'tell',
    'became': 'become',
    'left': 'leave',
    'felt': 'feel',
    'brought': 'bring',
    'bought': 'buy',
    'taught': 'teach',
    'caught': 'catch',
    'began': 'begin', 'begun': 'begin',
    'kept': 'keep',
    'held': 'hold',
    'lost': 'lose',
    'meant': 'mean',
    'met': 'meet',
    'paid': 'pay',
    'ran': 'run',
    'sold': 'sell',
    'sent': 'send',
    'sat': 'sit',
    'stood': 'stand',
    'won': 'win',
    'knew': 'know', 'known': 'know',
    'grew': 'grow', 'grown': 'grow',
    'broke': 'break', 'broken': 'break',
    'chose': 'choose', 'chosen': 'choose',
    'drove': 'drive', 'driven': 'drive',
    'wrote': 'write', 'written': 'write',
    'spoke': 'speak', 'spoken': 'speak',
    'ate': 'eat', 'eaten': 'eat',
    'children': 'child',
    'people': 'person',
    'men': 'man',
    'women': 'woman',
    'feet': 'foot',
    'teeth': 'tooth',
    'mice': 'mouse',
    'geese': 'goose',
  };

  /// Returns the base form of a single token.
  static String lemma(String token) {
    final w = token.toLowerCase();
    if (w.length <= 2) return w;
    if (_irregular.containsKey(w)) return _irregular[w]!;

    // -ies → -y (cities → city)
    if (w.endsWith('ies') && w.length > 4) {
      return '${w.substring(0, w.length - 3)}y';
    }
    // -ied → -y (tried → try)
    if (w.endsWith('ied') && w.length > 4) {
      return '${w.substring(0, w.length - 3)}y';
    }
    // -sses → -ss (misses → miss)
    if (w.endsWith('sses')) return w.substring(0, w.length - 2);
    // -ves → -f / -fe (leaves → leaf, knives → knife) — heuristic
    if (w.endsWith('ves') && w.length > 4) {
      return '${w.substring(0, w.length - 3)}f';
    }
    // -es → strip (boxes → box), but not -ses/-xes edge safe
    if (w.endsWith('es') && w.length > 3 &&
        (w.endsWith('ches') || w.endsWith('shes') ||
         w.endsWith('xes') || w.endsWith('zes'))) {
      return w.substring(0, w.length - 2);
    }
    // -s → strip (books → book), but not -ss / -us / -is
    if (w.endsWith('s') && !w.endsWith('ss') && !w.endsWith('us') &&
        !w.endsWith('is') && w.length > 3) {
      return w.substring(0, w.length - 1);
    }
    // -ing → strip, restoring double consonant (running → run, making → make)
    if (w.endsWith('ing') && w.length > 5) {
      var root = w.substring(0, w.length - 3);
      if (root.length > 2 &&
          root[root.length - 1] == root[root.length - 2]) {
        root = root.substring(0, root.length - 1);
      } else {
        // Heuristic: add 'e' back for verbs like "making" → "make"
        final maybe = '${root}e';
        if (_looksLikeEVerb(maybe)) return maybe;
      }
      return root;
    }
    // -ed → strip (worked → work, lived → live)
    if (w.endsWith('ed') && w.length > 4) {
      var root = w.substring(0, w.length - 2);
      if (root.length > 2 &&
          root[root.length - 1] == root[root.length - 2]) {
        root = root.substring(0, root.length - 1);
      } else {
        final maybe = '${root}e';
        if (_looksLikeEVerb(maybe)) return maybe;
      }
      return root;
    }
    // -er / -est comparatives (bigger → big, largest → large)
    if (w.endsWith('est') && w.length > 5) {
      return w.substring(0, w.length - 3);
    }
    if (w.endsWith('er') && w.length > 4) {
      return w.substring(0, w.length - 2);
    }
    // -ly adverb → base (quickly → quick)
    if (w.endsWith('ly') && w.length > 4) {
      return w.substring(0, w.length - 2);
    }
    return w;
  }

  static bool _looksLikeEVerb(String word) {
    const eVerbs = {
      'make', 'take', 'come', 'give', 'live', 'love', 'have',
      'move', 'save', 'believe', 'receive', 'write', 'drive',
      'ride', 'hide', 'close', 'use', 'lose', 'choose', 'like',
      'bake', 'shake', 'wake', 'fake',
    };
    return eVerbs.contains(word);
  }

  /// Tokenizes text, lemmatizes each token, drops stop-words.
  /// Preserves contractions as whole units ("can't" → "cannot" → "cannot" is
  /// overkill; we just lowercase and let the stop-list drop "n't").
  static List<String> lemmatize(String text) {
    final tokens = _tokenize(text);
    final out = <String>[];
    for (final t in tokens) {
      if (_stopWords.contains(t)) continue;
      final l = lemma(t);
      if (_stopWords.contains(l)) continue;
      if (l.isEmpty) continue;
      out.add(l);
    }
    return out;
  }

  static List<String> _tokenize(String text) {
    final lowered = text.toLowerCase();
    final cleaned = lowered.replaceAll(RegExp(r"[^a-z0-9'\- ]"), ' ');
    return cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  }
}