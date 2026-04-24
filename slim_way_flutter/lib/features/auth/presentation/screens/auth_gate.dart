import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:slim_way_flutter/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:slim_way_flutter/features/home/presentation/screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          prepare: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          authenticated: (user) => const MainScreen(),
          needsSetup: (userInfoId) => ProfileSetupScreen(userInfoId: userInfoId),
          unauthenticated: () => const LoginScreen(),
          failure: (error) => const LoginScreen(),
        );
      },
    );
  }
}
