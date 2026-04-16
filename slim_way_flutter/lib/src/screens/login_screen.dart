import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_email_flutter/serverpod_auth_email_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../main.dart' as main;
import '../providers/app_state.dart';
import '../theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Diagnostika: Ulanishni tekshirish ──────────────────────────────────────
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('DEBUG: Testing connection to ${main.client.host}...');
      // Use a known endpoint to test connectivity. 
      // 0 is just a dummy ID, we just want to see if the request reaches the server.
      await main.client.user.getUserByAuthId(0);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Server bilan ulanish muvaffaqiyatli!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Connection test failed: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Serverga ulanib bo\'lmadi: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Email / Parol bilan kirish ───────────────────────────────────────────
  Future<void> _signIn() async {
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
      print('DEBUG: Attempting email sign-in for $email');
      final authController = EmailAuthController(main.client.modules.auth);
      final userInfo = await authController.signIn(email, password);

      if (userInfo != null) {
        print('DEBUG: Login success for ${userInfo.email}. Refreshing session...');
        await main.sessionManager.refreshSession();
        
        if (!mounted) return;
        final appState = context.read<AppState>();
        await appState.fetchUserByAuthId(userInfo.id!);
        
        print('DEBUG: Navigation to /main...');
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
      } else {
        print('DEBUG: Email login returned null (invalid credentials)');
        setState(() => _errorMessage = 'Email yoki parol noto\'g\'ri');
      }
    } catch (e) {
      print('ERROR: Login exception: $e');
      setState(() {
        if (e.toString().contains('401')) {
          _errorMessage = 'Email yoki parol noto\'g\'ri (401)';
        } else if (e.toString().contains('Connection refused') || e.toString().contains('SocketException')) {
          _errorMessage = 'Serverga ulanib bo\'lmadi. Wi-Fi va IP ni tekshiring.';
        } else {
          _errorMessage = 'Xato: ${e.toString().split('\n').first}';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Google bilan kirish ──────────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('DEBUG: Starting Google Sign-In...');
      // 1. Google interaktiv dialog — google_sign_in v7 API
      final googleAccount = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // 2. Token olish
      final idToken = googleAccount.authentication.idToken;
      print('DEBUG: Google authentication received. idToken present: ${idToken != null}');

      String? authKeyStr;

      if (idToken != null && idToken.isNotEmpty) {
        print('DEBUG: Signing in with idToken...');
        authKeyStr = await main.client.googleAuth.signInWithGoogle(idToken, isAccessToken: false);
      } else {
        print('DEBUG: idToken missing, using accessToken...');
        final clientAuth = await googleAccount.authorizationClient
            .authorizeScopes(['email', 'profile']);
        authKeyStr = await main.client.googleAuth
            .signInWithAccessToken(clientAuth.accessToken);
      }

      if (authKeyStr == null || authKeyStr.isEmpty) {
        print('DEBUG: Serverpod Google login returned null');
        if (mounted) {
          setState(
            () => _errorMessage = 'Server Google autentifikatsiyani rad etdi. ClientId ni tekshiring.',
          );
        }
        return;
      }

      print('DEBUG: Google login successful. Updating session...');
      // 3. Auth key saqlash va session yangilash
      await main.authKeyManager.put(authKeyStr);
      await main.sessionManager.refreshSession();

      if (!mounted) return;
      final appState = context.read<AppState>();
      final signedInUser = main.sessionManager.signedInUser;
      if (signedInUser != null) {
        await appState.fetchUserByAuthId(signedInUser.id!);
      }
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
    } on GoogleSignInException catch (e) {
      print('ERROR: GoogleSignInException: ${e.code}');
      if (mounted) {
        setState(
          () => _errorMessage =
              'Google kirish xatosi: ${e.description ?? e.code.name}',
        );
      }
    } catch (e) {
      print('ERROR: General Google Auth error: $e');
      if (mounted) setState(() => _errorMessage = 'Xato: ${e.toString().split('\n').first}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetAppData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('DEBUG: Resetting app data...');
      await main.authKeyManager.remove();
      // refreshing session with no key effectively signs out
      await main.sessionManager.refreshSession();
      
      if (mounted) {
        setState(() => _errorMessage = 'Barcha ma\'lumotlar tozalandi. Qaytadan kiring.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siz tizimdan chiqdingiz va ma\'lumotlar tozalandi')),
        );
      }
    } catch (e) {
      print('ERROR: Reset failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: AppTheme.primaryColor,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Xush kelibsiz',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hisobingizga kiring',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
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

                  // Parol
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Parol',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _isLoading ? null : _signIn(),
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
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const _Spinner()
                          : const Text(
                              'Kirish',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Diagnostika tugmasi
                  TextButton.icon(
                    onPressed: _isLoading ? null : _testConnection,
                    icon: const Icon(Icons.network_check_rounded, size: 18),
                    label: const Text('Server bilan ulanib ko\'ring'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ajratgich
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'yoki',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.2),
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
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const _GoogleIcon(),
                      label: const Text(
                        'Google orqali kirish',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Ro'yxatdan o'tish
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hisobingiz yo\'qmi? ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
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
                          'Ro\'yxatdan o\'ting',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Reset tugmasi
                  TextButton(
                    onPressed: _isLoading ? null : _resetAppData,
                    child: const Text(
                      'Reset All App Data',
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Yordamchi widgetlar ───────────────────────────────────────────────────

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
