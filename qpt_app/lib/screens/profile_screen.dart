// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../widgets/app_badge.dart';
import '../services/api_service.dart';
import 'inbody_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;
  final VoidCallback onInBodyComplete;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onInBodyComplete,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  
  // DB에서 가져올 데이터
  int _totalWorkouts = 0;
  int _totalMeals = 0;
  int _streak = 0;
  Map<String, dynamic>? _activeGoal;
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  Future<void> _loadProfileData() async {
    try {
      // 활성 목표 가져오기
      final goalData = await _apiService.getActiveGoal();
      
      // 통계 데이터 계산 (간단한 버전)
      final stats = await _calculateStats();
      
      if (mounted) {
        setState(() {
          _activeGoal = goalData;
          _totalWorkouts = stats['totalWorkouts'] ?? 0;
          _totalMeals = stats['totalMeals'] ?? 0;
          _streak = stats['streak'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<Map<String, int>> _calculateStats() async {
    int totalWorkouts = 0;
    int totalMeals = 0;
    int streak = 0;
    
    try {
      // 최근 30일간 데이터 조회
      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        
        try {
          // 운동 계획 조회
          final workoutData = await _apiService.getWorkoutPlan(dateString);
          final sets = (workoutData['sets'] as List?) ?? [];
          final completedSets = sets.where((s) => s['status'] == 'completed').length;
          if (completedSets > 0) {
            totalWorkouts++;
          }
          
          // 식단 조회
          final mealsData = await _apiService.getMeals(dateString);
          final meals = (mealsData['meals'] as List?) ?? [];
          if (meals.isNotEmpty) {
            totalMeals++;
          }
        } catch (e) {
          // 특정 날짜 데이터 없으면 무시
        }
      }
      
      // 연속 일수 계산 (최근부터 역순으로)
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        
        try {
          final workoutData = await _apiService.getWorkoutPlan(dateString);
          final mealsData = await _apiService.getMeals(dateString);
          
          final hasSets = ((workoutData['sets'] as List?) ?? []).isNotEmpty;
          final hasMeals = ((mealsData['meals'] as List?) ?? []).isNotEmpty;
          
          if (hasSets || hasMeals) {
            streak++;
          } else {
            break; // 기록이 없으면 연속 중단
          }
        } catch (e) {
          break;
        }
      }
    } catch (e) {
      print('통계 계산 실패: $e');
    }
    
    return {
      'totalWorkouts': totalWorkouts,
      'totalMeals': totalMeals,
      'streak': streak,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Mock InBody History (OCR 미구현이므로 유지)
    final inbodyHistory = [
      {'date': '2024-01-15', 'weight': 70.5, 'muscleMass': 32.1, 'fatMass': 12.8},
      {'date': '2024-01-01', 'weight': 72.0, 'muscleMass': 31.8, 'fatMass': 14.5}
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildUserInfoCard(context),
          const SizedBox(height: 24),
          _buildStatsOverviewCard(),
          const SizedBox(height: 24),
          _buildCurrentGoalsCard(),
          const SizedBox(height: 24),
          _buildInBodyHistoryCard(context, inbodyHistory),
          const SizedBox(height: 24),
          _buildSettingsActions(),
          const SizedBox(height: 24),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return AppCard(
      content: AppCardContent(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(radius: 32, backgroundImage: NetworkImage('https://github.com/shadcn.png')),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.user['nickname'] ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(widget.user['email'] ?? 'user@example.com', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('Member since Jan 2024', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            AppButton(onPressed: () {}, variant: AppButtonVariant.outline, size: AppButtonSize.icon, child: const Icon(Icons.edit_outlined, size: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverviewCard() {
    return AppCard(
      header: const AppCardHeader(title: Row(children: [Icon(Icons.bar_chart, color: Colors.blue), SizedBox(width: 8), Text('Your Journey')])),
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(_streak.toString(), 'Day Streak', Colors.blue),
            _buildStatItem(_totalWorkouts.toString(), 'Workouts', Colors.green),
            _buildStatItem(_totalMeals.toString(), 'Meals Logged', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCurrentGoalsCard() {
    final hasGoal = _activeGoal != null;
    
    return AppCard(
      header: AppCardHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [Icon(Icons.track_changes, color: Colors.green), SizedBox(width: 8), Text('Current Goals')]),
            if (!hasGoal)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '목표 미설정',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      content: AppCardContent(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: hasGoal ? Column(
          children: [
            if (_activeGoal!['targetWeight'] != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Target Weight'),
                  Text('${_parseDouble(_activeGoal!['targetWeight']).toStringAsFixed(1)}kg', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (_activeGoal!['targetMuscleMass'] != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Target Muscle Mass'),
                  Text('${_parseDouble(_activeGoal!['targetMuscleMass']).toStringAsFixed(1)}kg',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (_activeGoal!['targetFatMass'] != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Target Fat Mass'),
                  Text('${_parseDouble(_activeGoal!['targetFatMass']).toStringAsFixed(1)}kg',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ],
        ) : Center(
          child: Column(
            children: [
              Icon(Icons.flag_outlined, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('아직 목표가 설정되지 않았습니다'),
              const SizedBox(height: 8),
              Text(
                'AI Trainer에서 분석을 받아보세요!',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 안전하게 double로 변환하는 헬퍼 메서드
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget _buildInBodyHistoryCard(BuildContext context, List<Map<String, dynamic>> history) {
    return AppCard(
      header: AppCardHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [Icon(Icons.calendar_today_outlined, color: Colors.purple), SizedBox(width: 8), Text('InBody History')]),
            AppButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InBodySetupScreen(user: widget.user, onComplete: widget.onInBodyComplete))),
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              child: const Text('Add New'),
            ),
          ],
        ),
      ),
      content: AppCardContent(
        // ✅ 여기에 padding 속성을 추가하세요.
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // 좌, 상, 우, 하 순서
        child: Column(
          children: List.generate(history.length, (index) {
            final record = history[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBadge(text: DateFormat.yMMMd().format(DateTime.parse(record['date'])), variant: AppBadgeVariant.outline),
                  Text('Weight: ${record['weight']}kg'),
                  Text('Muscle: ${record['muscleMass']}kg'),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSettingsActions() {
    return AppCard(
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(onPressed: () {}, variant: AppButtonVariant.ghost, child: const Row(children: [Icon(Icons.settings_outlined), SizedBox(width: 8), Text('Settings & Preferences')])),
            AppButton(onPressed: widget.onLogout, variant: AppButtonVariant.ghost, child: const Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Sign Out', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }

  // lib/screens/profile_screen.dart

  Widget _buildAppInfoCard() {
    return AppCard(
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(vertical: 24),
        // ✅ Column을 Center 위젯으로 한번 감싸줍니다.
        child: Center(
          child: Column(
            // 이 속성은 Column 내부의 위젯들을 정렬하므로 그대로 두는 것이 좋습니다.
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
                ),
                child: const Icon(Icons.android, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              const Text('Q-PT', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('AI. DATA. PERFORMANCE.', style: TextStyle(color: Colors.grey)),
              const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}