import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/scene_word.dart';

class FocusWordPanel extends StatelessWidget {
  const FocusWordPanel({required this.word, super.key});
  final SceneWord word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FOCUS WORD',
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(word.term,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(word.meaning, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          const Text('IN CONTEXT',
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(word.contextExplanation,
              style: const TextStyle(fontSize: 14, height: 1.45)),
        ],
      ),
    );
  }
}