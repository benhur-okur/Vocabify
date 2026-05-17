import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vocabulary_repository.dart';
import '../domain/models/category.dart';
import '../domain/models/vocabulary_word.dart';

/// Categories are app-wide read-only data — cached via FutureProvider.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(vocabularyRepositoryProvider).fetchCategories();
});

/// Words for a single category. Family parameter = categoryId.
final wordsForCategoryProvider =
    FutureProvider.family<List<VocabularyWord>, String>((ref, categoryId) async {
  return ref.watch(vocabularyRepositoryProvider).fetchWordsForCategory(categoryId);
});