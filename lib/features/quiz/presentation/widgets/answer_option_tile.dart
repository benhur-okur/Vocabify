import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum AnswerTileState { idle, correct, wrong, revealCorrect }

class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    required this.label,
    required this.state,
    required this.onTap,
    super.key,
  });

  final String label;
  final AnswerTileState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    IconData? icon;

    switch (state) {
      case AnswerTileState.idle:
        bg = AppColors.surface;
        border = AppColors.border;
        icon = null;
        break;
      case AnswerTileState.correct:
      case AnswerTileState.revealCorrect:
        bg = AppColors.correctAnswer;
        border = AppColors.correctAnswerBorder;
        icon = Icons.check_circle_rounded;
        break;
      case AnswerTileState.wrong:
        bg = AppColors.wrongAnswer;
        border = AppColors.wrongAnswerBorder;
        icon = Icons.cancel_rounded;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
              if (icon != null) Icon(icon, color: border, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}