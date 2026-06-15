import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp(
        title: 'ObvezaTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}