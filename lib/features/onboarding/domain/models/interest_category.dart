import 'package:flutter/foundation.dart';

@immutable
class InterestCategory {
  const InterestCategory({required this.id, required this.label, required this.emoji});
  final String id;
  final String label;
  final String emoji;
}

const onboardingInterests = <InterestCategory>[
  InterestCategory(id: 'tech', label: 'Technology', emoji: '💻'),
  InterestCategory(id: 'business', label: 'Business', emoji: '💼'),
  InterestCategory(id: 'travel', label: 'Travel', emoji: '✈️'),
  InterestCategory(id: 'daily', label: 'Daily Life', emoji: '☕'),
  InterestCategory(id: 'cinema', label: 'Cinema', emoji: '🎬'),
  InterestCategory(id: 'science', label: 'Science', emoji: '🔬'),
  InterestCategory(id: 'sports', label: 'Sports', emoji: '⚽'),
  InterestCategory(id: 'music', label: 'Music', emoji: '🎵'),
  InterestCategory(id: 'food', label: 'Food', emoji: '🍕'),
  InterestCategory(id: 'gaming', label: 'Gaming', emoji: '🎮'),
];