import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/models/cefr_level.dart'; // ← required for `.label`
import '../../../onboarding/application/onboarding_controller.dart';
import '../../../onboarding/domain/models/interest_category.dart';
import '../../../onboarding/domain/models/movie_preference.dart';
import '../../../onboarding/presentation/widgets/interest_card.dart';
import '../../../vocabulary/application/skill_tracker.dart';
import '../../application/user_preferences_controller.dart';
import '../widgets/stat_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final profile = ref.watch(learningProfileProvider);
    final skill = ref.watch(skillTrackerProvider);

    final selectedInterests = onboardingInterests
        .where((i) => onboarding.selectedInterestIds.contains(i.id))
        .toList();

    final selectedMovies = mockMoviePreferences
        .where((m) => onboarding.selectedMovieIds.contains(m.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Avatar + level ──────────────────────────────────────────────
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  child: Text('🙂', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You', style: context.text.headlineLarge),
                      Text('Current level: ${skill.level.label}',
                          style: context.text.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Weekly stats ────────────────────────────────────────────────
            Text('This week', style: context.text.headlineMedium),
            const SizedBox(height: 8),
            StatTile(
              icon: Icons.military_tech_outlined,
              label: 'Points',
              value: '${profile.totalPoints}',
            ),
            const SizedBox(height: 8),
            StatTile(
              icon: Icons.quiz_outlined,
              label: 'Quizzes completed',
              value: '${profile.totalQuizzes}',
            ),
            const SizedBox(height: 8),
            StatTile(
              icon: Icons.movie_outlined,
              label: 'Scenes learned',
              value: '${profile.totalScenesViewed}',
            ),
            const SizedBox(height: 8),
            StatTile(
              icon: Icons.percent,
              label: 'Accuracy',
              value: profile.overallAccuracy == 0
                  ? '–'
                  : '${(profile.overallAccuracy * 100).round()}%',
            ),
            const SizedBox(height: 28),

            // ── Interests ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your interests', style: context.text.headlineMedium),
                TextButton.icon(
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                  onPressed: () => context.push(Routes.editInterests),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (selectedInterests.isEmpty)
              _EmptyHint(
                label: 'No interests selected.',
                onEdit: () => context.push(Routes.editInterests),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedInterests
                    .map((i) => Chip(
                          avatar: Icon(InterestIcons.of(i.id), size: 18),
                          label: Text(i.label),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 28),

            // ── Movies & shows ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your movies & shows',
                    style: context.text.headlineMedium),
                TextButton.icon(
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                  onPressed: () => context.push(Routes.editMovies),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (selectedMovies.isEmpty)
              _EmptyHint(
                label: 'No titles selected.',
                onEdit: () => context.push(Routes.editMovies),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedMovies
                    .map((m) => Chip(
                          avatar: Icon(
                            m.type == MovieType.series
                                ? Icons.tv_rounded
                                : Icons.movie_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(m.title),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.label, required this.onEdit});
  final String label;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}