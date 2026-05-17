import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/onboarding_controller.dart';
import '../../domain/models/movie_preference.dart';
import '../widgets/movie_card.dart';
import '../widgets/onboarding_progress_bar.dart';
import '../widgets/swipe_card_deck.dart';

class MoviePreferenceScreen extends ConsumerStatefulWidget {
  const MoviePreferenceScreen({super.key});

  @override
  ConsumerState<MoviePreferenceScreen> createState() =>
      _MoviePreferenceScreenState();
}

class _MoviePreferenceScreenState
    extends ConsumerState<MoviePreferenceScreen> {
  final _deckKey = GlobalKey<SwipeCardDeckState>();
  late final List<MoviePreference> _deck;

  @override
  void initState() {
    super.initState();
    _deck = [...mockMoviePreferences]..shuffle();
  }

  void _onSwipe(int index, SwipeDirection dir) {
    if (dir == SwipeDirection.right) {
      ref
          .read(onboardingControllerProvider.notifier)
          .toggleMovie(_deck[index].id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final ctrl = ref.read(onboardingControllerProvider.notifier);
    final count = onboarding.selectedMovieIds.length;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: OnboardingProgressBar(currentStep: 2, totalSteps: 2),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Favorite shows & films?',
                    style: context.text.displayMedium),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Swipe right on the ones you love. We'll pull vocabulary from their scenes.",
                  style: context.text.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SwipeCardDeck(
                  key: _deckKey,
                  itemCount: _deck.length,
                  onSwipe: _onSwipe,
                  cardBuilder: (_, i) => MovieCard(movie: _deck[i]),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleBtn(
                    onTap: () =>
                        _deckKey.currentState?.swipe(SwipeDirection.left),
                    icon: Icons.close_rounded,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 40),
                  _CircleBtn(
                    onTap: () =>
                        _deckKey.currentState?.swipe(SwipeDirection.right),
                    icon: Icons.favorite_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('$count selected', style: context.text.labelMedium),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Finish',
                onPressed: ctrl.canFinishOnboarding
                    ? () async {
                        await ctrl.complete();
                        if (context.mounted) context.go(Routes.home);
                      }
                    : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.onTap,
    required this.icon,
    required this.color,
  });
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}