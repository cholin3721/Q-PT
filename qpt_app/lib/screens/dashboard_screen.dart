// lib/screens/dashboard_screen.dart (수정본)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_card.dart';
import '../services/api_service.dart';
import '../models/meal_data.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  // ✅ 1. 네비게이션 콜백을 받을 변수 선언
  final VoidCallback onNavigateToDiet;
  final VoidCallback onNavigateToWorkout;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.onNavigateToDiet,
    required this.onNavigateToWorkout,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  MealLog? _todayMeals;
  Map<String, dynamic>? _todayWorkout;
  List<Map<String, dynamic>> _aiFeedbacks = [];
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // 오늘 날짜 사용
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // 병렬로 데이터 로드
      final results = await Future.wait([
        _apiService.getMeals(today),
        _apiService.getWorkoutPlan(today),
        _apiService.getAIFeedbacks(),
        _loadRecentActivities(),
      ]);
      
      final mealsData = results[0] as Map<String, dynamic>;
      final workoutData = results[1] as Map<String, dynamic>;
      final feedbacks = results[2] as List<Map<String, dynamic>>;
      final activities = results[3] as List<Map<String, dynamic>>;
      
      final mealLog = MealLog.fromJson(mealsData);
      
      if (mounted) {
        setState(() {
          _todayMeals = mealLog;
          _todayWorkout = workoutData;
          _aiFeedbacks = feedbacks;
          _recentActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: ${e.toString()}')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadRecentActivities() async {
    final activities = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    try {
      // 최근 5일간의 데이터 로드
      for (int i = 0; i < 5; i++) {
        final date = now.subtract(Duration(days: i));
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        
        try {
          // 식단 데이터
          final mealsData = await _apiService.getMeals(dateString);
          final mealLog = MealLog.fromJson(mealsData);
          if (mealLog.meals.isNotEmpty) {
            activities.add({
              'type': 'meal',
              'icon': Icons.restaurant_menu,
              'color': Colors.orange,
              'title': 'Meals Logged',
              'subtitle': '${mealLog.totalNutrition['calories']?.toStringAsFixed(0) ?? 0} kcal',
              'date': date,
            });
          }
          
          // 운동 데이터
          final workoutData = await _apiService.getWorkoutPlan(dateString);
          final sets = (workoutData['sets'] as List?) ?? [];
          final completedSets = sets.where((s) => s['status'] == 'completed').length;
          if (completedSets > 0) {
            activities.add({
              'type': 'workout',
              'icon': Icons.fitness_center,
              'color': Colors.green,
              'title': 'Workout Completed',
              'subtitle': '$completedSets sets completed',
              'date': date,
            });
          }
        } catch (e) {
          // 특정 날짜 데이터 로드 실패는 무시
        }
      }
      
      // 날짜순 정렬 (최신순)
      activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      return activities.take(5).toList();
    } catch (e) {
      print('최근 활동 로드 실패: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(widget.user['nickname'] ?? 'User', DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now())),
            const SizedBox(height: 24),
            _buildTodaysOverview(),
            const SizedBox(height: 24),
            _buildQuickActions(), // ✅ 이 부분에서 콜백이 사용됩니다.
            const SizedBox(height: 24),
            _buildAiTipCard(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  // ... (_buildHeader, _buildTodaysOverview 등 다른 위젯들은 그대로) ...
  Widget _buildHeader(String nickname, String dateString) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, $nickname!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(dateString, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysOverview() {
    // 영양소 데이터
    final totalProtein = _todayMeals?.totalNutrition['protein'] ?? 0.0;
    final totalCarbs = _todayMeals?.totalNutrition['carbs'] ?? 0.0;
    final totalFat = _todayMeals?.totalNutrition['fat'] ?? 0.0;
    
    // 운동 데이터
    final sets = (_todayWorkout?['sets'] as List?) ?? [];
    final totalSets = sets.length;
    final completedSets = sets.where((set) => set['status'] == 'completed').length;

    return AppCard(
      header: const AppCardHeader(title: Row(children: [
        Icon(Icons.pie_chart_outline, color: Colors.blue),
        SizedBox(width: 8),
        Text("Today's Focus")
      ])),
      content: AppCardContent(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 영양소 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientItem('Protein', totalProtein, 'g', Colors.blue),
                _buildNutrientItem('Carbs', totalCarbs, 'g', Colors.green),
                _buildNutrientItem('Fat', totalFat, 'g', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // 운동 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Workout Sets: $completedSets / $totalSets',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientItem(String label, num value, String unit, Color color) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // ✅ 2. _buildQuickActions에서 콜백을 _buildActionCard로 전달
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionCard(
            Icons.restaurant_menu, 'Log Meal', 'Track your nutrition',
            Colors.orange, widget.onNavigateToDiet)), // onNavigateToDiet 전달
        const SizedBox(width: 16),
        Expanded(child: _buildActionCard(
            Icons.fitness_center, 'Workout', 'Begin your routine',
            Colors.green, widget.onNavigateToWorkout)), // onNavigateToWorkout 전달
      ],
    );
  }

  // ✅ 3. _buildActionCard를 InkWell로 감싸고 onTap 기능 추가
  Widget _buildActionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0), // 물결 효과가 카드 모양과 맞게
      child: AppCard(
        content: AppCardContent(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiTipCard() {
    String tipText = _getAiTip();
    
    return AppCard(
      header: const AppCardHeader(
        title: Row(children: [
          Icon(Icons.psychology, color: Colors.purple),
          SizedBox(width: 8),
          Text('AI Tip of the Day')
        ]),
      ),
      content: AppCardContent(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(8)
          ),
          child: Text(
            tipText,
            style: TextStyle(color: Colors.purple.shade800, fontSize: 14),
          ),
        ),
      ),
    );
  }

  String _getAiTip() {
    // 최신 AI 피드백이 있으면 그것을 사용
    if (_aiFeedbacks.isNotEmpty) {
      final latestFeedback = _aiFeedbacks.first;
      final analysis = latestFeedback['feedbackContent']?['analysis'];
      if (analysis != null && analysis.toString().isNotEmpty) {
        return analysis.toString();
      }
    }
    
    // AI 피드백이 없으면 일반적인 팁 제공 (요일별로 다른 팁)
    final dayOfWeek = DateTime.now().weekday;
    final tips = [
      'Stay hydrated! Aim for at least 8 glasses of water today. 💧',
      'Remember: Consistency beats perfection. Keep showing up! 💪',
      'Focus on your form over weight. Quality reps build better results. 🎯',
      'Recovery is part of training. Make sure to get enough sleep tonight. 😴',
      'Track your progress today. Small wins lead to big changes! 📈',
      'Fuel your body right. Your nutrition is just as important as your workout. 🥗',
      'Take a moment to celebrate how far you\'ve come. You\'re doing great! 🌟',
    ];
    
    return tips[dayOfWeek % tips.length];
  }

  Widget _buildRecentActivity() {
    final activities = _recentActivities.isEmpty 
      ? [
          {
            'icon': Icons.info_outline,
            'color': Colors.grey,
            'title': 'No recent activity',
            'subtitle': 'Start tracking to see your progress!',
            'date': DateTime.now(),
          }
        ]
      : _recentActivities;

    return AppCard(
      header: const AppCardHeader(
        title: Row(children: [
          Icon(Icons.history, color: Colors.indigo),
          SizedBox(width: 8),
          Text('Recent Activity')
        ]),
      ),
      content: AppCardContent(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: activities.map((activity) {
            final date = activity['date'] as DateTime;
            final isToday = DateFormat('yyyy-MM-dd').format(date) == 
                           DateFormat('yyyy-MM-dd').format(DateTime.now());
            final dateLabel = isToday 
              ? 'Today' 
              : DateFormat('MMM d').format(date);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      activity['icon'] as IconData, 
                      color: activity['color'] as Color, 
                      size: 18
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          activity['subtitle'] as String,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}