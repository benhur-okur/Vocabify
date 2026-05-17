import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/quiz_session_controller.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({required this.categoryId, super.key});
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(quizSessionControllerProvider(categoryId));

    return Scaffold(
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(message: '$e'),
          data: (session) {
            if (!session.isComplete) {
              return const LoadingView(message: 'Finalizing…');
            }
            final correct = session.correctCount;
            final total = session.questions.length;
            final pct = (correct / total * 100).round();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    _headline(pct),
                    style: context.text.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight,
                        border: Border.all(color: AppColors.primary, width: 4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$pct%',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Row(label: 'Correct', value: '$correct / $total'),
                  const Divider(height: 24),
                  _Row(label: 'Points earned', value: '+${correct * 10}'),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Back to home',
                    onPressed: () => context.go(Routes.home),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      ref.invalidate(
                          quizSessionControllerProvider(categoryId));
                      context.pushReplacement(
                        '/home/category/$categoryId/quiz/session',
                      );
                    },
                    child: const Text('Try again'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _headline(int pct) {
    if (pct == 100) return 'Perfect!';
    if (pct >= 80) return 'Great job!';
    if (pct >= 60) return 'Good work.';
    if (pct >= 40) return 'Keep going.';
    return "Let's try again.";
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}