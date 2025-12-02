// lib/screens/history_screen.dart (Final Version)

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tabs.dart';
import '../theme/app_theme.dart';
import '../widgets/app_progress_indicator.dart';
import '../services/api_service.dart';

// --- Data Models based on React Code ---

abstract class DailyEvent {
  final String time;
  DailyEvent(this.time);
}

class MealEvent extends DailyEvent {
  final String mealType;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  MealEvent({
    required this.mealType,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required String time,
  }) : super(time);
}

class WorkoutEvent extends DailyEvent {
  final String workoutType;
  final int durationMinutes;
  final int caloriesBurned;
  final List<String> exercises;
  final List<WorkoutSet> sets; // 세트 정보 추가

  WorkoutEvent({
    required this.workoutType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.exercises,
    required this.sets,
    required String time,
  }) : super(time);
}

class WorkoutSet {
  final String exerciseName;
  final String status; // 'completed', 'pending', 'skipped'
  final int setNumber;
  final double? targetWeightKg;
  final double? actualWeightKg;
  final int? targetReps;
  final int? actualReps;

  WorkoutSet({
    required this.exerciseName,
    required this.status,
    required this.setNumber,
    this.targetWeightKg,
    this.actualWeightKg,
    this.targetReps,
    this.actualReps,
  });
}

