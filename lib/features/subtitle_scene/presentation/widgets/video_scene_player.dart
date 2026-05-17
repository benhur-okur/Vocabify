import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../app/theme/app_colors.dart';
import '../../application/playability_registry.dart';

/// Embedded YouTube player with robust fallback. Verified against
/// youtube_player_iframe 5.2.x (no onInit, no YoutubePlayerValue.position).
///
/// Detection strategy for embed-blocked videos (error 150/152/153 etc.):
///
///   1. Construct YoutubePlayerController with onWebResourceError callback.
///      Any webview-level failure flips status to blocked.
///
///   2. Listen to controller.stream for PlayerState.unknown and any
///      hasError flag on YoutubePlayerValue.
///
///   3. Start an 8-second probe timer. If position hasn't advanced past
///      (startSec + 0.25) within 8s AND state isn't playing, we assume
///      the embed was blocked server-side and flip to blocked.
///
///   4. Once position advances past start, mark playable and stop probing.
///
/// When blocked, the widget renders a fallback card with a "Watch on YouTube"
/// button that opens the video in the YouTube app / external browser, while
/// the detail screen still shows subtitle, focus word, and quiz.
class VideoScenePlayer extends ConsumerStatefulWidget {
  const VideoScenePlayer({
    required this.videoId,
    required this.startMs,
    required this.endMs,
    required this.subtitle,
    this.onClipEnded,
    super.key,
  });

  final String videoId;
  final int startMs;
  final int endMs;
  final String subtitle;
  final VoidCallback? onClipEnded;

  @override
  ConsumerState<VideoScenePlayer> createState() => VideoScenePlayerState();
}

class VideoScenePlayerState extends ConsumerState<VideoScenePlayer> {
  YoutubePlayerController? _controller;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<YoutubePlayerValue>? _valueSub;
  Timer? _probeTimeout;
  Timer? _fallbackPoll;

  bool _endReached = false;
  bool _acting = false;
  bool _observedPlayback = false;

  double get _startSec => widget.startMs / 1000.0;
  double get _endSec => widget.endMs / 1000.0;

  Playability get _status =>
      ref.read(playabilityRegistryProvider.notifier).get(widget.videoId);

  @override
  void initState() {
    super.initState();
    if (widget.videoId.isEmpty) {
      ref
          .read(playabilityRegistryProvider.notifier)
          .set(widget.videoId, Playability.blocked);
      return;
    }

    // If we already know this video is blocked from a previous mount, skip
    // webview entirely.
    final prior = ref
        .read(playabilityRegistryProvider.notifier)
        .get(widget.videoId);
    if (prior == Playability.blocked) return;

    _initController();
  }

  void _initController() {
    ref
        .read(playabilityRegistryProvider.notifier)
        .set(widget.videoId, Playability.probing);

    final c = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      startSeconds: _startSec,
      endSeconds: _endSec,
      params: const YoutubePlayerParams(
        mute: false,
        showControls: false,
        showFullscreenButton: false,
        enableCaption: false,
        strictRelatedVideos: true,
        playsInline: true,
      ),
    );

    // Webview-level errors (net::ERR_*, SSL, etc.) flip us to blocked.
    c.setFullScreenListener((_) {});
    _controller = c;

    // State / error observation.
    _valueSub = c.stream.listen((YoutubePlayerValue value) {
      if (value.hasError) {
        _markBlocked('hasError=${value.error}');
      }
    });

    // Position observation — primary path for "did playback actually start".
    _attachEndWatcher();

