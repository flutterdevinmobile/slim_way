import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:isolate';

import 'src/theme.dart';
import 'src/providers/app_state.dart';
import 'src/screens/profile_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/food_history_screen.dart';
import 'src/screens/main_screen.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/add_food_screen.dart';
import 'src/utils/notification_service.dart';
import 'src/utils/hive_key_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

late final Client client;
late final SessionManager sessionManager;
late final HiveAuthenticationKeyManager authKeyManager;

// PC ning lokal IP manzili (dart run --dart-define=SERVER_IP=x.x.x.x bilan o'zgartirish mumkin)
// Haqiqiy qurilma: PC ning WiFi IP manzili (ipconfig da ko'ring)
// Emulyator:       10.0.2.2
const String _serverIp = String.fromEnvironment('SERVER_IP', defaultValue: '192.168.1.7');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Communication Bridge for Notifications
  final receivePort = ReceivePort();
  IsolateNameServer.removePortNameMapping(NotificationService.portName);
  IsolateNameServer.registerPortWithName(receivePort.sendPort, NotificationService.portName);
  receivePort.listen((message) {
      if (message is int) {
          NotificationService.relayUpdate(message);
      }
  });

  // Hive ni ishga tushirish
  await Hive.initFlutter();

  // Google Sign-In ni ishga tushirish (authenticate() dan OLDIN shart)
  await GoogleSignIn.instance.initialize();

  authKeyManager = HiveAuthenticationKeyManager();

  // Server manzili: real qurilma uchun LAN IP, emulyator uchun 10.0.2.2
  final String host;
  if (Platform.isAndroid) {
    host = _serverIp; // flutter run --dart-define=SERVER_IP=10.0.2.2  (emulator uchun)
  } else {
    host = 'localhost';
  }

  print('DEBUG: Connecting to server at http://$host:3000/');
  client = Client(
    'http://$host:3000/',
    authenticationKeyManager: authKeyManager,
  )..connectivityMonitor = FlutterConnectivityMonitor();

  // Initialize SessionManager with the caller from our client
  // It will automatically use the same keyManager we set on the client
  sessionManager = SessionManager(
    caller: client.modules.auth,
  );
  
  try {
    print('DEBUG: Initializing SessionManager...');
    await sessionManager.initialize();
    await NotificationService.initialize(); // Notification initialize
    print('DEBUG: SessionManager initialized. User: ${sessionManager.signedInUser?.email}');
  } catch (e) {
    print('CRITICAL ERROR: SessionManager initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return MaterialApp(
      title: 'SlimWay Premium',
      themeMode: appState.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
        '/food-history': (context) => const FoodHistoryScreen(),
        '/add-food': (context) => const AddFoodScreen(),
      },
    );
  }
}