enum ViewMode { overview, calendar }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  ViewMode _viewMode = ViewMode.overview;
  DateTime _focusedDay = DateTime.now(); // 현재 날짜로 초기 포커스 설정
  DateTime? _selectedDay;
  bool _isLoading = false;
  Set<DateTime> _daysWithMeals = {}; // 식단이 있는 날짜들
  Set<DateTime> _daysWithWorkouts = {}; // 운동이 있는 날짜들
  Map<DateTime, List<DailyEvent>> _allEvents = {}; // 모든 날짜의 이벤트 데이터
  Map<String, dynamic>? _activeGoal; // 활성 목표 데이터

  late final ValueNotifier<List<DailyEvent>> _selectedEvents;
  final ApiService _apiService = ApiService();

  // --- Mock Data (Based on React Code) ---
  List<Map<String, Object>> weeklyData = [
    {'date': "Mon", 'calories': 1850.0, 'protein': 120.0, 'carbs': 200.0, 'fat': 60.0, 'workout': 45.0},
    {'date': "Tue", 'calories': 1920.0, 'protein': 115.0, 'carbs': 220.0, 'fat': 65.0, 'workout': 60.0},
    {'date': "Wed", 'calories': 1780.0, 'protein': 105.0, 'carbs': 190.0, 'fat': 55.0, 'workout': 0.0},
    {'date': "Thu", 'calories': 1900.0, 'protein': 125.0, 'carbs': 210.0, 'fat': 62.0, 'workout': 50.0},
    {'date': "Fri", 'calories': 2100.0, 'protein': 140.0, 'carbs': 240.0, 'fat': 70.0, 'workout': 75.0},
    {'date': "Sat", 'calories': 2200.0, 'protein': 135.0, 'carbs': 250.0, 'fat': 75.0, 'workout': 90.0},
    {'date': "Sun", 'calories': 1950.0, 'protein': 110.0, 'carbs': 215.0, 'fat': 68.0, 'workout': 30.0},
  ];

  final Map<DateTime, List<DailyEvent>> _events = {
    DateTime.utc(2025, 1, 15): [
      MealEvent(mealType: 'Breakfast', description: "Oatmeal, Banana", calories: 420, protein: 25, carbs: 45, fat: 15, time: '07:30'),
      MealEvent(mealType: 'Lunch', description: "Chicken Breast Salad", calories: 650, protein: 35, carbs: 70, fat: 20, time: '12:30'),
      WorkoutEvent(workoutType: 'Upper Body Strength', durationMinutes: 45, caloriesBurned: 280, exercises: ["Bench Press", "Pull-up", "Shoulder Press"], sets: [], time: '18:30'),
      MealEvent(mealType: 'Dinner', description: "Salmon Steak", calories: 580, protein: 40, carbs: 55, fat: 18, time: '19:00'),
    ],
    DateTime.utc(2025, 1, 14): [
      WorkoutEvent(workoutType: 'Cardio', durationMinutes: 30, caloriesBurned: 320, exercises: ["Treadmill", "Cycling"], sets: [], time: '07:00'),
      MealEvent(mealType: 'Breakfast', description: "Greek Yogurt", calories: 380, protein: 20, carbs: 40, fat: 12, time: '08:00'),
      MealEvent(mealType: 'Lunch', description: "Pasta", calories: 520, protein: 28, carbs: 60, fat: 15, time: '13:00'),
      MealEvent(mealType: 'Dinner', description: "Tofu Kimchi", calories: 620, protein: 45, carbs: 50, fat: 22, time: '19:30'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadHistoryData();
    _loadDaysWithData();
  }

  Future<void> _loadDaysWithData() async {
    try {
      // 최근 30일간의 데이터를 확인
      final Set<DateTime> daysWithMeals = {};
      final Set<DateTime> daysWithWorkouts = {};
      final Map<DateTime, List<DailyEvent>> allEvents = {};
      
      for (int i = 0; i < 30; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final targetDate = DateTime(date.year, date.month, date.day);
        final List<DailyEvent> dayEvents = [];
        
        try {
          final dateString = DateFormat('yyyy-MM-dd').format(date);
          final mealsData = await _apiService.getMeals(dateString);
          
          // 식단 데이터 확인 및 이벤트 생성
          if (mealsData['meals'] != null && mealsData['meals'].isNotEmpty) {
            daysWithMeals.add(targetDate);
            
            for (var meal in mealsData['meals']) {
              for (var food in meal['foods']) {
                final calories = _safeDouble(food['calories'], 0.0).toInt();
                final protein = _safeDouble(food['protein'], 0.0).toInt();
                
                print('🍽️ 음식 데이터: ${food['foodName']} - ${food['calories']} -> $calories kcal');
                
                dayEvents.add(MealEvent(
                  mealType: _getMealTypeName(meal['mealType']),
                  description: food['foodName'],
                  calories: calories,
                  protein: protein,
                  carbs: _safeDouble(food['carbs'], 0.0).toInt(),
                  fat: _safeDouble(food['fat'], 0.0).toInt(),
                  time: _getMealTime(meal['mealType']),
                ));
              }
            }
          }
          
          // 운동 계획 데이터 확인 및 이벤트 생성
          try {
            print('🏃 운동 데이터 요청: $dateString');
            final workoutData = await _apiService.getWorkoutPlan(dateString);
            print('🏃 운동 API 응답: $workoutData');
            
            if (workoutData['planId'] != null && workoutData['status'] != 'none') {
              daysWithWorkouts.add(targetDate);
              
              // 실제 운동 세트 데이터에서 운동 목록 및 세트 정보 추출
              List<String> exerciseList = [];
              List<WorkoutSet> workoutSets = [];
              
              if (workoutData['sets'] != null && workoutData['sets'].isNotEmpty) {
                for (var set in workoutData['sets']) {
                  if (set['exerciseName'] != null) {
                    final exerciseName = set['exerciseName'];
                    if (!exerciseList.contains(exerciseName)) {
                      exerciseList.add(exerciseName);
                    }
                    
                    // WorkoutSet 객체 생성
                    workoutSets.add(WorkoutSet(
                      exerciseName: exerciseName,
                      status: set['status'] ?? 'pending',
                      setNumber: set['setNumber'] ?? 1,
                      targetWeightKg: set['targetWeightKg'] != null ? _safeDouble(set['targetWeightKg'], 0.0) : null,
                      actualWeightKg: set['actualWeightKg'] != null ? _safeDouble(set['actualWeightKg'], 0.0) : null,
                      targetReps: set['targetReps'],
                      actualReps: set['actualReps'],
                    ));
                  }
                }
              }
              
              // 운동 시간과 칼로리 계산 (실제 데이터 기반)
              int totalDuration = 0;
              int totalCalories = 0;
              if (workoutData['sets'] != null) {
                totalDuration = workoutData['sets'].length * 3; // 세트당 3분 가정
                totalCalories = workoutData['sets'].length * 15; // 세트당 15칼로리 가정
              }
              
              // 운동 시간을 실제 데이터 기반으로 계산 (오후 6시 기준)
              String workoutTime = '18:00';
              if (workoutData['status'] == 'completed') {
                workoutTime = '18:00'; // 완료된 운동은 오후 6시
              } else if (workoutData['status'] == 'active') {
                workoutTime = '19:00'; // 진행 중인 운동은 오후 7시
              } else {
                workoutTime = '20:00'; // 예정된 운동은 오후 8시
              }
              
              dayEvents.add(WorkoutEvent(
                workoutType: workoutData['memo'] ?? 'Workout',
                durationMinutes: totalDuration,
                caloriesBurned: totalCalories,
                exercises: exerciseList.isNotEmpty ? exerciseList : ['운동 계획'],
                sets: workoutSets,
                time: workoutTime,
              ));
              
              print('🏃 운동 데이터 추가: ${workoutData['memo']} - ${exerciseList.length}개 운동, ${totalDuration}분');
            } else {
              print('🏃 운동 데이터 없음: planId=${workoutData['planId']}, status=${workoutData['status']}');
            }
          } catch (e) {
            print('🏃 운동 데이터 로드 실패: $e');
          }
          
          // 해당 날짜의 이벤트 저장
          if (dayEvents.isNotEmpty) {
            allEvents[targetDate] = dayEvents;
          }
        } catch (e) {
          // 해당 날짜에 데이터가 없으면 무시
        }
      }
      
      if (mounted) {
        setState(() {
          _daysWithMeals = daysWithMeals;
          _daysWithWorkouts = daysWithWorkouts;
          _allEvents = allEvents;
        });
        print('📅 식단이 있는 날짜: $daysWithMeals');
        print('🏃 운동이 있는 날짜: $daysWithWorkouts');
        print('📊 전체 이벤트 데이터: ${allEvents.keys.length}개 날짜');
      }
    } catch (e) {
      print('데이터가 있는 날짜 로드 실패: $e');
    }
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 활성 목표 로드
      try {
        final goalData = await _apiService.getActiveGoal();
        if (mounted) {
          setState(() {
            _activeGoal = goalData;
          });
        }
        print('🎯 활성 목표 로드: ${goalData['goalType']} - ${goalData['targetCalories']}kcal');
      } catch (e) {
        print('🎯 활성 목표 로드 실패: $e');
      }
      
      // 최근 7일간의 데이터 로드
      final List<Map<String, Object>> weeklyDataFromAPI = [];
      
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        
        try {
          // 식단 데이터 로드
          final mealsData = await _apiService.getMeals(dateString);
          final totalNutrition = mealsData['totalNutrition'] as Map<String, dynamic>?;
          final totalCalories = _safeDouble(totalNutrition?['calories'], 0.0);
          final totalProtein = _safeDouble(totalNutrition?['protein'], 0.0);
          final totalCarbs = _safeDouble(totalNutrition?['carbs'], 0.0);
          final totalFat = _safeDouble(totalNutrition?['fat'], 0.0);
          
          // 운동 데이터 로드 (실제 API 연동)
          double workoutTime = 0.0;
          try {
            final workoutData = await _apiService.getWorkoutPlan(dateString);
            if (workoutData['planId'] != null && workoutData['status'] != 'none') {
              // 운동 세트 수를 기반으로 시간 계산 (세트당 3분 가정)
              if (workoutData['sets'] != null && workoutData['sets'].isNotEmpty) {
                workoutTime = (workoutData['sets'].length * 3).toDouble();
              }
            }
          } catch (e) {
            print('🏃 운동 데이터 로드 실패 ($dateString): $e');
          }
          
          weeklyDataFromAPI.add({
            'date': DateFormat('E').format(date),
            'calories': totalCalories,
            'protein': totalProtein,
            'carbs': totalCarbs,
            'fat': totalFat,
            'workout': workoutTime,
          });
          
          print('📊 Overview 데이터 ($dateString): ${totalCalories}kcal, P:${totalProtein}g, C:${totalCarbs}g, F:${totalFat}g, W:${workoutTime}min');
        } catch (e) {
          // 해당 날짜에 데이터가 없으면 0으로 설정
          weeklyDataFromAPI.add({
            'date': DateFormat('E').format(date),
            'calories': 0.0,
            'protein': 0.0,
            'carbs': 0.0,
            'fat': 0.0,
            'workout': 0.0,
          });
        }
      }
      
      if (mounted) {
        setState(() {
          // weeklyData를 API 데이터로 업데이트
          weeklyData.clear();
          weeklyData.addAll(weeklyDataFromAPI);
          _isLoading = false;
        });
        
        print('📊 Overview 주간 데이터 로드 완료: ${weeklyData.length}일');
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

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<DailyEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      
      // 미리 로드된 데이터에서 선택된 날짜의 이벤트 가져오기
      final targetDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      final dayEvents = _allEvents[targetDate] ?? [];
      _selectedEvents.value = dayEvents;
      
      print('📅 선택된 날짜: $targetDate, 이벤트 수: ${dayEvents.length}');
    }
  }


  String _getMealTime(int mealType) {
    switch (mealType) {
      case 1: return '07:00'; // Breakfast
      case 2: return '12:00'; // Lunch
      case 3: return '18:00'; // Dinner
      case 4: return '15:00'; // Snack
      default: return '12:00';
    }
  }

  String _getMealTypeName(int mealType) {
    switch (mealType) {
      case 1: return 'Breakfast';
      case 2: return 'Lunch';
      case 3: return 'Dinner';
      case 4: return 'Snack';
      default: return 'Meal';
    }
  }

  double _safeDouble(dynamic value, double defaultValue) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  int _safeInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    } else if (value is String) {
      // 문자열에서 숫자 부분만 추출하고 double로 파싱 후 int로 변환
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      final parsed = double.tryParse(cleanValue);
      print('🔢 _safeInt 변환: "$value" -> "$cleanValue" -> ${parsed?.toInt()}');
      return parsed?.toInt() ?? 0;
    }
    print('🔢 _safeInt 변환 실패: $value (타입: ${value.runtimeType})');
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('History & Analytics'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Review your fitness journey.', style: TextStyle(color: Colors.grey)),
                  _buildViewModeToggle(),
                ],
              ),
            )
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _viewMode == ViewMode.overview
          ? _buildOverviewView()
          : _buildCalendarView(),
    );
  }

  Widget _buildViewModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ToggleButtons(
        isSelected: [_viewMode == ViewMode.overview, _viewMode == ViewMode.calendar],
        onPressed: (index) {
          setState(() {
            _viewMode = index == 0 ? ViewMode.overview : ViewMode.calendar;
          });
        },
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        color: Colors.black,
        fillColor: AppColors.primary,
        constraints: const BoxConstraints(minHeight: 32, minWidth: 90),
        splashColor: Colors.transparent,
        selectedBorderColor: AppColors.primary,
        borderColor: Colors.transparent,
        children: const [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bar_chart, size: 16), SizedBox(width: 4), Text('Overview')]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_today, size: 16), SizedBox(width: 4), Text('Calendar')]),
        ],
      ),
    );
  }

  Widget _buildOverviewView() {
    // 주간 평균 영양소 계산
    final weekAvgCalories = (weeklyData.fold<double>(0, (sum, day) => sum + (day['calories']! as num)) / 7).round();
    final avgProtein = (weeklyData.fold<double>(0, (sum, day) => sum + (day['protein']! as num)) / 7).round();
    final avgCarbs = (weeklyData.fold<double>(0, (sum, day) => sum + (day['carbs']! as num)) / 7).round();
    final avgFat = (weeklyData.fold<double>(0, (sum, day) => sum + (day['fat']! as num)) / 7).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              _buildSummaryCard('Weekly Avg Calories', '$weekAvgCalories kcal', null, Icons.local_fire_department, Colors.orange),
              _buildSummaryCard('Average Carbs', '${avgCarbs}g', null, Icons.grain, Colors.brown),
              _buildSummaryCard('Average Protein', '${avgProtein}g', null, Icons.set_meal, Colors.red),
              _buildSummaryCard('Average Fat', '${avgFat}g', null, Icons.water_drop, Colors.yellow),
            ],
          ),
          const SizedBox(height: 16),
          AppTabs(
            // ✅ 오버플로우 해결: 높이를 220에서 250으로 수정
            contentHeight: 250,
            tabTitles: const ['Calories', 'Protein', 'Carbs', 'Fat'],
            tabContents: [
              _buildChartCard('Weekly Calorie Intake', 'calories', Colors.orange, isBarChart: true),
              _buildChartCard('Weekly Protein Intake', 'protein', Colors.red, isBarChart: true),
              _buildChartCard('Weekly Carbs Intake', 'carbs', Colors.brown, isBarChart: true),
              _buildChartCard('Weekly Fat Intake', 'fat', Colors.amber, isBarChart: true),
            ],
          ),
          const SizedBox(height: 24),
          _buildMonthlyGoalCard(),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    final selectedDateData = _selectedEvents.value;
    final totalCalories = selectedDateData.whereType<MealEvent>().fold<int>(0, (sum, meal) => sum + meal.calories);
    final totalProtein = selectedDateData.whereType<MealEvent>().fold<int>(0, (sum, meal) => sum + meal.protein);
    final totalCarbs = selectedDateData.whereType<MealEvent>().fold<int>(0, (sum, meal) => sum + meal.carbs);
    final totalFat = selectedDateData.whereType<MealEvent>().fold<int>(0, (sum, meal) => sum + meal.fat);
    
    // 디버깅: 선택된 날짜 데이터 확인
    print('📅 Calendar 선택된 날짜 데이터:');
    print('   - 이벤트 수: ${selectedDateData.length}');
    print('   - 총 칼로리: $totalCalories');
    print('   - 총 단백질: $totalProtein');
    print('   - 총 탄수화물: $totalCarbs');
    print('   - 총 지방: $totalFat');
    for (var event in selectedDateData) {
      if (event is MealEvent) {
        print('   - 식사: ${event.mealType} - ${event.description} (${event.calories}kcal)');
      } else if (event is WorkoutEvent) {
        print('   - 운동: ${event.workoutType} (${event.durationMinutes}분)');
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AppCard(
            content: AppCardContent(
              padding: EdgeInsets.zero,
              child: TableCalendar<DailyEvent>(
                locale: 'en_US',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: (day) {
                  final targetDate = DateTime(day.year, day.month, day.day);
                  final List<DailyEvent> events = [];
                  
                  // 실제 캐시된 이벤트 데이터 사용
                  if (_allEvents.containsKey(targetDate)) {
                    events.addAll(_allEvents[targetDate]!);
                    print('📅 이벤트 로더: $targetDate - ${events.length}개 이벤트');
                  }
                  
                  return events;
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 2,
                ),
                headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            header: AppCardHeader(
              padding: const EdgeInsets.all(16), 
              title: Text(DateFormat('yyyy-MM-dd (E)', 'en_US').format(_selectedDay!))
            ),
            content: AppCardContent(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // 통계 요약
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(totalCalories.toString(), 'kcal'),
                          _buildStatItem(totalProtein.toString(), 'protein (g)'),
                          _buildStatItem(totalCarbs.toString(), 'carbs (g)'),
                          _buildStatItem(totalFat.toString(), 'fat (g)'),
                        ],
                      ),
                  const SizedBox(height: 16),
                  // 상세 활동 내역
                  if (selectedDateData.isNotEmpty) ...[
                    const Text('📅 Daily Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...selectedDateData.map((event) {
                      print('🎯 이벤트 타일 생성: ${event.runtimeType}');
                      return _buildEventTile(event);
                    }),
                  ] else ...[
                    const Text('📅 No activities recorded', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILDER METHODS ---

  Widget _buildSummaryCard(String title, String value, double? progress, IconData icon, Color color) {
    return AppCard(
      content: AppCardContent(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, size: 16, color: color),
              ],
            ),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (progress != null) AppProgressIndicator(value: progress / 100, color: color) else const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, String dataKey, Color color, {bool isBarChart = false}) {
    return AppCard(
      header: AppCardHeader(padding: const EdgeInsets.all(16), title: Text(title)),
      content: AppCardContent(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 170,
          child: isBarChart
              ? BarChart(_buildBarChartData(dataKey, color))
              : LineChart(_buildLineChartData(dataKey, color)),
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(String dataKey, Color color) {
    Widget leftTitles(double value, TitleMeta meta) {
      if (value % 500 != 0) return Container();
      return SideTitleWidget(
        meta: meta,
        space: 4,
        child: Text(NumberFormat.compact().format(value), style: const TextStyle(fontSize: 10, color: Colors.grey)),
      );
    }

    Widget bottomTitles(double value, TitleMeta meta) {
      const style = TextStyle(fontSize: 10, color: Colors.grey);
      String text;
      if (value.toInt() >= 0 && value.toInt() < weeklyData.length) {
        text = weeklyData[value.toInt()]['date']! as String;
      } else {
        text = '';
      }
      return SideTitleWidget(meta: meta, child: Text(text, style: style));
    }

    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => Colors.black.withOpacity(0.8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => const FlLine(color: Colors.black12, strokeWidth: 1, dashArray: [5, 5]),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: leftTitles, reservedSize: 35)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitles, reservedSize: 20)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: weeklyData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value[dataKey] as num).toDouble())).toList(),
          isCurved: true,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
        )
      ],
    );
  }

  BarChartData _buildBarChartData(String dataKey, Color color) {
    Widget leftTitles(double value, TitleMeta meta) {
      if (value % 100 != 0) return Container();
      return SideTitleWidget(
        meta: meta,
        space: 4,
        child: Text(NumberFormat.compact().format(value), style: const TextStyle(fontSize: 10, color: Colors.grey)),
      );
    }

    Widget bottomTitles(double value, TitleMeta meta) {
      const style = TextStyle(fontSize: 10, color: Colors.grey);
      String text;
      if (value.toInt() >= 0 && value.toInt() < weeklyData.length) {
        text = weeklyData[value.toInt()]['date']! as String;
      } else {
        text = '';
      }
      return SideTitleWidget(meta: meta, child: Text(text, style: style));
    }

    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.black.withOpacity(0.8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${rod.toY.round()}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: leftTitles, reservedSize: 35)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitles, reservedSize: 20)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => const FlLine(color: Colors.black12, strokeWidth: 1, dashArray: [5, 5]),
      ),
      borderData: FlBorderData(show: false),
      barGroups: weeklyData.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: (e.value[dataKey] as num).toDouble(), color: color, width: 14, borderRadius: const BorderRadius.all(Radius.circular(4)))])).toList(),
    );
  }

  Widget _buildMonthlyGoalCard() {
    // 최근 7일 데이터만 추출
    final now = DateTime.now();
    final List<WorkoutEvent> weeklyWorkouts = [];
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final targetDate = DateTime(date.year, date.month, date.day);
      
      if (_allEvents.containsKey(targetDate)) {
        weeklyWorkouts.addAll(_allEvents[targetDate]!.whereType<WorkoutEvent>());
      }
    }
    
    if (weeklyWorkouts.isEmpty) {
      return AppCard(
        header: const AppCardHeader(title: Text("Weekly Workout Summary")),
        content: const AppCardContent(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No workout data available', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }
    
    // 실제 세트 데이터 기반 통계 계산
    int totalSets = 0;
    int completedSets = 0;
    int pendingSets = 0;
    int skippedSets = 0;
    final Map<String, int> exerciseSetCount = {}; // 운동별 세트 수
    final Map<String, int> muscleGroupCount = {
      'Chest': 0,
      'Back': 0,
      'Legs': 0,
      'Shoulders': 0,
      'Arms': 0,
    };
    
    final workoutDays = weeklyWorkouts.length;
    int totalWorkoutTime = 0;
    
    for (var workout in weeklyWorkouts) {
      totalWorkoutTime += workout.durationMinutes;
      
      for (var set in workout.sets) {
        totalSets++;
        
        // 세트 상태별 카운트
        if (set.status == 'completed') {
          completedSets++;
        } else if (set.status == 'pending') {
          pendingSets++;
        } else if (set.status == 'skipped') {
          skippedSets++;
        }
        
        // 운동별 세트 수 카운트
        exerciseSetCount[set.exerciseName] = (exerciseSetCount[set.exerciseName] ?? 0) + 1;
        
        // 근육 그룹별 세트 수 카운트
        final lowerExercise = set.exerciseName.toLowerCase();
        if (lowerExercise.contains('벤치') || lowerExercise.contains('bench') || lowerExercise.contains('chest')) {
          muscleGroupCount['Chest'] = muscleGroupCount['Chest']! + 1;
        } else if (lowerExercise.contains('랫풀') || lowerExercise.contains('로우') || lowerExercise.contains('lat') || lowerExercise.contains('row') || lowerExercise.contains('등')) {
          muscleGroupCount['Back'] = muscleGroupCount['Back']! + 1;
        } else if (lowerExercise.contains('스쿼트') || lowerExercise.contains('레그') || lowerExercise.contains('squat') || lowerExercise.contains('leg') || lowerExercise.contains('하체')) {
          muscleGroupCount['Legs'] = muscleGroupCount['Legs']! + 1;
        } else if (lowerExercise.contains('숄더') || lowerExercise.contains('프레스') || lowerExercise.contains('shoulder') || lowerExercise.contains('press') || lowerExercise.contains('어깨')) {
          muscleGroupCount['Shoulders'] = muscleGroupCount['Shoulders']! + 1;
        } else if (lowerExercise.contains('컬') || lowerExercise.contains('curl') || lowerExercise.contains('팔')) {
          muscleGroupCount['Arms'] = muscleGroupCount['Arms']! + 1;
        }
      }
    }
    
    // Top 3 운동 (세트 수 기준)
    final topExercises = exerciseSetCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = topExercises.take(3).toList();
    
    final maxMuscleCount = muscleGroupCount.values.isNotEmpty 
        ? muscleGroupCount.values.reduce((a, b) => a > b ? a : b) 
        : 0;
    
    return AppCard(
      header: const AppCardHeader(title: Text("Weekly Workout Summary")),
      content: AppCardContent(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 통계
            _buildStatRow(Icons.calendar_today, 'Workout Days', '$workoutDays / 7 days', Colors.blue),
            _buildStatRow(Icons.timer, 'Total Workout Time', '$totalWorkoutTime min', Colors.green),
            _buildStatRow(Icons.check_circle, 'Completed Sets', '$completedSets sets', Colors.orange),
            
            const Divider(height: 24),
            
            // 세트 완료율
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('📊 Set Completion Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Expanded(
                  flex: completedSets,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                    ),
                  ),
                ),
                if (pendingSets > 0)
                  Expanded(
                    flex: pendingSets,
                    child: Container(height: 8, color: Colors.orange),
                  ),
                if (skippedSets > 0)
                  Expanded(
                    flex: skippedSets,
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('✅ $completedSets', style: const TextStyle(fontSize: 11, color: Colors.green)),
                  Text('⏸️ $pendingSets', style: const TextStyle(fontSize: 11, color: Colors.orange)),
                  Text('❌ $skippedSets', style: const TextStyle(fontSize: 11, color: Colors.red)),
                ],
              ),
            ),
            
            if (top3.isNotEmpty) ...[
              const Divider(height: 24),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('🏆 Top Exercises', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              ...top3.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(exercise.key, style: const TextStyle(fontSize: 13))),
                      Text('${exercise.value} sets', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }),
            ],
            
            if (maxMuscleCount > 0) ...[
              const Divider(height: 24),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('💪 Muscle Group Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              ...muscleGroupCount.entries.where((e) => e.value > 0).map((entry) {
                final progress = entry.value / maxMuscleCount;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 12)),
                          Text('${entry.value} sets', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppProgressIndicator(value: progress, color: _getMuscleGroupColor(entry.key)),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
  
  Color _getMuscleGroupColor(String muscleGroup) {
    switch (muscleGroup) {
      case 'Chest': return Colors.red;
      case 'Back': return Colors.blue;
      case 'Legs': return Colors.green;
      case 'Shoulders': return Colors.orange;
      case 'Arms': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Widget _buildProgressRow(String title, String value, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text(value, style: const TextStyle(color: Colors.grey))],
          ),
          const SizedBox(height: 4),
          AppProgressIndicator(value: progress / 100),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEventTile(DailyEvent event) {
    if (event is MealEvent) {
      return _buildMealCard(event);
    } else if (event is WorkoutEvent) {
      return _buildWorkoutCard(event);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMealCard(MealEvent meal) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.orange, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(meal.mealType, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(meal.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
            Text('${meal.calories} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutEvent workout) {
    // 운동 목록을 문자열로 변환 (길이 제한)
    String exerciseList = workout.exercises.join(', ');
    if (exerciseList.length > 40) {
      exerciseList = '${exerciseList.substring(0, 40)}...';
    }
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.blue, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(workout.workoutType, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(exerciseList, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
          ],
        ),
      ),
    );
  }
}