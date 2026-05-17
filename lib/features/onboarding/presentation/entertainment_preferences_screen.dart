import 'package:flutter/material.dart';
import 'package:vocabify/core/widgets/app_back_button.dart';
import 'package:vocabify/features/shell/presentation/app_shell.dart';

class EntertainmentPreferencesScreen extends StatefulWidget {
  final List<String> selectedInterests;

  const EntertainmentPreferencesScreen({
    super.key,
    required this.selectedInterests,
  });

  @override
  State<EntertainmentPreferencesScreen> createState() =>
      _EntertainmentPreferencesScreenState();
}

class _EntertainmentPreferencesScreenState
    extends State<EntertainmentPreferencesScreen> {
  final TextEditingController _favoritesController = TextEditingController();

  @override
  void dispose() {
    _favoritesController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Movies & series preferences'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us what you like to watch so we can shape future subtitle and scene-based learning experiences.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Text(
                'Selected interests',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.selectedInterests
                    .map((item) => Chip(label: Text(item)))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Favorite movies, series, or genres',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _favoritesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Example: Interstellar, Dark, Breaking Bad, sci-fi, crime, fantasy...',
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _finishOnboarding,
                child: const Text('Finish onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}