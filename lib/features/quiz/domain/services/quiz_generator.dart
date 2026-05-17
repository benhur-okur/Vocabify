import 'dart:math';
import '../../../vocabulary/domain/models/vocabulary_word.dart';
import '../models/quiz_question.dart';

class QuizGenerator {
  QuizGenerator({Random? random}) : _random = random ?? Random();
  final Random _random;

  List<QuizQuestion> generate({
    required List<VocabularyWord> words,
    int questionCount = 10,
  }) {
    if (words.length < 4) {
      throw ArgumentError('Need at least 4 words to build a quiz');
    }
    final pool = [...words]..shuffle(_random);
    final selected = pool.take(questionCount).toList();

    return selected.map((word) {
      final wrong = pool
          .where((w) => w.id != word.id)
          .map((w) => w.meaning)
          .toList()
        ..shuffle(_random);
      final options = [word.meaning, ...wrong.take(3)]..shuffle(_random);
      return QuizQuestion(
        wordId: word.id,
        prompt: word.term,
        options: options,
        correctIndex: options.indexOf(word.meaning),
      );
    }).toList();
  }
}