import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../data/ranking_repository.dart';
import '../../domain/models/ranking_entry.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(weeklyRankingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: SafeArea(
        child: rankingAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(message: '$e'),
          data: (entries) => ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _Tile(entry: entries[i]),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.entry});
  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isCurrentUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? AppColors.primary : AppColors.border,
          width: isMe ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isMe ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(entry.avatarEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              entry.username,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Text('${entry.points} pts', style: context.text.labelLarge),
        ],
      ),
    );
  }
}