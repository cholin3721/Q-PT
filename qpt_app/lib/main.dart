// lib/main.dart (최종 롤백 버전)

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
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

enum AppState { welcome, authentication, authenticated }

class _MyAppState extends State<MyApp> {
  AppState _appState = AppState.welcome;
  Map<String, dynamic>? _user;

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

// 인증 후의 메인 앱 구조 (하단 네비게이션 바 포함)
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
  bool _hasCompletedInBody = false;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      DashboardScreen(user: widget.user),
      DietTrackerScreen(user: widget.user),
      InBodySetupScreen(user: widget.user, onComplete: _handleInBodyComplete),
      WorkoutPlannerScreen(user: widget.user),
      AiTrainerScreen(user: widget.user),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout, onInBodyComplete: _handleInBodyComplete),
    ];
  }

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }

  void _handleInBodyComplete() {
    setState(() {
      _hasCompletedInBody = true;
      _selectedIndex = 0; // 완료 후 대시보드로 이동
    });
  }

  @override
  Widget build(BuildContext context) {
    // 인바디 설정을 완료하지 않았고, 현재 보려는 탭이 인바디 탭이 아니라면, 인바디 설정 화면을 강제로 먼저 보여줌
    if (!_hasCompletedInBody && _selectedIndex != 2) {
      return InBodySetupScreen(user: widget.user, onComplete: _handleInBodyComplete);
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), activeIcon: Icon(Icons.restaurant_menu), label: 'Diet'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), activeIcon: Icon(Icons.assessment), label: 'InBody'),
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