import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/application/onboarding_controller.dart';
import '../../features/onboarding/presentation/screens/edit_interests_screen.dart';
import '../../features/onboarding/presentation/screens/edit_movies_screen.dart';
import '../../features/onboarding/presentation/screens/interest_selection_screen.dart';
import '../../features/onboarding/presentation/screens/movie_preference_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/quiz/presentation/screens/quiz_intro_screen.dart';
import '../../features/quiz/presentation/screens/quiz_result_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/ranking/presentation/screens/ranking_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/subtitle_scene/presentation/screens/scene_detail_screen.dart';
import '../../features/subtitle_scene/presentation/screens/scene_list_screen.dart';
import '../../features/user_profile/presentation/screens/profile_screen.dart';
import '../../features/weekly_test/presentation/screens/weekly_test_screen.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final completed = ref.read(onboardingControllerProvider).isCompleted;
      final loc = state.matchedLocation;
      final goingToOnboarding = loc.startsWith('/onboarding');
      final atSplash = loc == Routes.splash;

      if (!completed && !goingToOnboarding) {
        return Routes.onboardingWelcome;
      }
      if (completed && (goingToOnboarding || atSplash)) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: Routes.onboardingWelcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.onboardingInterests,
        builder: (_, __) => const InterestSelectionScreen(),
      ),
      GoRoute(
        path: Routes.onboardingMovies,
        builder: (_, __) => const MoviePreferenceScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.home,
              builder: (_, __) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'category/:categoryId/quiz',
                  builder: (_, st) => QuizIntroScreen(
                    categoryId: st.pathParameters['categoryId']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'session',
                      builder: (_, st) => QuizScreen(
                        categoryId: st.pathParameters['categoryId']!,
                      ),
                    ),
                    GoRoute(
                      path: 'result',
                      builder: (_, st) => QuizResultScreen(
                        categoryId: st.pathParameters['categoryId']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'scenes',
                  builder: (_, __) => const SceneListScreen(),
                  routes: [
                    GoRoute(
                      path: ':sceneId',
                      builder: (_, st) => SceneDetailScreen(
                        sceneId: st.pathParameters['sceneId']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.weeklyTest,
              builder: (_, __) => const WeeklyTestScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.ranking,
              builder: (_, __) => const RankingScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.profile,
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit-interests',
                  builder: (_, __) => const EditInterestsScreen(),
                ),
                GoRoute(
                  path: 'edit-movies',
                  builder: (_, __) => const EditMoviesScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});