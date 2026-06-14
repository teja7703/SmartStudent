import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/careers/screens/career_detail_screen.dart';
import 'features/careers/screens/careers_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/previous_papers/models/previous_paper_model.dart';
import 'features/previous_papers/screens/previous_paper_detail_screen.dart';
import 'features/previous_papers/screens/previous_paper_levels_screen.dart';
import 'features/previous_papers/screens/previous_paper_list_screen.dart';
import 'features/previous_papers/screens/previous_paper_subjects_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/quizzes/screens/quiz_play_screen.dart';
import 'features/quizzes/screens/quiz_score_screen.dart';
import 'features/quizzes/screens/quizzes_screen.dart';
import 'features/stories/screens/stories_screen.dart';
import 'features/stories/screens/story_detail_screen.dart';
import 'features/study_materials/models/study_material_model.dart';
import 'features/study_materials/screens/study_levels_screen.dart';
import 'features/study_materials/screens/study_material_detail_screen.dart';
import 'features/study_materials/screens/study_material_list_screen.dart';
import 'features/study_materials/screens/subjects_screen.dart';
import 'injection.dart';
import 'shared/screens/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: _AuthRefreshNotifier(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/study-materials',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StudyLevelsScreen(),
            ),
          ),
          GoRoute(
            path: '/quizzes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuizzesScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/study-materials/:level/subjects',
        builder: (context, state) {
          final level = state.pathParameters['level']!;
          return SubjectsScreen(academicLevel: level);
        },
      ),
      GoRoute(
        path: '/study-materials/:level/:subject',
        builder: (context, state) {
          final level = state.pathParameters['level']!;
          final subject = state.pathParameters['subject']!;
          return BlocProvider(
            create: (_) => createStudyMaterialCubit(
              academicLevel: level,
              subject: subject,
            ),
            child: StudyMaterialListScreen(
              academicLevel: level,
              subject: subject,
            ),
          );
        },
      ),
      GoRoute(
        path: '/study-materials/detail/:id',
        builder: (context, state) {
          final material = state.extra as StudyMaterialModel;
          return StudyMaterialDetailScreen(material: material);
        },
      ),
      GoRoute(
        path: '/previous-papers',
        builder: (context, state) => const PreviousPaperLevelsScreen(),
      ),
      GoRoute(
        path: '/previous-papers/:level/subjects',
        builder: (context, state) {
          final level = state.pathParameters['level']!;
          return PreviousPaperSubjectsScreen(academicLevel: level);
        },
      ),
      GoRoute(
        path: '/previous-papers/:level/:subject',
        builder: (context, state) {
          final level = state.pathParameters['level']!;
          final subject = state.pathParameters['subject']!;
          return BlocProvider(
            create: (_) => createPreviousPaperCubit(
              academicLevel: level,
              subject: subject,
            ),
            child: PreviousPaperListScreen(
              academicLevel: level,
              subject: subject,
            ),
          );
        },
      ),
      GoRoute(
        path: '/previous-papers/detail/:id',
        builder: (context, state) {
          final paper = state.extra as PreviousPaperModel;
          return PreviousPaperDetailScreen(paper: paper);
        },
      ),
      GoRoute(
        path: '/careers',
        builder: (context, state) => const CareersScreen(),
      ),
      GoRoute(
        path: '/careers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CareerDetailScreen(careerId: id);
        },
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const StoriesScreen(),
      ),
      GoRoute(
        path: '/stories/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StoryDetailScreen(storyId: id);
        },
      ),
      GoRoute(
        path: '/quizzes/play/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return QuizPlayScreen(quizId: id);
        },
      ),
      GoRoute(
        path: '/quizzes/score',
        builder: (context, state) => const QuizScoreScreen(),
      ),
      GoRoute(
        path: '/coming-soon/:feature',
        builder: (context, state) {
          final feature = state.pathParameters['feature']!
              .split('-')
              .map((w) => w[0].toUpperCase() + w.substring(1))
              .join(' ');
          return ComingSoonScreen(feature: feature);
        },
      ),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(AuthCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}
