// lib/screens/diet_tracker_screen.dart (수정본)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_data.dart';
import '../models/food_item.dart';
import '../widgets/app_card.dart';
import '../widgets/app_progress_indicator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_camera_modal.dart';
import '../widgets/manual_food_entry.dart';
import '../services/api_service.dart';
import '../services/meal_api_service.dart';

class DietTrackerScreen extends StatefulWidget {
  // 1. user 데이터를 전달받을 변수 선언
  final Map<String, dynamic> user;

  // 2. 생성자에서 user 데이터를 필수로 받도록 수정
  const DietTrackerScreen({super.key, required this.user});

  @override
  State<DietTrackerScreen> createState() => DietTrackerScreenState();
}

class DietTrackerScreenState extends State<DietTrackerScreen> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  DateTime _selectedDate = DateTime.now();
  bool _isAnalyzing = false;
  bool _isLoading = true;
  
  final ApiService _apiService = ApiService();
  final MealApiService _mealApiService = MealApiService();
  
  MealLog? _mealLog;
  Map<String, dynamic>? _activeGoal;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMealData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 다시 포그라운드로 돌아올 때 데이터 새로고침
    if (state == AppLifecycleState.resumed) {
      _loadMealData();
    }
  }

  // Public 메서드로 외부에서 새로고침 가능하도록
  void refreshData() {
    _loadMealData();
  }

  // 안전하게 double로 변환하는 헬퍼 메서드
  double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Future<void> _loadMealData() async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      // 식단 데이터 로드
      final mealsData = await _apiService.getMeals(dateString);
      final mealLog = MealLog.fromJson(mealsData);
      
      // 활성 목표 로드
      final goalData = await _apiService.getActiveGoal();
      
      if (mounted) {
        setState(() {
          _mealLog = mealLog;
          _activeGoal = goalData;
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

  void _handlePhotoAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AppCameraModal(
          onImageSelected: (File image) async {
            Navigator.of(context).pop(); // 카메라 모달 닫기
            
            setState(() => _isAnalyzing = true);
            
            try {
              // AI 분석 실행
              final analysisResult = await _mealApiService.analyzeFoodImage(image);
              
              if (mounted) {
                setState(() => _isAnalyzing = false);
                
                // 분석 결과를 FoodItem 리스트로 변환
                List<FoodItem> initialFoods = [];
                
                // recommended 음식을 먼저 추가
                final recommendedData = analysisResult['recommended'];
                if (recommendedData != null) {
                  final recommended = recommendedData as Map<String, dynamic>;
                  final foodName = recommended['foodName'] as String? ?? '';
                  final foodItem = FoodItem(
                    id: 'recommended-${DateTime.now().millisecondsSinceEpoch}',
                    name: foodName,
                    calories: _parseDouble(recommended['calories']),
                    protein: _parseDouble(recommended['protein']),
                    carbs: _parseDouble(recommended['carbs']),
                    fat: _parseDouble(recommended['fat']),
                    servingSizeGrams: _parseDouble(recommended['servingSizeGrams'], 100.0),
                  );
                  initialFoods.add(foodItem);
                }
                
                // candidates도 추가 (recommended와 중복되지 않는 것만)
                final candidatesData = analysisResult['candidates'];
                if (candidatesData != null) {
                  final candidates = candidatesData as List<dynamic>;
                  final recommendedName = (recommendedData as Map<String, dynamic>?)?['foodName'] as String?;
                  
                  for (var i = 0; i < candidates.length; i++) {
                    final candidate = candidates[i] as Map<String, dynamic>;
                    final candidateName = candidate['foodName'] as String? ?? '';
                    if (candidateName != recommendedName) {
                      final foodItem = FoodItem(
                        id: 'candidate-$i-${DateTime.now().millisecondsSinceEpoch}',
                        name: candidateName,
                        calories: _parseDouble(candidate['calories']),
                        protein: _parseDouble(candidate['protein']),
                        carbs: _parseDouble(candidate['carbs']),
                        fat: _parseDouble(candidate['fat']),
                        servingSizeGrams: _parseDouble(candidate['servingSizeGrams'], 100.0),
                      );
                      initialFoods.add(foodItem);
                    }
                  }
                }
                
                // ManualFoodEntry 모달 열기 (분석 결과를 초기값으로)
                final recognizedLabels = analysisResult['recognizedLabels'] as List<dynamic>?;
                final foodsByLabel = analysisResult['foodsByLabel'] as Map<String, dynamic>?;
                
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.9,
                    builder: (_, controller) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: ManualFoodEntry(
                        initialFoods: initialFoods,
                        recognizedLabels: recognizedLabels,
                        foodsByLabel: foodsByLabel,
                        onMealAdded: () {
                          _loadMealData();
                        },
                      ),
                    ),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                setState(() => _isAnalyzing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('분석 실패: ${e.toString()}')),
                );
              }
            }
          },
        );
      },
    );
  }

   void _handleAddMealManually() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 모달이 화면의 대부분을 차지할 수 있도록 함
      builder: (context) => DraggableScrollableSheet( // 모달을 드래그해서 닫을 수 있게 함
        expand: false,
        initialChildSize: 0.9, // 초기 높이를 화면의 90%로 설정
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ManualFoodEntry(
            onMealAdded: () {
              // 식단 추가 후 데이터 새로고침
              _loadMealData();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });
      await _loadMealData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수
    
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildDailyNutrition(),
          const SizedBox(height: 24),
          _buildAddMealActions(),
          const SizedBox(height: 24),
          _buildMealHistory(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Diet Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailyNutrition() {
    final totalCalories = _mealLog?.totalNutrition['calories'] ?? 0.0;
    final totalProtein = _mealLog?.totalNutrition['protein'] ?? 0.0;
    final totalCarbs = _mealLog?.totalNutrition['carbs'] ?? 0.0;
    final totalFat = _mealLog?.totalNutrition['fat'] ?? 0.0;
    
    // 목표가 설정되어 있는지 확인
    final hasGoal = _activeGoal?['targetCalories'] != null;

    return AppCard(
      header: AppCardHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daily Nutrition'),
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
        child: Column(
          children: [
            if (!hasGoal) ...[
              // 목표가 없을 때 안내 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.flag, size: 48, color: Colors.blue.shade300),
                    const SizedBox(height: 12),
                    const Text(
                      '영양소 목표가 설정되지 않았습니다',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI Trainer에서 분석을 받고\n목표를 설정해보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                '현재 섭취량 (참고용)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // 목표가 있을 때 진행률 표시
              _buildProgressRow('Calories', totalCalories, _parseDouble(_activeGoal!['targetCalories'])),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalItem(
                  '${totalProtein.toStringAsFixed(0)}g',
                  'Protein',
                  hasGoal ? 'Goal: ${_parseDouble(_activeGoal!['targetProtein']).toStringAsFixed(0)}g' : null,
                  Colors.blue,
                ),
                _buildGoalItem(
                  '${totalCarbs.toStringAsFixed(0)}g',
                  'Carbs',
                  hasGoal ? 'Goal: ${_parseDouble(_activeGoal!['targetCarbs']).toStringAsFixed(0)}g' : null,
                  Colors.green,
                ),
                _buildGoalItem(
                  '${totalFat.toStringAsFixed(0)}g',
                  'Fat',
                  hasGoal ? 'Goal: ${_parseDouble(_activeGoal!['targetFat']).toStringAsFixed(0)}g' : null,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String title, num current, num target) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title), Text('$current / $target')]),
        const SizedBox(height: 8),
        AppProgressIndicator(value: current / target),
      ],
    );
  }
  
  Widget _buildGoalItem(String value, String label, String? goal, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        if (goal != null)
          Text(goal, style: const TextStyle(fontSize: 10, color: Colors.grey))
        else
          Text(
            '목표 미설정',
            style: TextStyle(fontSize: 10, color: Colors.orange.shade400, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  Widget _buildAddMealActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 80,
            child: AppButton(
              // 1. 'Photo Analysis' 버튼에 _handlePhotoAnalysis 함수를 연결합니다.
              onPressed: _handlePhotoAnalysis,
              child: _isAnalyzing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt), Text('Photo Analysis')]),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 80,
            child: AppButton(
              // 2. 'Add Manually' 버튼에 _handleAddMealManually 함수를 연결합니다.
              onPressed: _handleAddMealManually,
              variant: AppButtonVariant.outline,
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add), Text('Add Manually')]),
            ),
          ),
        ),
      ],
    );
  }

// lib/screens/diet_tracker_screen.dart

  Widget _buildMealHistory() {
    final meals = _mealLog?.meals ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Today's Meals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (meals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                '아직 기록된 식단이 없습니다.\n위의 버튼을 눌러 식단을 기록해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          ...meals.map((meal) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppCard(
              content: AppCardContent(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Meal ${meal.mealType}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('${meal.foods.length} items', style: const TextStyle(color: Colors.grey)),
                        ]),
                        AppBadge(text: '${meal.totalCalories.toStringAsFixed(0)} kcal', variant: AppBadgeVariant.secondary),
                      ],
                    ),
                    if (meal.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 128,
                          color: Colors.grey.shade200,
                          child: const Center(child: Text('Meal Photo')),
                        ),
                      )
                    ],
                    const SizedBox(height: 12),
                    ...meal.foods.map((food) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(food.name)),
                          Text('${food.calories.toStringAsFixed(0)}kcal • ${food.protein.toStringAsFixed(0)}g protein', 
                               style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          )),
      ],
    );
  }
}