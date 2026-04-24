import 'package:get_it/get_it.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:slim_way_flutter/main.dart' as main;

import 'package:slim_way_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:slim_way_flutter/features/auth/data/repository/auth_repository_impl.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

import 'package:slim_way_flutter/features/home/domain/repository/summary_repository.dart';
import 'package:slim_way_flutter/features/home/data/repository/summary_repository_impl.dart';
import 'package:slim_way_flutter/features/home/presentation/blocs/summary_bloc/summary_bloc.dart';
import 'package:slim_way_flutter/features/home/data/datasources/summary_local_data_source.dart';
import 'package:slim_way_flutter/shared/application/services/sync_service.dart';
import 'package:slim_way_flutter/shared/application/services/sensor_sync_service.dart';




import 'package:slim_way_flutter/features/food/domain/repository/food_repository.dart';
import 'package:slim_way_flutter/features/food/data/repository/food_repository_impl.dart';
import 'package:slim_way_flutter/features/food/presentation/blocs/food_bloc/food_bloc.dart';

import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/navigation_bloc/navigation_bloc.dart';

import 'package:slim_way_flutter/features/activity/domain/repository/activity_repository.dart';
import 'package:slim_way_flutter/features/activity/data/repository/activity_repository_impl.dart';
import 'package:slim_way_flutter/features/activity/presentation/blocs/activity_bloc/activity_bloc.dart';

import 'package:slim_way_flutter/features/stats/domain/repository/stats_repository.dart';
import 'package:slim_way_flutter/features/stats/data/repository/stats_repository_impl.dart';
import 'package:slim_way_flutter/features/stats/presentation/blocs/stats_bloc/stats_bloc.dart';

import 'package:slim_way_flutter/features/chat/domain/repository/chat_repository.dart';
import 'package:slim_way_flutter/features/chat/data/repository/chat_repository_impl.dart';
import 'package:slim_way_flutter/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:slim_way_flutter/shared/application/services/health_sync_service.dart';


final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<Client>(() => main.client);
  sl.registerLazySingleton<SessionManager>(() => main.sessionManager);

  sl.registerLazySingleton<SummaryLocalDataSource>(() => SummaryLocalDataSourceImpl());
  sl.registerLazySingleton<SyncService>(() => SyncService(
    client: sl<Client>(),
    localDataSource: sl<SummaryLocalDataSource>(),
  ));
  sl.registerLazySingleton<HealthSyncService>(() => HealthSyncService());
  sl.registerLazySingleton<SensorSyncService>(() => SensorSyncService());


  // Repositories


  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      client: sl<Client>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  sl.registerLazySingleton<SummaryRepository>(
    () => SummaryRepositoryImpl(
      client: sl<Client>(),
      localDataSource: sl<SummaryLocalDataSource>(),
    ),
  );


  sl.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(
      client: sl<Client>(),
    ),
  );

  sl.registerLazySingleton<StatsRepository>(
    () => StatsRepositoryImpl(
      client: sl<Client>(),
    ),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      client: sl<Client>(),
    ),
  );

  sl.registerLazySingleton<FoodRepository>(
    () => FoodRepositoryImpl(
      client: sl<Client>(),
    ),
  );

  // Blocs
  sl.registerLazySingleton(
    () => NavigationBloc(),
  );

  sl.registerLazySingleton(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton(
    () => SettingsBloc()..add(SettingsInitRequested()),
  );

  sl.registerFactory(
    () => SummaryBloc(
      repository: sl<SummaryRepository>(),
      userId: sl<AuthBloc>().state.whenOrNull<int>(authenticated: (user) => user.id ?? 0) ?? 0,
    ),
  );

  sl.registerFactory(
    () => ActivityBloc(
      activityRepository: sl<ActivityRepository>(),
      healthSyncService: sl<HealthSyncService>(),
      sensorSyncService: sl<SensorSyncService>(),
      userId: sl<AuthBloc>().state.whenOrNull<int>(authenticated: (user) => user.id ?? 0) ?? 0,
    ),
  );


  sl.registerFactory(
    () => FoodBloc(repository: sl<FoodRepository>()),
  );

  sl.registerFactory(
    () => StatsBloc(
      statsRepository: sl<StatsRepository>(),
      userId: sl<AuthBloc>().state.whenOrNull<int>(authenticated: (user) => user.id ?? 0) ?? 0,
    ),
  );

  sl.registerFactory(
    () => ChatBloc(
      chatRepository: sl<ChatRepository>(),
      userId: sl<AuthBloc>().state.whenOrNull<int>(authenticated: (user) => user.id ?? 0) ?? 0,
    ),
  );
}
