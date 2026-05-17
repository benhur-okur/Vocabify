// test/features/quiz/quiz_generator_test.dart
   test('generates N questions with 4 options each', () {
     final gen = QuizGenerator(random: Random(42));
     final qs = gen.generate(words: mockWords.take(10).toList(), questionCount: 5);
     expect(qs.length, 5);
     expect(qs.every((q) => q.options.length == 4), true);
     expect(qs.every((q) => q.correctIndex >= 0 && q.correctIndex < 4), true);
   });