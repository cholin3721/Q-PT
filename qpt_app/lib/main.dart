// lib/main.dart (Tab Order Changed)

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/diet_tracker_screen.dart';
import 'screens/inbody_setup_screen.dart';
import 'screens/workout_planner_screen.dart';
import 'screens/ai_trainer_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/history_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

enum AppState { welcome, authentication, authenticated }

class _MyAppState extends State<MyApp> {
  AppState _appState = AppState.authenticated; // 바로 인증된 상태로 시작
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    // 테스트용 사용자 데이터로 바로 설정
    _user = {
      'id': 1,
      'nickname': '김철중',
      'email': 'cholin3721@example.com',
      'provider': 'google',
    };
  }

  void _handleGetStarted() => setState(() => _appState = AppState.authentication);
  void _handleAuthSuccess(Map<String, dynamic> userData) {
    setState(() {
      _user = userData;
      _appState = AppState.authenticated;
    });
  }
  void _handleLogout() => setState(() {
    _user = null;
    _appState = AppState.welcome;
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Q-PT App',
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) {
          switch (_appState) {
            case AppState.welcome:
              return WelcomeScreen(onGetStarted: _handleGetStarted);
            case AppState.authentication:
              return AuthScreen(onAuthSuccess: _handleAuthSuccess, onBack: () => setState(() => _appState = AppState.welcome));
            case AppState.authenticated:
              return MainAppShell(user: _user!, onLogout: _handleLogout);
          }
        },
      ),
    );
  }
}

class MainAppShell extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const MainAppShell({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;
  bool _hasCompletedInBody = true; // InBody 설정 완료로 설정

  // DietTrackerScreen의 GlobalKey
  final GlobalKey<DietTrackerScreenState> _dietTrackerKey = GlobalKey();

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      DashboardScreen(
        user: widget.user,
        // ✅ Diet 탭의 새 인덱스(2)로 수정
        onNavigateToDiet: () => _onItemTapped(2),
        // Workout 탭의 인덱스(3)는 동일
        onNavigateToWorkout: () => _onItemTapped(3),
      ),
      // ✅ History와 Diet의 순서를 변경
      const HistoryScreen(),
      DietTrackerScreen(key: _dietTrackerKey, user: widget.user),
      WorkoutPlannerScreen(user: widget.user),
      AiTrainerScreen(user: widget.user),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout, onInBodyComplete: _handleInBodyComplete),
    ];
  }

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
    
    // Diet Tracker 탭(index: 2)으로 이동 시 데이터 새로고침
    if (index == 2 && _dietTrackerKey.currentState != null) {
      Future.microtask(() => _dietTrackerKey.currentState!.refreshData());
    }
  }

  void _handleInBodyComplete() {
    setState(() {
      _hasCompletedInBody = true;
      _selectedIndex = 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!_hasCompletedInBody) {
      return InBodySetupScreen(user: widget.user, onComplete: _handleInBodyComplete);
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // ✅ items 리스트에서 History와 Diet의 순서를 변경
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), activeIcon: Icon(Icons.restaurant_menu), label: 'Diet'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: AppColors.mutedForeground,
        showUnselectedLabels: true,
      ),
    );
  }
}