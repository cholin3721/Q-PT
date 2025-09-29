// lib/widgets/manual_food_entry.dart (최종 완성본)

import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'app_select.dart';
import 'app_input.dart';
import 'app_card.dart';
import 'app_button.dart';
import 'app_label.dart';

class ManualFoodEntry extends StatefulWidget {
  const ManualFoodEntry({super.key});

  @override
  State<ManualFoodEntry> createState() => _ManualFoodEntryState();
}

class _ManualFoodEntryState extends State<ManualFoodEntry> {
  // --- 상태 변수 ---
  String _mealType = '아침식사';
  final _searchController = TextEditingController();
  List<FoodItem> _selectedFoods = [];
  List<FoodItem> _filteredFoods = [];

  // --- 1. 직접 입력을 위한 컨트롤러 추가 ---
  final _customNameController = TextEditingController();
  final _customCaloriesController = TextEditingController();
  final _customProteinController = TextEditingController();
  final _customCarbsController = TextEditingController();
  final _customFatController = TextEditingController();

  // --- Mock 데이터 ---
  final List<FoodItem> _foodDatabase = [
    FoodItem(id: "1", name: "닭가슴살", calories: 165, protein: 31, carbs: 0, fat: 3.6),
    FoodItem(id: "2", name: "현미밥", calories: 112, protein: 2.6, carbs: 22, fat: 0.9),
    FoodItem(id: "3", name: "브로콜리", calories: 34, protein: 2.8, carbs: 7, fat: 0.4),
    FoodItem(id: "4", name: "계란", calories: 155, protein: 13, carbs: 1.1, fat: 11),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFoods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    // --- 2. 추가된 컨트롤러 정리 ---
    _customNameController.dispose();
    _customCaloriesController.dispose();
    _customProteinController.dispose();
    _customCarbsController.dispose();
    _customFatController.dispose();
    super.dispose();
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoods = _foodDatabase.where((food) => food.name.toLowerCase().contains(query)).toList();
    });
  }

  void _addFood(FoodItem food) {
    setState(() {
      _selectedFoods.add(food.copyWith(id: 'selected-${DateTime.now().millisecondsSinceEpoch}'));
    });
  }

  void _removeFood(String id) {
    setState(() {
      _selectedFoods.removeWhere((food) => food.id == id);
    });
  }

  // --- 3. 직접 입력한 음식을 추가하는 함수 ---
  void _addCustomFood() {
    final name = _customNameController.text;
    final calories = double.tryParse(_customCaloriesController.text) ?? 0;

    if (name.isNotEmpty && calories > 0) {
      final newFood = FoodItem(
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        calories: calories,
        protein: double.tryParse(_customProteinController.text) ?? 0,
        carbs: double.tryParse(_customCarbsController.text) ?? 0,
        fat: double.tryParse(_customFatController.text) ?? 0,
      );

      setState(() {
        _selectedFoods.add(newFood);
        // 입력창 초기화
        _customNameController.clear();
        _customCaloriesController.clear();
        _customProteinController.clear();
        _customCarbsController.clear();
        _customFatController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalCalories = _selectedFoods.fold(0, (sum, item) => sum + item.calories);
    double totalProtein = _selectedFoods.fold(0, (sum, item) => sum + item.protein);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ... 헤더, 식사 종류, 음식 검색, 검색 결과 ... (이전과 동일)
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('식단 수기 입력', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 24),
          AppSelect(
            items: const ['아침식사', '점심식사', '저녁식사', '간식'],
            value: _mealType,
            onChanged: (value) => setState(() => _mealType = value ?? '아침식사'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: '음식 검색', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isNotEmpty && _filteredFoods.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _filteredFoods.length,
                itemBuilder: (context, index) {
                  final food = _filteredFoods[index];
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text('${food.calories}kcal / 100g'),
                    trailing: IconButton(icon: const Icon(Icons.add), onPressed: () => _addFood(food)),
                  );
                },
              ),
            ),

          // --- 4. 직접 입력 UI 추가 ---
          const SizedBox(height: 16),
          _buildCustomFoodEntry(),

          // --- 선택된 음식 목록 및 요약 ---
          if (_selectedFoods.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('선택된 음식 (${_selectedFoods.length}개)', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _selectedFoods.length,
                itemBuilder: (context, index) {
                  final food = _selectedFoods[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(food.name),
                      subtitle: Text('${food.calories}kcal • ${food.protein}g 단백질'),
                      trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => _removeFood(food.id)),
                    ),
                  );
                },
              ),
            ),
            AppCard(
              content: AppCardContent(
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('총 칼로리:'), Text('${totalCalories.toStringAsFixed(0)}kcal')]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('총 단백질:'), Text('${totalProtein.toStringAsFixed(1)}g')]),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          // 저장/취소 버튼
          Row(children: [
            Expanded(child: AppButton(onPressed: () => Navigator.of(context).pop(), variant: AppButtonVariant.outline, child: const Text('취소'))),
            const SizedBox(width: 8),
            Expanded(child: AppButton(onPressed: () {}, child: const Text('저장하기'))),
          ]),
        ],
      ),
    );
  }

  // --- 5. 직접 입력 UI를 만드는 빌더 메소드 ---
  Widget _buildCustomFoodEntry() {
    return AppCard(
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('직접 입력', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AppInput(controller: _customNameController, hintText: '음식명'),
                AppInput(controller: _customCaloriesController, hintText: '칼로리', keyboardType: TextInputType.number),
                AppInput(controller: _customProteinController, hintText: '단백질(g)', keyboardType: TextInputType.number),
                AppInput(controller: _customCarbsController, hintText: '탄수화물(g)', keyboardType: TextInputType.number),
                AppInput(controller: _customFatController, hintText: '지방(g)', keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 12),
            AppButton(
              onPressed: _addCustomFood,
              size: AppButtonSize.sm,
              child: const Text('추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}