// lib/screens/diet_tracker_screen.dart (수정본)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_data.dart';
import '../widgets/app_card.dart';
import '../widgets/app_progress_indicator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_camera_modal.dart';
import '../widgets/manual_food_entry.dart';

class DietTrackerScreen extends StatefulWidget {
  // 1. user 데이터를 전달받을 변수 선언
  final Map<String, dynamic> user;

  // 2. 생성자에서 user 데이터를 필수로 받도록 수정
  const DietTrackerScreen({super.key, required this.user});

  @override
  State<DietTrackerScreen> createState() => _DietTrackerScreenState();
}

class _DietTrackerScreenState extends State<DietTrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isAnalyzing = false;

  final List<Meal> _meals = [
    Meal(id: 1, name: "Breakfast", time: "08:30", foods: [Food(name: "Protein Smoothie", calories: 320, protein: 25), Food(name: "Banana", calories: 105, protein: 1)], totalCalories: 425, image: null),
    Meal(id: 2, name: "Lunch", time: "13:15", foods: [Food(name: "Grilled Chicken Breast", calories: 185, protein: 35), Food(name: "Mixed Salad", calories: 45, protein: 3), Food(name: "Brown Rice", calories: 220, protein: 5)], totalCalories: 450, image: "placeholder"),
    Meal(id: 3, name: "Dinner", time: "19:45", foods: [Food(name: "Salmon Fillet", calories: 280, protein: 39), Food(name: "Steamed Vegetables", calories: 80, protein: 4), Food(name: "Sweet Potato", calories: 245, protein: 2)], totalCalories: 605, image: "placeholder"),
  ];

 void _handlePhotoAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 내용이 길어져도 스크롤 가능하게
      backgroundColor: Colors.transparent, // 모달 배경을 투명하게
      builder: (context) {
        return AppCameraModal(
          onImageSelected: (File image) async {
            // 이미지가 최종 선택되면 AI 분석 시작
            print('Selected image path: ${image.path}');
            setState(() => _isAnalyzing = true);
            await Future.delayed(const Duration(seconds: 2));
            setState(() => _isAnalyzing = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("AI analysis would complete here.")),
              );
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
          child: const ManualFoodEntry(),
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
    return AppCard(
      header: const AppCardHeader(title: Text('Daily Nutrition')),
      content: AppCardContent(
        child: Column(
          children: [
            _buildProgressRow('Calories', 1480, 2000),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalItem('85g', 'Protein', 'Goal: 120g', Colors.blue),
                _buildGoalItem('180g', 'Carbs', 'Goal: 250g', Colors.green),
                _buildGoalItem('45g', 'Fat', 'Goal: 65g', Colors.orange),
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
  
  Widget _buildGoalItem(String value, String label, String goal, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(goal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Today's Meals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._meals.map((meal) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AppCard(
            // AppCardContent에 새로 만든 padding 속성을 사용합니다.
            content: AppCardContent(
              // horizontal(좌우)은 24, vertical(상하)은 16의 패딩을 줍니다.
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(meal.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(meal.time, style: const TextStyle(color: Colors.grey)),
                      ]),
                      AppBadge(text: '${meal.totalCalories} kcal', variant: AppBadgeVariant.secondary),
                    ],
                  ),
                  if (meal.image != null) ...[
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
                        Text(food.name),
                        Text('${food.calories}kcal • ${food.protein}g protein', style: const TextStyle(color: Colors.grey)),
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