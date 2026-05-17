import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              const Text('📚', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              Text('Learn vocabulary\nthat fits you.',
                  style: context.text.displayLarge),
              const SizedBox(height: 16),
              Text(
                "Pick what you love — tech, cinema, travel — and we'll turn it into words you'll actually remember.",
                style: context.text.bodyLarge,
              ),
              const Spacer(flex: 3),
              PrimaryButton(
                label: 'Get started',
                onPressed: () => context.push(Routes.onboardingInterests),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}