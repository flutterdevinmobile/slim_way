import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'dart:ui';
import 'dart:isolate';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:slim_way_flutter/shared/application/configs/di/injection_container.dart';
import 'package:slim_way_flutter/shared/utils/notification_service.dart';
import 'package:slim_way_flutter/shared/utils/hive_key_manager.dart';
import 'package:slim_way_flutter/features/home/data/datasources/summary_local_data_source.dart';
import 'package:slim_way_flutter/shared/application/services/sync_service.dart';
import 'package:slim_way_flutter/shared/application/services/sensor_sync_service.dart';

import 'app.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/features/home/presentation/blocs/summary_bloc/summary_bloc.dart';
import 'package:slim_way_flutter/features/activity/presentation/blocs/activity_bloc/activity_bloc.dart';
import 'package:slim_way_flutter/features/food/presentation/blocs/food_bloc/food_bloc.dart';
import 'package:slim_way_flutter/features/stats/presentation/blocs/stats_bloc/stats_bloc.dart';
import 'package:slim_way_flutter/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/navigation_bloc/navigation_bloc.dart';

late final Client client;
late final SessionManager sessionManager;
late final HiveAuthenticationKeyManager authKeyManager;

const String _serverIp = String.fromEnvironment(
  'SERVER_IP',
  defaultValue: 'slim-way-server.onrender.com',
);

void main() async {
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final receivePort = ReceivePort();
  IsolateNameServer.removePortNameMapping(NotificationService.portName);
  IsolateNameServer.registerPortWithName(
    receivePort.sendPort,
    NotificationService.portName,
  );
  receivePort.listen((message) {
    if (message is int) {
      NotificationService.relayUpdate(message);
    }
  });

  await Hive.initFlutter();
  await SummaryLocalDataSourceImpl.init();

  // GoogleSignIn is handled by serverpod_auth_google_flutter internally

  authKeyManager = HiveAuthenticationKeyManager();

  final String host = _serverIp;
  // Use HTTPS for Render, HTTP for local
  final String protocol = host.contains('onrender.com') ? 'https' : 'http';
  // Render handles port routing (443), local needs 3000
  final String portSuffix = host.contains('onrender.com') ? '' : ':3000';

  client = Client(
    '$protocol://$host$portSuffix/',
    // ignore: deprecated_member_use
    authenticationKeyManager: authKeyManager,
  )..connectivityMonitor = FlutterConnectivityMonitor();

  sessionManager = SessionManager(
    caller: client.modules.auth,
  );

  try {
    await sessionManager.initialize();
    await NotificationService.initialize();
    await initDependencies();
    sl<SyncService>().startAutoSync();
    await sl<SensorSyncService>().initialize();
  } catch (e) {
    if (kDebugMode) debugPrint('Initialization failed: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uz'), Locale('en'), Locale('ru')],
      path: 'assets/langs',
      fallbackLocale: const Locale('uz'),
      startLocale: const Locale('uz'),
      saveLocale: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<SettingsBloc>(),
          ),
          BlocProvider(
            create: (_) => sl<NavigationBloc>(),
          ),
          BlocProvider(
            create: (_) => sl<AuthBloc>()..add(AuthInitRequested()),
          ),
          BlocProvider(
            create: (_) => sl<SummaryBloc>(),
          ),
          BlocProvider(
            create: (_) => sl<ActivityBloc>(),
          ),
          BlocProvider(
            create: (_) => sl<FoodBloc>(),
          ),
          BlocProvider(
            create: (_) => sl<StatsBloc>(),
          ),
          BlocProvider(
            create: (_) => sl<ChatBloc>(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
