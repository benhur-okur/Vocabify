import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class QuizProgressIndicator extends StatelessWidget {
  const QuizProgressIndicator({
    required this.current,
    required this.total,
    super.key,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (current + 1) / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 6),
        Text('Question ${current + 1} of $total',
            style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}