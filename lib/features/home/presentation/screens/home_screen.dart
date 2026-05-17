import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../onboarding/application/onboarding_controller.dart';
import '../../../vocabulary/data/vocabulary_repository.dart';
import '../widgets/category_row.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/scene_recommendation_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(message: '$e'),
          data: (all) {
            final recommended =
                all.where((c) => onboarding.selectedInterestIds.contains(c.id)).toList();
            final others =
                all.where((c) => !onboarding.selectedInterestIds.contains(c.id)).toList();

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const DailyGoalCard(),
                const SizedBox(height: 24),
                const SceneRecommendationCard(),
                const SizedBox(height: 24),
                if (recommended.isNotEmpty) ...[
                  Text('Recommended for you',
                      style: context.text.headlineMedium),
                  const SizedBox(height: 8),
                  ...recommended.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CategoryRow(category: c, recommended: true),
                      )),
                  const SizedBox(height: 24),
                ],
                Text('All categories', style: context.text.headlineMedium),
                const SizedBox(height: 8),
                ...others.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CategoryRow(category: c),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}