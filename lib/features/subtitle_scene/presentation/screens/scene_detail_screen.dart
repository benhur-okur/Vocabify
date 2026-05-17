import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/analytics/analytics_event.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/models/cefr_level.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../vocabulary/application/skill_tracker.dart';
import '../../../vocabulary/data/mock/mock_words.dart';
import '../../../vocabulary/domain/models/vocabulary_word.dart';
import '../../../weekly_test/data/weekly_stats_repository.dart';
import '../../application/playability_registry.dart';
import '../../application/scene_controller.dart';
import '../../domain/services/scene_matcher.dart';
import '../widgets/video_scene_player.dart';

class SceneDetailScreen extends ConsumerStatefulWidget {
  const SceneDetailScreen({required this.sceneId, super.key});
  final String sceneId;

  @override
  ConsumerState<SceneDetailScreen> createState() => _SceneDetailScreenState();
}

class _SceneDetailScreenState extends ConsumerState<SceneDetailScreen> {
  final _playerKey = GlobalKey<VideoScenePlayerState>();

  bool _answered = false;
  bool _answeredCorrect = false;
  int? _selectedOption;
  List<String>? _options;
  int? _correctIndex;

  @override
  Widget build(BuildContext context) {
    final scoredList = ref.watch(scoredScenesProvider);
    ref.watch(playabilityRegistryProvider); // rebuild when status flips

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: scoredList.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(message: '$e'),
          data: (list) {
            final index = list.indexWhere((s) => s.scene.id == widget.sceneId);
            if (index < 0) {
              return const Center(child: Text('Scene not found.'));
            }
            final item = list[index];
            final scene = item.scene;
            final nextItem =
                index + 1 < list.length ? list[index + 1] : null;

            // Find the next scene in the feed that isn't known-blocked.
            // Useful as a "try another playable one" shortcut.
            final nextPlayable = _findNextPlayable(list, index);

            _options ??= _buildOptions(scene.focusWord.term);
            _correctIndex ??= _options!.indexOf(scene.focusWord.meaning);

            final playability = ref
                .read(playabilityRegistryProvider.notifier)
                .get(scene.source.youtubeVideoId);

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 4),
                _TitleRow(item: item, playability: playability),
                const SizedBox(height: 16),
                VideoScenePlayer(
                  key: _playerKey,
                  videoId: scene.source.youtubeVideoId,
                  startMs: scene.startMs,
                  endMs: scene.endMs,
                  subtitle: scene.subtitle,
                ),
                const SizedBox(height: 16),
                _WhyThisSceneCard(item: item),
                const SizedBox(height: 16),
                _SubtitleSnippetCard(
                  subtitle: scene.subtitle,
                  focusTerm: scene.focusWord.term,
                ),
                const SizedBox(height: 20),
                _FocusWordQuiz(
                  focusTerm: scene.focusWord.term,
                  options: _options!,
                  correctIndex: _correctIndex!,
                  selectedOption: _selectedOption,
                  answered: _answered,
                  onSelect: _handleAnswer,
                ),
                if (_answered) ...[
                  const SizedBox(height: 16),
                  _MeaningPanel(
                    term: scene.focusWord.term,
                    meaning: scene.focusWord.meaning,
                    context: scene.focusWord.contextExplanation,
                  ),
                ],
                const SizedBox(height: 24),
                _ActionRow(
                  playability: playability,
                  canReplay: playability == Playability.playable,
                  canTryAnother: nextPlayable != null,
                  nextLabel: nextItem == null ? 'Done' : 'Next scene',
                  onReplay: () => _playerKey.currentState?.replay(),
                  onTryAnother: nextPlayable == null
                      ? null
                      : () {
                          _resetForNextScene();
                          context.pushReplacement(
                              '/home/scenes/${nextPlayable.scene.id}');
                        },
                  onNext: () {
                    if (nextItem == null) {
                      context.pop();
                      return;
                    }
                    _resetForNextScene();
                    context.pushReplacement(
                        '/home/scenes/${nextItem.scene.id}');
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  ScoredScene? _findNextPlayable(List<ScoredScene> list, int fromIndex) {
    final registry = ref.read(playabilityRegistryProvider.notifier);
    for (var i = fromIndex + 1; i < list.length; i++) {
      final vid = list[i].scene.source.youtubeVideoId;
      final status = registry.get(vid);
      if (status != Playability.blocked) return list[i];
    }
    // Also look backwards, in case the user has already walked past the
    // playable ones.
    for (var i = fromIndex - 1; i >= 0; i--) {
      final vid = list[i].scene.source.youtubeVideoId;
      final status = registry.get(vid);
      if (status == Playability.playable) return list[i];
    }
    return null;
  }

  List<String> _buildOptions(String term) {
    final word = mockWords.firstWhere(
      (w) => w.term.toLowerCase() == term.toLowerCase(),
      orElse: () => _fallbackWord(term),
    );
    final level = word.cefrLevel;
    final distractors = mockWords
        .where((w) =>
            w.id != word.id &&
            (w.cefrLevel.rank - level.rank).abs() <= 1)
        .map((w) => w.meaning)
        .toList();
    distractors.shuffle();
    final options = [
      word.meaning,
      ...distractors.take(3),
    ]..shuffle();
    return options;
  }

  VocabularyWord _fallbackWord(String term) {
    return VocabularyWord(
      id: 'synth_${term.hashCode}',
      term: term,
      meaning: 'the ${term.toLowerCase()}',
      exampleSentence: '',
      categoryId: 'daily',
      difficulty: WordDifficulty.medium,
      cefrLevel: CefrLevel.b1,
      tags: const [],
    );
  }

  void _handleAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      _answeredCorrect = index == _correctIndex;
    });

    ref.read(skillTrackerProvider.notifier).registerAnswer(
          correct: _answeredCorrect,
          responseMs: 0,
        );

    if (_answeredCorrect) {
      ref.read(weeklyStatsRepositoryProvider).recordSceneCompletion();
      final list = ref.read(scoredScenesProvider).valueOrNull ?? const [];
      final scene = list
          .firstWhere(
            (s) => s.scene.id == widget.sceneId,
            orElse: () => list.isEmpty
                ? (throw StateError('empty feed'))
                : list.first,
          )
          .scene;
      ref.read(analyticsServiceProvider).track(
            WordMarkedKnown(
              wordId: scene.focusWord.term,
              source: 'scene',
            ),
          );
      context.showSnack('+5 points — added to your learned words');
    }
  }

