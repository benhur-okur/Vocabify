import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../data/weekly_stats_repository.dart';
import '../../domain/models/weekly_stats.dart';

class WeeklyTestScreen extends ConsumerWidget {
  const WeeklyTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weeklyStatsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('This week')),
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(message: '$e'),
          data: (stats) => _Body(stats: stats),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.stats});
  final WeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('POINTS THIS WEEK',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('${stats.pointsEarned}',
                  style: context.text.displayLarge
                      ?.copyWith(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.6,
          children: [
            _Box(label: 'Quizzes', value: '${stats.quizzesCompleted}'),
            _Box(label: 'Scenes', value: '${stats.scenesCompleted}'),
            _Box(
              label: 'Accuracy',
              value: stats.totalAnswers == 0
                  ? '–'
                  : '${(stats.accuracy * 100).round()}%',
            ),
            _Box(
              label: 'Answers',
              value: '${stats.correctAnswers}/${stats.totalAnswers}',
            ),
          ],
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.labelMedium),
          const Spacer(),
          Text(value, style: context.text.displayMedium),
        ],
      ),
    );
  }
}