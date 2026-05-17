import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/onboarding_controller.dart';
import '../../domain/models/interest_category.dart';
import '../widgets/interest_card.dart';
import '../widgets/onboarding_progress_bar.dart';
import '../widgets/swipe_card_deck.dart';

class InterestSelectionScreen extends ConsumerStatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  ConsumerState<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState
    extends ConsumerState<InterestSelectionScreen> {
  final _deckKey = GlobalKey<SwipeCardDeckState>();
  late final List<InterestCategory> _deck;

  @override
  void initState() {
    super.initState();
    // Shuffle copy for a fresh feel each time but deterministic within session.
    _deck = [...onboardingInterests]..shuffle();
  }

  void _onSwipe(int index, SwipeDirection dir) {
    if (dir == SwipeDirection.right) {
      ref
          .read(onboardingControllerProvider.notifier)
          .toggleInterest(_deck[index].id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final ctrl = ref.read(onboardingControllerProvider.notifier);
    final count = onboarding.selectedInterestIds.length;
    final canContinue = ctrl.canProceedFromInterests;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: OnboardingProgressBar(currentStep: 1, totalSteps: 2),
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
                child: Text('What interests you?',
                    style: context.text.displayMedium),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Swipe through what catches your eye. Pick at least ${AppConstants.minInterestsToProceed}.',
                  style: context.text.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SwipeCardDeck(
                  key: _deckKey,
                  itemCount: _deck.length,
                  onSwipe: _onSwipe,
                  cardBuilder: (_, i) => InterestCard(interest: _deck[i]),
                ),
              ),
              const SizedBox(height: 16),
              _ActionRow(
                onSkip: () =>
                    _deckKey.currentState?.swipe(SwipeDirection.left),
                onPick: () =>
                    _deckKey.currentState?.swipe(SwipeDirection.right),
              ),
              const SizedBox(height: 16),
              Text('$count selected', style: context.text.labelMedium),
              const SizedBox(height: 8),
              PrimaryButton(
                label:
                    canContinue ? 'Continue' : 'Pick ${AppConstants.minInterestsToProceed - count} more',
                onPressed: canContinue
                    ? () => context.push(Routes.onboardingMovies)
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onSkip, required this.onPick});
  final VoidCallback onSkip;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleBtn(
          onTap: onSkip,
          icon: Icons.close_rounded,
          color: Colors.red.shade400,
        ),
        const SizedBox(width: 40),
        _CircleBtn(
          onTap: onPick,
          icon: Icons.favorite_rounded,
          color: AppColors.primary,
        ),
      ],
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