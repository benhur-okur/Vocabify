import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../subtitle_scene/application/scene_controller.dart';
import '../../application/onboarding_controller.dart';
import '../../domain/models/movie_preference.dart';

class EditMoviesScreen extends ConsumerWidget {
  const EditMoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(onboardingControllerProvider).selectedMovieIds;
    final ctrl = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit movies & shows')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Text(
                    'Tap to add or remove titles.',
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ...mockMoviePreferences.map((movie) {
                    final isSelected = selected.contains(movie.id);
                    return _MovieTile(
                      movie: movie,
                      selected: isSelected,
                      onTap: () => ctrl.toggleMovie(movie.id),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: 'Save',
                onPressed: selected.isNotEmpty
                    ? () async {
                        await ctrl.saveSelections();
                        ref.invalidate(scoredScenesProvider);
                        if (context.mounted) {
                          context.showSnack('Movies & shows updated');
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieTile extends StatelessWidget {
  const _MovieTile({
    required this.movie,
    required this.selected,
    required this.onTap,
  });
  final MoviePreference movie;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    movie.type == MovieType.series
                        ? Icons.tv_rounded
                        : Icons.movie_rounded,
                    size: 22,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${movie.year} · ${movie.type == MovieType.series ? 'Series' : 'Movie'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: selected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 22,
                            key: ValueKey('check'))
                        : const Icon(Icons.circle_outlined,
                            color: AppColors.textTertiary, size: 22,
                            key: ValueKey('empty')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
