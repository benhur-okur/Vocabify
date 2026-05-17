import '../../domain/models/scene_word.dart';
import '../../domain/models/subtitle_scene.dart';

const mockScenes = <SubtitleScene>[
  SubtitleScene(
    id: 'scene_bb_1',
    movieId: 'breaking_bad',
    movieTitle: 'Breaking Bad',
    subtitle: 'I am not in danger. I am the danger.',
    focusWord: SceneWord(
      term: 'danger',
      meaning: 'the possibility of harm',
      contextExplanation:
          'Walter uses "the danger" as a metaphor — he is the source of threat.',
    ),
    timestampLabel: 'S4 · E6',
    videoAssetPath: 'assets/scenes/bb_danger.mp4',
    startSeconds: 0,
    endSeconds: 8,
    taggedWordIds: [],
    topicTags: ['drama'],
  ),
  SubtitleScene(
    id: 'scene_office_1',
    movieId: 'the_office',
    movieTitle: 'The Office',
    subtitle: 'I declare bankruptcy!',
    focusWord: SceneWord(
      term: 'bankruptcy',
      meaning: 'the state of being unable to pay debts',
      contextExplanation:
          '"Declare" here means to formally state something.',
    ),
    timestampLabel: 'S4 · E4',
    videoAssetPath: 'assets/scenes/office_bankruptcy.mp4',
    startSeconds: 0,
    endSeconds: 6,
    taggedWordIds: ['w_biz_5', 'w_biz_6'],
    topicTags: ['business', 'comedy'],
  ),
  SubtitleScene(
    id: 'scene_friends_1',
    movieId: 'friends',
    movieTitle: 'Friends',
    subtitle: 'We were on a break!',
    focusWord: SceneWord(
      term: 'break',
      meaning: 'a temporary pause in a relationship',
      contextExplanation:
          '"On a break" is informal English for a relationship paused.',
    ),
    timestampLabel: 'S3 · E15',
    taggedWordIds: ['w_daily_3'],
    topicTags: ['daily', 'relationships'],
  ),
  SubtitleScene(
    id: 'scene_stranger_1',
    movieId: 'stranger_things',
    movieTitle: 'Stranger Things',
    subtitle: "Friends don't lie.",
    focusWord: SceneWord(
      term: 'lie',
      meaning: 'to say something that is not true',
      contextExplanation: 'A core principle in the show.',
    ),
    timestampLabel: 'S1 · E4',
    taggedWordIds: [],
    topicTags: ['daily'],
  ),
  SubtitleScene(
    id: 'scene_ted_lasso_1',
    movieId: 'ted_lasso',
    movieTitle: 'Ted Lasso',
    subtitle: 'Be curious, not judgmental.',
    focusWord: SceneWord(
      term: 'judgmental',
      meaning: 'quick to form critical opinions',
      contextExplanation: 'Forming opinions before understanding.',
    ),
    timestampLabel: 'S1 · E8',
    taggedWordIds: [],
    topicTags: ['daily', 'sports'],
  ),
  SubtitleScene(
    id: 'scene_inception_1',
    movieId: 'inception',
    movieTitle: 'Inception',
    subtitle: "You mustn't be afraid to dream a little bigger, darling.",
    focusWord: SceneWord(
      term: "mustn't",
      meaning: 'must not; a strong prohibition',
      contextExplanation: 'Contraction used as encouragement here.',
    ),
    timestampLabel: 'Mid-film',
    taggedWordIds: [],
    topicTags: ['cinema'],
  ),
];