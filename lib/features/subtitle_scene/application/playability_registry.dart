import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Per-video playability outcome. Cached in memory per-session.
enum Playability {
  /// Haven't tried yet.
  unknown,

  /// Player is initializing — don't show error yet.
  probing,

  /// Playback succeeded (position advanced past start).
  playable,

  /// Embed refused by YouTube (error 150/152/153), webview failure, or
  /// timeout waiting for playback to begin.
  blocked,
}

class PlayabilityRegistry extends Notifier<Map<String, Playability>> {
  @override
  Map<String, Playability> build() => <String, Playability>{};

  Playability get(String videoId) {
    if (videoId.isEmpty) return Playability.blocked;
    return state[videoId] ?? Playability.unknown;
  }

  void set(String videoId, Playability p) {
    if (videoId.isEmpty) return;
    // Don't regress playable → blocked on a late error; once it played, trust it.
    final current = state[videoId];
    if (current == Playability.playable && p == Playability.blocked) return;
    if (current == p) return;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[playability] $videoId: ${current ?? "none"} → $p');
    }
    state = {...state, videoId: p};
  }
}

final playabilityRegistryProvider =
    NotifierProvider<PlayabilityRegistry, Map<String, Playability>>(
  PlayabilityRegistry.new,
);