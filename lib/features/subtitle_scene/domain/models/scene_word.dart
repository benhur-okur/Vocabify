import 'package:flutter/foundation.dart';

@immutable
class SceneWord {
  const SceneWord({
    required this.term,
    required this.meaning,
    required this.contextExplanation,
  });
  final String term;
  final String meaning;
  final String contextExplanation;
}