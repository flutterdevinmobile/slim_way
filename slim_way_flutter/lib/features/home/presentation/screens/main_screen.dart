import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/navigation_bloc/navigation_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'home_screen.dart';
import 'package:slim_way_flutter/features/food/presentation/screens/food_history_screen.dart';
import 'package:slim_way_flutter/features/activity/presentation/screens/walk_log_screen.dart';
import 'package:slim_way_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:slim_way_flutter/features/chat/presentation/screens/chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const FoodHistoryScreen(),
    const ChatScreen(),
    const WalkLogScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, navState) {
            final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: IndexedStack(
                index: navState.selectedIndex,
                children: _screens,
              ),
              floatingActionButton: (isKeyboardVisible) 
                ? null 
                : FloatingActionButton(
                    onPressed: () => Navigator.pushNamed(context, '/add-food'),
                    backgroundColor: AppTheme.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 28),
                  ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: (isKeyboardVisible)
                ? null
                : BottomAppBar(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 70,
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildTabItem(0, Icons.home_rounded, 'dashboard.title'.tr(), navState.selectedIndex),
                    _buildTabItem(1, Icons.restaurant_rounded, 'common.history'.tr(), navState.selectedIndex),
                    const Expanded(child: SizedBox.shrink()), // Space for center docked FAB!
                    _buildTabItem(2, Icons.auto_awesome_rounded, 'chat.title'.tr(), navState.selectedIndex),
                    _buildTabItem(3, Icons.directions_walk_rounded, 'activity.title'.tr(), navState.selectedIndex),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label, int selectedIndex) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? AppTheme.green : Colors.grey;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<NavigationBloc>().add(TabChanged(index)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 9, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
