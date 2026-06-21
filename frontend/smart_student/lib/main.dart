import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:smart_student/core/theme/app_theme.dart';
import 'package:smart_student/features/auth/cubit/auth_cubit.dart';
import 'package:smart_student/features/careers/cubit/career_cubit.dart';
import 'package:smart_student/features/home/cubit/dashboard_cubit.dart';
import 'package:smart_student/features/progress/cubit/progress_cubit.dart';
import 'package:smart_student/features/quizzes/cubit/quiz_cubit.dart';
import 'package:smart_student/features/stories/cubit/story_cubit.dart';
import 'package:smart_student/firebase_options.dart';
import 'package:smart_student/injection.dart';
import 'package:smart_student/router.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash on screen while Firebase, dependencies and the
  // stored-session check complete, so there is no white flash before routing.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencies();

  final authCubit = getIt<AuthCubit>();
  // Resolve the logged-in state up front so the very first frame is the
  // correct destination (Home for signed-in users, Login otherwise).
  await authCubit.checkAuthStatus();
  getIt<ProgressCubit>().load();

  runApp(SmartStudentApp(authCubit: authCubit));
}

class SmartStudentApp extends StatefulWidget {
  final AuthCubit authCubit;

  const SmartStudentApp({super.key, required this.authCubit});

  @override
  State<SmartStudentApp> createState() => _SmartStudentAppState();
}

class _SmartStudentAppState extends State<SmartStudentApp> {
  late final _router = createRouter(widget.authCubit);

  @override
  void initState() {
    super.initState();
    // First frame is the resolved destination, so it's safe to drop the
    // native splash now.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authCubit),
        BlocProvider.value(value: getIt<ProgressCubit>()),
        BlocProvider(create: (_) => getIt<DashboardCubit>()),
        BlocProvider(create: (_) => getIt<CareerCubit>()),
        BlocProvider(create: (_) => getIt<StoryCubit>()),
        BlocProvider(create: (_) => getIt<QuizCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Smart Student',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
