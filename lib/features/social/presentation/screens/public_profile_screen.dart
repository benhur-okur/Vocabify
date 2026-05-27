import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../onboarding/domain/models/interest_category.dart';
import '../../../onboarding/presentation/widgets/interest_card.dart';
import '../../data/follow_repository.dart';
import '../../domain/models/public_profile.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({required this.userId, super.key});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (profile) => _Body(profile: profile),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.profile});
  final PublicProfile profile;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  late bool _isFollowing;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.profile.isFollowing;
  }

  Future<void> _toggleFollow() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (_isFollowing) {
        await ref
            .read(followRepositoryProvider)
            .unfollow(widget.profile.id);
      } else {
        await ref.read(followRepositoryProvider).follow(widget.profile.id);
      }
      setState(() => _isFollowing = !_isFollowing);
      ref.invalidate(publicProfileProvider(widget.profile.id));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwnProfile = currentUser?.id == widget.profile.id;
    final p = widget.profile;

    final selectedInterests = onboardingInterests
        .where((i) => p.interests.contains(i.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        // ── Avatar + name + counts ──────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primaryLight,
              child:
                  Text(p.avatarEmoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.username, style: context.text.headlineLarge),
                  const SizedBox(height: 6),
                  _CefrBadge(level: p.cefrLevel),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CountChip(
                          label: 'Followers',
                          count: p.followersCount +
                              (_isFollowing && !p.isFollowing ? 1 : 0) +
                              (!_isFollowing && p.isFollowing ? -1 : 0)),
                      const SizedBox(width: 12),
                      _CountChip(
                          label: 'Following', count: p.followingCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Follow button ───────────────────────────────────────────────
        if (!isOwnProfile)
          SizedBox(
            width: double.infinity,
            child: _loading
                ? const Center(
                    child: SizedBox(
                      height: 36,
                      width: 36,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : OutlinedButton.icon(
                    icon: Icon(
                      _isFollowing
                          ? Icons.person_remove_rounded
                          : Icons.person_add_rounded,
                      size: 18,
                    ),
                    label: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isFollowing
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      side: BorderSide(
                        color: _isFollowing
                            ? AppColors.border
                            : AppColors.primary,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _toggleFollow,
                  ),
          ),

        const SizedBox(height: 28),

        // ── This week ───────────────────────────────────────────────────
        Text('This week', style: context.text.headlineMedium),
        const SizedBox(height: 12),
        if (p.weeklyPoints == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No activity this week yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else ...[
          _StatRow(
            icon: Icons.military_tech_outlined,
            label: 'Points',
            value: '${p.weeklyPoints}',
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: Icons.quiz_outlined,
            label: 'Quizzes',
            value: '${p.weeklyQuizzes ?? 0}',
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: Icons.movie_outlined,
            label: 'Scenes',
            value: '${p.weeklyScenes ?? 0}',
          ),
        ],

        // ── Interests ───────────────────────────────────────────────────
        if (selectedInterests.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text('Interests', style: context.text.headlineMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedInterests
                .map((i) => Chip(
                      avatar: Icon(InterestIcons.of(i.id), size: 16),
                      label: Text(i.label),
                      backgroundColor: AppColors.primaryLight,
                      side: BorderSide.none,
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ))
                .toList(),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level});
  final String level;

  Color get _color {
    switch (level.toUpperCase()) {
      case 'A1':
      case 'A2':
        return const Color(0xFF22C55E); // green – beginner
      case 'B1':
      case 'B2':
        return AppColors.primary; // indigo – intermediate
      case 'C1':
      case 'C2':
        return const Color(0xFF8B5CF6); // violet – advanced
      default:
        return AppColors.textSecondary;
    }
  }

  String get _sublabel {
    switch (level.toUpperCase()) {
      case 'A1':
        return 'Beginner';
      case 'A2':
        return 'Elementary';
      case 'B1':
        return 'Intermediate';
      case 'B2':
        return 'Upper-Intermediate';
      case 'C1':
        return 'Advanced';
      case 'C2':
        return 'Proficient';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, size: 13, color: _color),
            const SizedBox(width: 4),
            Text(
              '$level · $_sublabel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ],
        ),
      );
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
}
