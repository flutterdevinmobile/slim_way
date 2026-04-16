import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/i18n.dart';
import 'home_screen.dart';
import 'food_history_screen.dart';
import 'walk_log_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

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
    final appState = context.watch<AppState>();
    final locale = appState.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: appState.selectedTabIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-food'),
        backgroundColor: AppTheme.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildTabItem(0, Icons.home_rounded, I18n.t('dashboard', locale), appState),
            _buildTabItem(1, Icons.restaurant_rounded, I18n.t('history', locale), appState),
            const Expanded(child: SizedBox.shrink()), // Space for center docked FAB!
            _buildTabItem(2, Icons.auto_awesome_rounded, I18n.t('ai_coach', locale), appState), 
            _buildTabItem(3, Icons.directions_walk_rounded, I18n.t('activity', locale), appState),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label, AppState state) {
    final isSelected = state.selectedTabIndex == index;
    final color = isSelected ? AppTheme.green : Colors.grey;

    return Expanded(
      child: GestureDetector(
        onTap: () => state.selectedTabIndex = index,
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
