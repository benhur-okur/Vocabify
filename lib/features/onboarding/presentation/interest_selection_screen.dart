import 'package:flutter/material.dart';
import 'package:vocabify/core/widgets/app_back_button.dart';
import 'package:vocabify/features/onboarding/presentation/entertainment_preferences_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final List<String> _allInterests = const [
    'Technology',
    'Business',
    'Travel',
    'Science',
    'Gaming',
    'Sports',
    'Music',
    'Movies',
    'TV Series',
    'History',
    'Psychology',
    'Art',
  ];

  final Set<String> _selectedInterests = {};

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _goToNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntertainmentPreferencesScreen(
          selectedInterests: _selectedInterests.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canContinue = _selectedInterests.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Choose your interests'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a few topics to personalize your vocabulary journey.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);

                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (_) => _toggleInterest(interest),
                        selectedColor: const Color(0xFFDCEBFF),
                        checkmarkColor: const Color(0xFF2563EB),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: canContinue ? _goToNext : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}