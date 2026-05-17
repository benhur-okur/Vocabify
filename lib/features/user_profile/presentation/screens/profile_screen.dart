import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/models/cefr_level.dart'; // ← required for `.label`
import '../../../onboarding/domain/models/interest_category.dart';
import '../../../onboarding/presentation/widgets/interest_card.dart';
import '../../../vocabulary/application/skill_tracker.dart';
import '../../application/user_preferences_controller.dart';
import '../widgets/stat_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final profile = ref.watch(learningProfileProvider);
    final skill = ref.watch(skillTrackerProvider);

    final selectedInterests = onboardingInterests
        .where((i) => prefs.selectedInterestIds.contains(i.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
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
            const SizedBox(height: 24),
            Text('Your interests', style: context.text.headlineMedium),
            const SizedBox(height: 8),
            if (selectedInterests.isEmpty)
              const Text('None yet.')
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
          ],
        ),
      ),
    );
  }
}