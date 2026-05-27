import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/models/cefr_level.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../onboarding/application/onboarding_controller.dart';
import '../../../onboarding/domain/models/interest_category.dart';
import '../../../onboarding/domain/models/movie_preference.dart';
import '../../../onboarding/presentation/widgets/interest_card.dart';
import '../../../social/data/follow_repository.dart';
import '../../../social/domain/models/public_profile.dart';
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
    final currentUser = ref.watch(currentUserProvider);

    final selectedInterests = onboardingInterests
        .where((i) => onboarding.selectedInterestIds.contains(i.id))
        .toList();

    final selectedMovies = mockMoviePreferences
        .where((m) => onboarding.selectedMovieIds.contains(m.id))
        .toList();

    // Following list — only load when user id is known.
    final followingAsync = currentUser != null
        ? ref.watch(followingListProvider(currentUser.id))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Avatar + name + follow counts ───────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    currentUser?.avatarEmoji ?? '🙂',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.username ?? 'You',
                        style: context.text.headlineLarge,
                      ),
                      Text(
                        'Level: ${skill.level.label}',
                        style: context.text.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // Following count chip — tappable → scroll to following list.
                if (followingAsync != null)
                  followingAsync.maybeWhen(
                    data: (list) => _FollowChip(count: list.length),
                    orElse: () => const SizedBox.shrink(),
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

            // ── Following ───────────────────────────────────────────────────
            Text('Following', style: context.text.headlineMedium),
            const SizedBox(height: 8),
            if (followingAsync == null)
              const SizedBox.shrink()
            else
              followingAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) => list.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          "You're not following anyone yet. Find users in Rankings!",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : Column(
                        children: list
                            .map((u) => _FollowingTile(user: u))
                            .toList(),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────

class _FollowChip extends StatelessWidget {
  const _FollowChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$count following',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
}

class _FollowingTile extends StatelessWidget {
  const _FollowingTile({required this.user});
  final PublicProfile user;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push('${Routes.userProfile}/${user.id}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: Text(user.avatarEmoji,
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 18),
            ],
          ),
        ),
      );
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
