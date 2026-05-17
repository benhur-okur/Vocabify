import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class SubtitleCard extends StatelessWidget {
  const SubtitleCard({
    required this.subtitle,
    required this.focusTerm,
    super.key,
  });

  final String subtitle;
  final String focusTerm;

  @override
  Widget build(BuildContext context) {
    final parts = _split(subtitle, focusTerm);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
          children: [
            TextSpan(text: parts[0]),
            TextSpan(
              text: parts[1],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
            TextSpan(text: parts[2]),
          ],
        ),
      ),
    );
  }

  List<String> _split(String full, String term) {
    final lower = full.toLowerCase();
    final idx = lower.indexOf(term.toLowerCase());
    if (idx < 0) return [full, '', ''];
    return [
      full.substring(0, idx),
      full.substring(idx, idx + term.length),
      full.substring(idx + term.length),
    ];
  }
}