import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/services/mock_data_seeder.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase asynchronously with fast fallback
  try {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_) {
      // Seed starter routes in background if needed
      MockDataSeeder.seedFirestoreIfEmpty();
    }).catchError((e) {
      debugPrint('Firebase init notice: $e');
    });
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  runApp(
    const ProviderScope(
      child: RouteHiveApp(),
    ),
  );
}

class RouteHiveApp extends ConsumerWidget {
  const RouteHiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainNavScreen();
          }
          return const LoginScreen();
        },
        loading: () => const LoginScreen(),
        error: (error, stackTrace) => const LoginScreen(),
      ),
    );
  }
}
