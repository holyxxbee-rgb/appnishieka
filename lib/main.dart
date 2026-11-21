import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/diary_provider.dart';
import 'screens/add_entry_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/diary_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => DiaryProvider(),
      child: const SnapDiaryApp(),
    ),
  );
}

class SnapDiaryApp extends StatelessWidget {
  const SnapDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapDiary Mobile Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onNavigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addNewEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEntryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToDiary: () => _onNavigateToTab(1),
        onNavigateToProfile: () => _onNavigateToTab(3),
      ),
      DiaryListScreen(
        onNavigateToProfile: () => _onNavigateToTab(3),
      ),
      FavoritesScreen(
        onNavigateToProfile: () => _onNavigateToTab(3),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryContainer,
              foregroundColor: AppTheme.onPrimaryContainer,
              shape: const CircleBorder(),
              onPressed: _addNewEntry,
              child: const Icon(Icons.edit_note_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigateToTab,
        backgroundColor: AppTheme.surfaceContainerLowest,
        indicatorColor: AppTheme.surfaceContainerHigh,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppTheme.primary),
            label: 'My Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: AppTheme.primary),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
