import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/features/splash/presentation/screens/splash_screen.dart';
import 'package:slim_way_flutter/features/home/presentation/screens/main_screen.dart';
import 'package:slim_way_flutter/features/home/presentation/screens/home_screen.dart';
import 'package:slim_way_flutter/features/food/presentation/screens/food_history_screen.dart';
import 'package:slim_way_flutter/features/food/presentation/screens/add_food_screen.dart';
import 'package:slim_way_flutter/features/profile/presentation/screens/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settings) {
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, auth) {
                return MaterialApp(
                  title: 'SlimWay Premium',
                  themeMode: settings.themeMode,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  debugShowCheckedModeBanner: false,
                  locale: context.locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  home: const SplashScreen(),
                  routes: {
                    '/main': (context) => const MainScreen(),
                    '/profile': (context) => const ProfileScreen(),
                    '/home': (context) => const HomeScreen(),
                    '/food-history': (context) => const FoodHistoryScreen(),
                    '/add-food': (context) => const AddFoodScreen(),
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
