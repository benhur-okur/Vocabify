import 'package:flutter/foundation.dart';

@immutable
class RankingEntry {
  const RankingEntry({
    required this.userId,
    required this.username,
    required this.avatarEmoji,
    required this.points,
    required this.rank,
    this.isCurrentUser = false,
  });
  final String userId;
  final String username;
  final String avatarEmoji;
  final int points;
  final int rank;
  final bool isCurrentUser;
}