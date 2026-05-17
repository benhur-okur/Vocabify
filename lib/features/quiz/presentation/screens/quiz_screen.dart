import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../application/quiz_session_controller.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/quiz_progress_indicator.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({required this.categoryId, super.key});
  final String categoryId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _pendingSelection;
  bool _locked = false;
  Timer? _advanceTimer;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _select(int index) {
    if (_locked) return;
    setState(() {
      _pendingSelection = index;
      _locked = true;
    });

    _advanceTimer = Timer(AppConstants.feedbackDisplayDuration, () {
      if (!mounted) return;
      ref
          .read(quizSessionControllerProvider(widget.categoryId).notifier)
          .answer(index);

      final session =
          ref.read(quizSessionControllerProvider(widget.categoryId)).valueOrNull;
      if (session != null && session.isComplete) {
        context.pushReplacement(
          '/home/category/${widget.categoryId}/quiz/result',
        );
      } else {
        setState(() {
          _pendingSelection = null;
          _locked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync =
        ref.watch(quizSessionControllerProvider(widget.categoryId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const LoadingView(message: 'Preparing quiz…'),
          error: (e, _) => ErrorView(message: '$e'),
          data: (session) {
            final q = session.questions[session.currentIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuizProgressIndicator(
                    current: session.currentIndex,
                    total: session.questions.length,
                  ),
                  const SizedBox(height: 24),
                  Text('What does this mean?',
                      style: context.text.labelLarge),
                  const SizedBox(height: 8),
                  Text(q.prompt, style: context.text.displayLarge),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: q.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final tileState = _stateFor(
                          index: i,
                          correctIndex: q.correctIndex,
                        );
                        return AnswerOptionTile(
                          label: q.options[i],
                          state: tileState,
                          onTap: _locked ? null : () => _select(i),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  AnswerTileState _stateFor({required int index, required int correctIndex}) {
    if (_pendingSelection == null) return AnswerTileState.idle;
    if (index == _pendingSelection && index == correctIndex) {
      return AnswerTileState.correct;
    }
    if (index == _pendingSelection && index != correctIndex) {
      return AnswerTileState.wrong;
    }
    if (_pendingSelection != correctIndex && index == correctIndex) {
      return AnswerTileState.revealCorrect;
    }
    return AnswerTileState.idle;
  }

  Future<void> _confirmExit(BuildContext context) async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave quiz?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep going')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave')),
        ],
      ),
    );
    if (exit == true && context.mounted) context.pop();
  }
}