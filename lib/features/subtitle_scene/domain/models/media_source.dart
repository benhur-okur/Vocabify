import 'package:flutter/foundation.dart';

/// Where to stream the video from. For prototype scope this is always YouTube.
/// Abstracted so a future HLS/DASH source can plug in without changing
/// screens or the matcher.
@immutable
class MediaSource {
  const MediaSource({required this.youtubeVideoId});
  final String youtubeVideoId;
}