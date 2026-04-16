import 'package:flutter/material.dart';
import 'package:serverpod_auth_email_flutter/serverpod_auth_email_flutter.dart';
import 'package:provider/provider.dart';
import '../../main.dart' as main;
import '../providers/app_state.dart';
import '../theme.dart';
import 'profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationController = TextEditingController();

  bool _isLoading = false;
  bool _showVerification = false;
  String? _errorMessage;

  late final EmailAuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = EmailAuthController(main.client.modules.auth);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _verificationController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email va parolni kiriting');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('DEBUG: Requesting account creation for $email');
      final success = await _authController.createAccountRequest(
        'User',
        email,
        password,
      );

      if (success) {
        print('DEBUG: Account request created. Showing verification field.');
        setState(() => _showVerification = true);
      } else {
        print('DEBUG: createAccountRequest returned false (Email likely taken)');
        setState(() => _errorMessage = 'Email allaqachon ro\'yxatdan o\'tgan');
      }
    } catch (e) {
      print('ERROR: Register request exception: $e');
      setState(() => _errorMessage = 'Xato: ${e.toString().split('\n').first}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAccount() async {
    final code = _verificationController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Tasdiqlash kodini kiriting');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      print('DEBUG: Validating account for $email with code $code...');
      final userInfo = await _authController.validateAccount(email, code);

      if (userInfo != null) {
        print('DEBUG: Verification success. Signing in...');
        final signInResult = await _authController.signIn(email, password);
        
        if (signInResult != null) {
          print('DEBUG: Sign in success. Refreshing session...');
          await main.sessionManager.refreshSession();
          
          if (mounted) {
            final appState = context.read<AppState>();
            await appState.fetchUserByAuthId(userInfo.id!);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hisob tasdiqlandi! Profilingizni to\'ldiring.'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
              (route) => false,
            );
          }
        } else {
          print('DEBUG: Validation succeeded but signIn returned null');
          setState(() => _errorMessage = 'Hisob tasdiqlandi, lekin kirib bo\'lmadi. Login sahifasiga o\'ting.');
        }
      } else {
        print('DEBUG: validateAccount returned null (wrong code)');
        setState(() => _errorMessage = 'Tasdiqlash kodi noto\'g\'ri');
      }
    } catch (e) {
      print('ERROR: Register verification exception: $e');
      setState(() => _errorMessage = 'Xato: ${e.toString().split('\n').first}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    _showVerification ? 'Emailni tasdiqlang' : 'Hisob yaratish',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showVerification
                        ? '${_emailController.text.trim()} manziliga kod yuborildi'
                        : 'SlimWay ga qo\'shiling',
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  if (!_showVerification) ...[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Parol (kamida 8 ta belgi)',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _isLoading ? null : _createAccount(),
                    ),
                  ] else ...[
                    // Tasdiqlash kodi — server terminalida ko'rinadi
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kod server terminalida chiqadi (development mode)',
                              style: TextStyle(color: Colors.amber, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _verificationController,
                      decoration: const InputDecoration(
                        labelText: 'Tasdiqlash kodi',
                        prefixIcon: Icon(Icons.verified_user_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _isLoading ? null : _verifyAccount(),
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_showVerification ? _verifyAccount : _createAccount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _showVerification ? 'Tasdiqlash' : 'Ro\'yxatdan o\'tish',
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
                        'Emailni o\'zgartirish',
                        style: TextStyle(color: AppTheme.primaryColor),
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
  }
}
