import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_student/core/theme/app_theme.dart';
import 'package:smart_student/features/auth/cubit/auth_cubit.dart';
import 'package:smart_student/features/careers/cubit/career_cubit.dart';
import 'package:smart_student/features/home/cubit/dashboard_cubit.dart';
import 'package:smart_student/features/quizzes/cubit/quiz_cubit.dart';
import 'package:smart_student/features/stories/cubit/story_cubit.dart';
import 'package:smart_student/firebase_options.dart';
import 'package:smart_student/injection.dart';
import 'package:smart_student/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupDependencies();

  final authCubit = getIt<AuthCubit>()..checkAuthStatus();

  runApp(SmartStudentApp(authCubit: authCubit));
}

class SmartStudentApp extends StatelessWidget {
  final AuthCubit authCubit;

  const SmartStudentApp({super.key, required this.authCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (_) => getIt<DashboardCubit>()),
        BlocProvider(create: (_) => getIt<CareerCubit>()),
        BlocProvider(create: (_) => getIt<StoryCubit>()),
        BlocProvider(create: (_) => getIt<QuizCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Smart Student',
        theme: AppTheme.lightTheme,
        routerConfig: createRouter(authCubit),
      ),
    );
  }
}
