import 'package:flutter/material.dart';

import '../../domain/models/movie_preference.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({required this.movie, super.key});
  final MoviePreference movie;

  // Deterministic background color per title so each card feels distinct
  // without needing real cover art.
  Color _bgFor(String id) {
    final palette = [
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      const Color(0xFF312E81),
      const Color(0xFF831843),
      const Color(0xFF14532D),
      const Color(0xFF7C2D12),
      const Color(0xFF581C87),
      const Color(0xFF0C4A6E),
    ];
    return palette[id.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgFor(movie.id);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Icon(
              movie.type == MovieType.series
                  ? Icons.tv_rounded
                  : Icons.movie_creation_rounded,
              size: 240,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  movie.type == MovieType.series ? 'SERIES' : 'MOVIE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${movie.year}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Swipe right if you love it.\nSwipe left to pass.',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}