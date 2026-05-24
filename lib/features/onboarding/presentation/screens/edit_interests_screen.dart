import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../subtitle_scene/application/scene_controller.dart';
import '../../application/onboarding_controller.dart';
import '../../domain/models/interest_category.dart';
import '../widgets/interest_card.dart';

class EditInterestsScreen extends ConsumerWidget {
  const EditInterestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(onboardingControllerProvider).selectedInterestIds;
    final ctrl = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit interests')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Text(
                    'Tap to add or remove interests.',
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.55,
                    ),
                    itemCount: onboardingInterests.length,
                    itemBuilder: (_, i) {
                      final interest = onboardingInterests[i];
                      final isSelected = selected.contains(interest.id);
                      return _InterestTile(
                        interest: interest,
                        selected: isSelected,
                        onTap: () => ctrl.toggleInterest(interest.id),
                      );
                    },
                  ),
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
                          context.showSnack('Interests updated');
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

class _InterestTile extends StatelessWidget {
  const _InterestTile({
    required this.interest,
    required this.selected,
    required this.onTap,
  });
  final InterestCategory interest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradient = InterestIcons.gradientOf(interest.id);
    final icon = InterestIcons.of(interest.id);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                )
              : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    icon,
                    size: 26,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    interest.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color:
                          selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