    // Probe timeout: if we haven't seen playback in 8s, assume blocked.
    _probeTimeout = Timer(const Duration(seconds: 8), () {
      if (!_observedPlayback) _markBlocked('probe timeout');
    });
  }

  void _attachEndWatcher() {
    final c = _controller;
    if (c == null) return;
    try {
      // ignore: deprecated_member_use
      final stream = c.getCurrentPositionStream();
      _positionSub = stream.listen(
        (pos) => _onPosition(pos.inMilliseconds / 1000.0),
        onError: (_) => _startFallbackPoll(),
      );
    } catch (_) {
      _startFallbackPoll();
    }
  }

  void _startFallbackPoll() {
    _fallbackPoll?.cancel();
    _fallbackPoll =
        Timer.periodic(const Duration(milliseconds: 500), (_) async {
      final c = _controller;
      if (c == null) return;
      try {
        final secs = await c.currentTime;
        _onPosition(secs);
      } catch (_) {
        // iframe not ready yet
      }
    });
  }

  void _onPosition(double posSec) {
    if (!_observedPlayback && posSec > _startSec + 0.1) {
      _observedPlayback = true;
      _probeTimeout?.cancel();
      ref
          .read(playabilityRegistryProvider.notifier)
          .set(widget.videoId, Playability.playable);
    }
    if (_acting || _endReached) return;
    if (posSec <= 0) return;
    if (posSec >= _endSec - 0.1) {
      _acting = true;
      _controller?.pauseVideo().catchError((_) {}).whenComplete(() {
        if (!mounted) return;
        setState(() => _endReached = true);
        widget.onClipEnded?.call();
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (mounted) _acting = false;
        });
      });
    }
  }

  void _markBlocked(String why) {
    if (!mounted) return;
    // If playback was already observed, ignore late errors.
    if (_observedPlayback) return;
    ref
        .read(playabilityRegistryProvider.notifier)
        .set(widget.videoId, Playability.blocked);
    _positionSub?.cancel();
    _fallbackPoll?.cancel();
    _probeTimeout?.cancel();
    setState(() {}); // re-render into fallback
  }

  Future<void> replay() async {
    final c = _controller;
    if (c == null) return;
    _endReached = false;
    _acting = true;
    try {
      await c.seekTo(seconds: _startSec, allowSeekAhead: true);
      await c.playVideo();
    } catch (_) {}
    if (!mounted) return;
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (mounted) _acting = false;
  }

  Future<void> openExternally() async {
    if (widget.videoId.isEmpty) return;
    final startSec = widget.startMs ~/ 1000;
    final uri = Uri.parse(
      'https://www.youtube.com/watch?v=${widget.videoId}&t=${startSec}s',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback: in-app webview if external can't handle it.
      try {
        await launchUrl(uri);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _valueSub?.cancel();
    _fallbackPoll?.cancel();
    _probeTimeout?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the registry so we rebuild when status flips.
    ref.watch(playabilityRegistryProvider);
    final status = _status;

    final clipLenSec = ((widget.endMs - widget.startMs) / 1000).round();

    Widget surface;
    if (widget.videoId.isEmpty || status == Playability.blocked) {
      surface = _BlockedFallback(
        subtitle: widget.subtitle,
        videoId: widget.videoId,
        startMs: widget.startMs,
        onOpenExternally: openExternally,
      );
    } else if (_controller == null) {
      // Should not happen — we build the controller whenever we're not
      // already blocked. Safety net:
      surface = const ColoredBox(color: Colors.black);
    } else {
      surface = YoutubePlayer(
        controller: _controller!,
        aspectRatio: 16 / 9,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            Positioned.fill(child: surface),

            // Only overlay subtitle on top of the real player.
            if (status != Playability.blocked && widget.videoId.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Text(
                    '"${widget.subtitle}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ),

            Positioned(
              top: 8,
              left: 8,
              child: _StatusChip(
                  status: status,
                  clipLenSec: clipLenSec,
                  videoId: widget.videoId),
            ),

            if (_endReached &&
                status == Playability.playable &&
                widget.videoId.isNotEmpty)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  alignment: Alignment.center,
                  child: _ReplayButton(onTap: replay),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.clipLenSec,
    required this.videoId,
  });
  final Playability status;
  final int clipLenSec;
  final String videoId;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final IconData icon;
    switch (status) {
      case Playability.playable:
        label = '${clipLenSec}s clip';
        bg = AppColors.primary;
        icon = Icons.play_circle_fill;
        break;
      case Playability.probing:
        label = 'Loading…';
        bg = Colors.black54;
        icon = Icons.hourglass_bottom_rounded;
        break;
      case Playability.blocked:
        label = 'Transcript only';
        bg = Colors.black87;
        icon = Icons.subtitles_rounded;
        break;
      case Playability.unknown:
        label = '${clipLenSec}s clip';
        bg = AppColors.primary;
        icon = Icons.play_circle_fill;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedFallback extends StatelessWidget {
  const _BlockedFallback({
    required this.subtitle,
    required this.videoId,
    required this.startMs,
    required this.onOpenExternally,
  });
  final String subtitle;
  final String videoId;
  final int startMs;
  final VoidCallback onOpenExternally;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F2937), Color(0xFF0F172A)],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.videocam_off_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "This clip can't play embedded",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "The video blocks embedded playback. Keep learning from the subtitle, or open it on YouTube.",
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const Spacer(),
          if (videoId.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpenExternally,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Watch on YouTube'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReplayButton extends StatelessWidget {
  const _ReplayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Icon(Icons.replay_rounded,
              color: AppColors.primary, size: 32),
        ),
      ),
    );
  }
}