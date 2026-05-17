import '../../domain/models/ranking_entry.dart';

const mockRanking = <RankingEntry>[
  RankingEntry(userId: 'u1', username: 'Lexi', avatarEmoji: '🦊', points: 2340, rank: 1),
  RankingEntry(userId: 'u2', username: 'Mert', avatarEmoji: '🐼', points: 2110, rank: 2),
  RankingEntry(userId: 'u3', username: 'Sora', avatarEmoji: '🐙', points: 1985, rank: 3),
  RankingEntry(userId: 'u4', username: 'Aylin', avatarEmoji: '🦉', points: 1720, rank: 4),
  RankingEntry(userId: 'u5', username: 'Kaan', avatarEmoji: '🐻', points: 1510, rank: 5),
  RankingEntry(userId: 'me', username: 'You', avatarEmoji: '🙂', points: 0, rank: 6, isCurrentUser: true),
  RankingEntry(userId: 'u7', username: 'Noor', avatarEmoji: '🦁', points: 1180, rank: 7),
  RankingEntry(userId: 'u8', username: 'Deniz', avatarEmoji: '🐨', points: 940, rank: 8),
];