import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        print(
          'DEBUG: AuthGate - initialized: ${appState.sessionInitialized}, signedIn: ${appState.isSignedIn}, hasProfile: ${appState.currentUser != null}',
        );

        // 1. Splash should be handled by SplashScreen, but if we land here and not ready:
        if (!appState.sessionInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Critical error (server down)
        if (appState.initializationError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text('Failed to connect to server'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => appState.retryInit(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Main Navigation Logic
        // Flow: If Signed In AND has Profile -> Home
        //       Else if Not Signed In -> Login
        //       Else if Signed In BUT No Profile -> Profile Setup

        if (!appState.isSignedIn) {
          return const LoginScreen();
        }

        if (appState.currentUser == null) {
          if (appState.isLoading) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Fetching profile...'),
                  ],
                ),
              ),
            );
          }
          // Signed in but no profile record yet -> Go to ProfileScreen for setup
          return const ProfileScreen();
        }

        // Fully ready
        return const MainScreen();
      },
    );
  }
}
