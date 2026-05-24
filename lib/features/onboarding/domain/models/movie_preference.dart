import 'package:flutter/foundation.dart';

enum MovieType { movie, series }

@immutable
class MoviePreference {
  const MoviePreference({
    required this.id,
    required this.title,
    required this.type,
    required this.year,
  });
  final String id;
  final String title;
  final MovieType type;
  final int year;
}

const mockMoviePreferences = <MoviePreference>[
  MoviePreference(id: 'mr_robot', title: 'Mr. Robot', type: MovieType.series, year: 2015),
  MoviePreference(id: 'breaking_bad', title: 'Breaking Bad', type: MovieType.series, year: 2008),
  MoviePreference(id: 'the_office', title: 'The Office', type: MovieType.series, year: 2005),
  MoviePreference(id: 'friends', title: 'Friends', type: MovieType.series, year: 1994),
  MoviePreference(id: 'stranger_things', title: 'Stranger Things', type: MovieType.series, year: 2016),
  MoviePreference(id: 'succession', title: 'Succession', type: MovieType.series, year: 2018),
  MoviePreference(id: 'ted_lasso', title: 'Ted Lasso', type: MovieType.series, year: 2020),
  MoviePreference(id: 'inception', title: 'Inception', type: MovieType.movie, year: 2010),
  MoviePreference(id: 'interstellar', title: 'Interstellar', type: MovieType.movie, year: 2014),
  MoviePreference(id: 'black_mirror', title: 'Black Mirror', type: MovieType.series, year: 2011),
];