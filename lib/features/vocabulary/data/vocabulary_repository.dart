import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/category.dart';
import '../domain/models/vocabulary_word.dart';
import 'mock/mock_categories.dart';
import 'mock/mock_words.dart';

abstract class VocabularyRepository {
  Future<List<Category>> fetchCategories();
  Future<List<VocabularyWord>> fetchWordsForCategory(String categoryId);
}

class MockVocabularyRepository implements VocabularyRepository {
  @override
  Future<List<Category>> fetchCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return mockCategories;
  }

  @override
  Future<List<VocabularyWord>> fetchWordsForCategory(String categoryId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return mockWords.where((w) => w.categoryId == categoryId).toList();
  }
}

final vocabularyRepositoryProvider =
    Provider<VocabularyRepository>((ref) => MockVocabularyRepository());

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(vocabularyRepositoryProvider).fetchCategories();
});

final wordsForCategoryProvider =
    FutureProvider.family<List<VocabularyWord>, String>((ref, categoryId) {
  return ref.watch(vocabularyRepositoryProvider).fetchWordsForCategory(categoryId);
});