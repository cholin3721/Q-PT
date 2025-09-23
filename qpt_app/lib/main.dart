// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// 우리가 만든 모든 화면들을 가져옵니다.
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

// 앱의 전체 상태(환영->인증->메인)를 관리하기 위해 StatefulWidget으로 변경
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// 앱의 상태를 정의하는 enum
enum AppState { welcome, authentication, authenticated }

class _MyAppState extends State<MyApp> {
  AppState _appState = AppState.welcome;
  Map<String, dynamic>? _user;

  void _handleGetStarted() {
    setState(() {
      _appState = AppState.authentication;
    });
  }

  // 1. 환영 화면으로 돌아가는 함수 추가
  void _handleBackToWelcome() {
    setState(() {
      _appState = AppState.welcome;
    });
  }

  void _handleAuthSuccess(Map<String, dynamic> userData) {
    setState(() {
      _user = userData;
      _appState = AppState.authenticated;
    });
  }

  void _handleLogout() {
    setState(() {
      _user = null;
      _appState = AppState.welcome;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Q-PT App',
      theme: AppTheme.lightTheme, // 앱 전체에 우리가 만든 테마를 적용!
      
      home: Builder(
        builder: (context) {
          switch (_appState) {
            case AppState.welcome:
              return WelcomeScreen(onGetStarted: _handleGetStarted);
            case AppState.authentication:
              // 수정된 AuthScreen은 이제 데이터를 받는 함수를 정상적으로 전달받습니다.
              return AuthScreen(
                onAuthSuccess: _handleAuthSuccess,
                onBack: _handleBackToWelcome,
              );
            case AppState.authenticated:
              // MainAppShell에 user 데이터와 logout 함수를 전달합니다.
              return MainAppShell(user: _user!, onLogout: _handleLogout);
          }
        },
      ),
    );
  }
}

// 인증 후의 메인 앱 구조 (하단 네비게이션 바 포함)
class MainAppShell extends StatefulWidget {
  // 1. user와 onLogout을 전달받을 변수를 선언합니다.
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  // 2. 생성자에서 이 값들을 필수로 받도록 수정합니다.
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
    // 3. 이제 widget.user 와 widget.onLogout 으로 올바르게 접근할 수 있습니다.
    _widgetOptions = <Widget>[
      DashboardScreen(user: widget.user),
      DietTrackerScreen(user: widget.user),
      InBodySetupScreen(user: widget.user, onComplete: _handleInBodyComplete),
      WorkoutPlannerScreen(user: widget.user),
      AiTrainerScreen(user: widget.user),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout),
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