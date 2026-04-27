import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/features/auth/presentation/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (mounted) setState(() => _errorMessage = 'auth.error_empty_fields'.tr());
      return;
    }

    context.read<AuthBloc>().add(AuthLoginRequested(email, password));
  }

  Future<void> _signInWithGoogle() async {
    context.read<AuthBloc>().add(AuthGoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    // Determine theme for modern styling that matches RegisterScreen and standard sizes
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          failure: (error) => setState(() => _errorMessage = error.userFriendlyMessage),
        );
      },
      builder: (context, state) {
        final isLoading = state is AuthPrepare;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Container(
            decoration: isDark ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0F0F), Color(0xFF001A0F)],
              ),
            ) : null,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'auth.welcome_back'.tr(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'auth.sign_in_subtitle'.tr(),
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'auth.email'.tr(),
                          prefixIcon: const Icon(Icons.email_outlined, size: 22),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Parol
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'auth.password'.tr(),
                          prefixIcon: const Icon(Icons.lock_outline, size: 22),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => isLoading ? null : _signIn(),
                      ),

                      // Xato xabari
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBox(message: _errorMessage!),
                      ],

                      const SizedBox(height: 28),

                      // Kirish tugmasi
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const _Spinner()
                              : Text(
                                  'auth.sign_in'.tr(),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ajratgich
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black12,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'common.or'.tr(),
                              style: TextStyle(
                                color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black45,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Google tugmasi
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : Colors.black87,
                            side: BorderSide(
                              color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black26,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const _GoogleIcon(),
                          label: Text(
                            'auth.sign_in_google'.tr(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Ro'yxatdan o'tish
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.no_account'.tr(),
                            style: TextStyle(
                              color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                            child: Text(
                              'auth.sign_up'.tr(),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
