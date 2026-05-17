import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../vocabulary/data/vocabulary_repository.dart';

class QuizIntroScreen extends ConsumerWidget {
  const QuizIntroScreen({required this.categoryId, super.key});
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: categoriesAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(message: '$e'),
            data: (cats) {
              final cat = cats.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => cats.first,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(cat.emoji, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  Text(cat.name, style: context.text.displayMedium),
                  const SizedBox(height: 8),
                  Text(cat.description, style: context.text.bodyLarge),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Start quiz',
                    onPressed: () => context.push(
                      '/home/category/$categoryId/quiz/session',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}