  void _resetForNextScene() {
    _answered = false;
    _answeredCorrect = false;
    _selectedOption = null;
    _options = null;
    _correctIndex = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.item, required this.playability});
  final ScoredScene item;
  final Playability playability;

  @override
  Widget build(BuildContext context) {
    final vocab = mockWords.firstWhere(
      (w) => w.term.toLowerCase() == item.scene.focusWord.term.toLowerCase(),
      orElse: () => const VocabularyWord(
        id: '',
        term: '',
        meaning: '',
        exampleSentence: '',
        categoryId: '',
        difficulty: WordDifficulty.medium,
        cefrLevel: CefrLevel.b1,
        tags: [],
      ),
    );
    final level = vocab.id.isEmpty ? null : vocab.cefrLevel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.scene.movieTitle, style: context.text.titleLarge),
              Row(
                children: [
                  Text(item.scene.timestampLabel,
                      style: context.text.labelSmall),
                  const SizedBox(width: 8),
                  _PlayabilityDot(status: playability),
                ],
              ),
            ],
          ),
        ),
        if (level != null) _CefrChip(level: level),
      ],
    );
  }
}

class _PlayabilityDot extends StatelessWidget {
  const _PlayabilityDot({required this.status});
  final Playability status;

  @override
  Widget build(BuildContext context) {
    late Color dot;
    late String label;
    switch (status) {
      case Playability.playable:
        dot = AppColors.success;
        label = 'embed ok';
        break;
      case Playability.probing:
        dot = Colors.amber;
        label = 'checking';
        break;
      case Playability.blocked:
        dot = AppColors.error;
        label = 'transcript only';
        break;
      case Playability.unknown:
        dot = AppColors.textTertiary;
        label = 'pending';
        break;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                context.text.labelSmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _CefrChip extends StatelessWidget {
  const _CefrChip({required this.level});
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level.label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _WhyThisSceneCard extends StatelessWidget {
  const _WhyThisSceneCard({required this.item});
  final ScoredScene item;

  @override
  Widget build(BuildContext context) {
    if (item.reasons.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Why this scene: ${item.reasons.join(" · ")}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtitleSnippetCard extends StatelessWidget {
  const _SubtitleSnippetCard({
    required this.subtitle,
    required this.focusTerm,
  });
  final String subtitle;
  final String focusTerm;

  @override
  Widget build(BuildContext context) {
    final parts = _splitAroundTerm(subtitle, focusTerm);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          children: [
            TextSpan(text: parts[0]),
            TextSpan(
              text: parts[1],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
            TextSpan(text: parts[2]),
          ],
        ),
      ),
    );
  }

  List<String> _splitAroundTerm(String full, String term) {
    final lower = full.toLowerCase();
    final idx = lower.indexOf(term.toLowerCase());
    if (idx < 0) return [full, '', ''];
    return [
      full.substring(0, idx),
      full.substring(idx, idx + term.length),
      full.substring(idx + term.length),
    ];
  }
}

class _FocusWordQuiz extends StatelessWidget {
  const _FocusWordQuiz({
    required this.focusTerm,
    required this.options,
    required this.correctIndex,
    required this.selectedOption,
    required this.answered,
    required this.onSelect,
  });

  final String focusTerm;
  final List<String> options;
  final int correctIndex;
  final int? selectedOption;
  final bool answered;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What does this mean?', style: context.text.labelLarge),
        const SizedBox(height: 4),
        Text('"$focusTerm"',
            style: context.text.displayMedium
                ?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 12),
        ...List.generate(options.length, (i) {
          final isSelected = selectedOption == i;
          final isCorrect = i == correctIndex;
          Color bg = AppColors.surface;
          Color border = AppColors.border;
          IconData? icon;
          if (answered) {
            if (isCorrect) {
              bg = AppColors.correctAnswer;
              border = AppColors.correctAnswerBorder;
              icon = Icons.check_circle_rounded;
            } else if (isSelected) {
              bg = AppColors.wrongAnswer;
              border = AppColors.wrongAnswerBorder;
              icon = Icons.cancel_rounded;
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: answered ? null : () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(options[i],
                            style: const TextStyle(fontSize: 15)),
                      ),
                      if (icon != null)
                        Icon(icon, color: border, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MeaningPanel extends StatelessWidget {
  const _MeaningPanel({
    required this.term,
    required this.meaning,
    required this.context,
  });
  final String term;
  final String meaning;
  final String context;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(term,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              )),
          const SizedBox(height: 6),
          Text(meaning, style: const TextStyle(fontSize: 16, height: 1.4)),
          if (context.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('IN CONTEXT',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                )),
            const SizedBox(height: 4),
            Text('"$context"',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                )),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.playability,
    required this.canReplay,
    required this.canTryAnother,
    required this.nextLabel,
    required this.onReplay,
    required this.onTryAnother,
    required this.onNext,
  });

  final Playability playability;
  final bool canReplay;
  final bool canTryAnother;
  final String nextLabel;
  final VoidCallback onReplay;
  final VoidCallback? onTryAnother;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Replay'),
                onPressed: canReplay ? onReplay : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: nextLabel,
                onPressed: onNext,
              ),
            ),
          ],
        ),
        if (playability == Playability.blocked && canTryAnother) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.shuffle_rounded),
              label: const Text('Try another playable scene'),
              onPressed: onTryAnother,
            ),
          ),
        ],
      ],
    );
  }
}