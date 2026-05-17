import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../application/playability_registry.dart';
import '../../application/scene_controller.dart';

class SceneListScreen extends ConsumerWidget {
  const SceneListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoredAsync = ref.watch(scoredScenesProvider);
    ref.watch(playabilityRegistryProvider); // rebuild on status changes
    final registry = ref.read(playabilityRegistryProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Scenes for you')),
      body: SafeArea(
        child: scoredAsync.when(
          loading: () => const LoadingView(message: 'Matching scenes…'),
          error: (e, _) => ErrorView(message: '$e'),
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.movie_filter_outlined,
                          size: 56, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text(
                        "No scenes matched your interests and level yet.",
                        style: context.text.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = list[i];
                final status =
                    registry.get(item.scene.source.youtubeVideoId);

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context
                          .push('/home/scenes/${item.scene.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _PlayabilityIcon(status: status),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(item.scene.movieTitle,
                                      style: context.text.titleMedium),
                                ),
                                Text(item.scene.timestampLabel,
                                    style: context.text.labelSmall),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"${item.scene.subtitle}"',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _Badge(
                                  text: item.scene.focusWord.term,
                                  bg: AppColors.primary,
                                  fg: Colors.white,
                                ),
                                ...item.reasons.take(2).map((r) => _Badge(
                                      text: r,
                                      bg: AppColors.primaryLight,
                                      fg: AppColors.primary,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PlayabilityIcon extends StatelessWidget {
  const _PlayabilityIcon({required this.status});
  final Playability status;

  @override
  Widget build(BuildContext context) {
    late IconData icon;
    late Color color;
    switch (status) {
      case Playability.playable:
        icon = Icons.play_circle_fill;
        color = AppColors.success;
        break;
      case Playability.probing:
        icon = Icons.hourglass_bottom_rounded;
        color = Colors.amber;
        break;
      case Playability.blocked:
        icon = Icons.subtitles_rounded;
        color = AppColors.textSecondary;
        break;
      case Playability.unknown:
        icon = Icons.play_circle_outline;
        color = AppColors.textTertiary;
        break;
    }
    return Icon(icon, color: color, size: 18);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}