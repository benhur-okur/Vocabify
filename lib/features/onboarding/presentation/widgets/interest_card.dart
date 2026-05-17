import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/interest_category.dart';

/// Maps each interest id to a Material icon — used across onboarding and
/// home so the iconography stays consistent.
class InterestIcons {
  InterestIcons._();
  static IconData of(String id) {
    switch (id) {
      case 'tech':
        return Icons.memory_rounded;
      case 'business':
        return Icons.trending_up_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'daily':
        return Icons.local_cafe_rounded;
      case 'cinema':
        return Icons.movie_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'gaming':
        return Icons.sports_esports_rounded;
      default:
        return Icons.tag_rounded;
    }
  }

  static List<Color> gradientOf(String id) {
    switch (id) {
      case 'tech':
        return const [Color(0xFF6366F1), Color(0xFF4338CA)];
      case 'business':
        return const [Color(0xFF10B981), Color(0xFF065F46)];
      case 'travel':
        return const [Color(0xFFF59E0B), Color(0xFFDC2626)];
      case 'daily':
        return const [Color(0xFFF472B6), Color(0xFFBE185D)];
      case 'cinema':
        return const [Color(0xFF8B5CF6), Color(0xFF5B21B6)];
      case 'science':
        return const [Color(0xFF0EA5E9), Color(0xFF0C4A6E)];
      case 'sports':
        return const [Color(0xFF22C55E), Color(0xFF14532D)];
      case 'music':
        return const [Color(0xFFEC4899), Color(0xFF831843)];
      case 'food':
        return const [Color(0xFFEF4444), Color(0xFF991B1B)];
      case 'gaming':
        return const [Color(0xFF6366F1), Color(0xFF312E81)];
      default:
        return const [AppColors.primary, AppColors.primaryDark];
    }
  }
}

class InterestCard extends StatelessWidget {
  const InterestCard({required this.interest, super.key});
  final InterestCategory interest;

  @override
  Widget build(BuildContext context) {
    final gradient = InterestIcons.gradientOf(interest.id);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(InterestIcons.of(interest.id),
                size: 36, color: Colors.white),
          ),
          const Spacer(),
          Text(
            interest.emoji,
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 12),
          Text(
            interest.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Swipe right to learn about this.\nSwipe left to skip.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}