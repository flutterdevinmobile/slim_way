import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationController = TextEditingController();

  bool _showVerification = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _verificationController.dispose();
    super.dispose();
  }

  void _createAccount() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (mounted) setState(() => _errorMessage = 'auth.error_empty_fields'.tr());
      return;
    }

    context.read<AuthBloc>().add(AuthRegisterRequested('User', email, password));
  }

  void _verifyAccount() {
    final code = _verificationController.text.trim();
    if (code.isEmpty) {
      if (mounted) setState(() => _errorMessage = 'auth.enter_code'.tr());
      return;
    }

    final email = _emailController.text.trim();
    context.read<AuthBloc>().add(AuthVerifyRequested(email, code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          failure: (error) => setState(() => _errorMessage = error.userFriendlyMessage),
          unauthenticated: () {
            // OTP verification is now handled in the background.
            // We don't show the verification UI here.
            /*
            if (!_showVerification && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
              setState(() {
                _showVerification = true;
                _errorMessage = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('auth.code_sent'.tr(args: [_emailController.text]))),
              );
            }
            */
          },
          authenticated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('auth.verified_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final isLoading = state is AuthPrepare;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0F0F), Color(0xFF001A0F)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Sarlavha
                      Text(
                        _showVerification ? 'auth.verify_email'.tr() : 'auth.sign_up'.tr(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showVerification
                            ? 'auth.code_sent'.tr(args: [_emailController.text.trim()])
                            : 'auth.join_slimway'.tr(),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      if (!_showVerification) ...[
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'auth.email'.tr(),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'auth.password_hint'.tr(),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => isLoading ? null : _createAccount(),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _verificationController,
                          maxLength: 5,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 32, letterSpacing: 24, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: '00000',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1), letterSpacing: 24),
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(vertical: 24),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => isLoading ? null : _verifyAccount(),
                        ),
                      ],

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBox(message: _errorMessage!),
                      ],

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : (_showVerification ? _verifyAccount : _createAccount),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const _Spinner()
                              : Text(
                                  _showVerification ? 'common.confirm'.tr() : 'auth.sign_up_action'.tr(),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      if (_showVerification) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() {
                            _showVerification = false;
                            _verificationController.clear();
                            _errorMessage = null;
                          }),
                          child: Text(
                            'auth.change_email'.tr(),
                            style: const TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
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
      height: 22,
      width: 22,
      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
    );
  }
}
