import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.avatarEmoji,
    required this.onboardingCompleted,
  });

  final String id;
  final String email;
  final String username;
  final String avatarEmoji;
  final bool onboardingCompleted;

  AppUser copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarEmoji,
    bool? onboardingCompleted,
  }) =>
      AppUser(
        id: id ?? this.id,
        email: email ?? this.email,
        username: username ?? this.username,
        avatarEmoji: avatarEmoji ?? this.avatarEmoji,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      );

  factory AppUser.fromMap(Map<String, dynamic> map, String email) {
    return AppUser(
      id: map['id'] as String,
      email: email,
      username: map['username'] as String,
      avatarEmoji: map['avatar_emoji'] as String? ?? '🙂',
      onboardingCompleted: map['onboarding_completed'] as bool? ?? false,
    );
  }
}
