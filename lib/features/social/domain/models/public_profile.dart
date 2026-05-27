import 'package:flutter/foundation.dart';

@immutable
class PublicProfile {
  const PublicProfile({
    required this.id,
    required this.username,
    required this.avatarEmoji,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.cefrLevel,
    required this.interests,
    this.weeklyPoints,
    this.weeklyQuizzes,
    this.weeklyScenes,
  });

  final String id;
  final String username;
  final String avatarEmoji;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final String cefrLevel;
  final List<String> interests;
  final int? weeklyPoints;
  final int? weeklyQuizzes;
  final int? weeklyScenes;
}
