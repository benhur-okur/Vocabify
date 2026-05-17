import 'package:flutter/foundation.dart';

@immutable
class UserPreferences {
  const UserPreferences({
    required this.selectedInterestIds,
    required this.selectedMovieIds,
  });
  final Set<String> selectedInterestIds;
  final Set<String> selectedMovieIds;
}