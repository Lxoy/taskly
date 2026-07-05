import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/notifications/notification_service.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/screens/app_shell.dart';
import 'package:frontend/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await configureDependencies();

  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM TOKEN: $token');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(const AppStarted()),
      child: MaterialApp(
        title: 'Taskly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthInitial() => const _SplashScreen(),
          AuthAuthenticated() => const _NotificationInitializer(
            child: AppShell(),
          ),
          AuthUnauthenticated() => const LoginScreen(),
          AuthLoading() => const LoginScreen(),
          AuthError() => const LoginScreen(),
        };
      },
    );
  }
}

class _NotificationInitializer extends StatefulWidget {
  final Widget child;

  const _NotificationInitializer({required this.child});

  @override
  State<_NotificationInitializer> createState() =>
      _NotificationInitializerState();
}

class _NotificationInitializerState extends State<_NotificationInitializer> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      sl<NotificationService>().initialize().catchError((error) {
        debugPrint('Notification init failed: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
