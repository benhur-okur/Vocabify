import 'package:flutter/material.dart';
import 'package:vocabify/core/constants/app_strings.dart';
import 'package:vocabify/features/onboarding/presentation/interest_selection_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _goToNext(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InterestSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _goToNext(context),
                          child: const Text(AppStrings.skipText),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFDCEBFF),
                              Color(0xFFEFF6FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            size: 96,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        AppStrings.onboardingTitle,
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.onboardingSubtitle,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          _TagChip(label: 'Movies & TV'),
                          _TagChip(label: 'Category Quizzes'),
                          _TagChip(label: 'Subtitle Learning'),
                          _TagChip(label: 'Weekly Tests'),
                          _TagChip(label: 'Ranking'),
                          _TagChip(label: 'Personalized Path'),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _goToNext(context),
                        child: const Text(AppStrings.continueText),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}