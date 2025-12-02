// lib/widgets/manual_food_entry.dart (Improved Version)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import 'app_select.dart';
import 'app_input.dart';
import 'app_card.dart';
import 'app_button.dart';

class ManualFoodEntry extends StatefulWidget {
  final Function()? onMealAdded;
  final List<FoodItem>? initialFoods; // 초기 음식 리스트 (사진 분석 결과 등)
  final List<dynamic>? recognizedLabels; // 인식된 라벨 목록
  final Map<String, dynamic>? foodsByLabel; // 라벨별로 그룹화된 음식들
  const ManualFoodEntry({
    super.key, 
    this.onMealAdded, 
    this.initialFoods,
    this.recognizedLabels,
    this.foodsByLabel,
  });

  @override
  State<ManualFoodEntry> createState() => _ManualFoodEntryState();
}

class _ManualFoodEntryState extends State<ManualFoodEntry> {
  final ApiService _apiService = ApiService();
  String _mealType = 'Breakfast';
  final _searchController = TextEditingController();
  List<FoodItem> _selectedFoods = [];
  List<FoodItem> _filteredFoods = [];
  bool _isSaving = false;
  String? _selectedLabel; // 현재 선택된 라벨 (필터링용)

  final _customNameController = TextEditingController();
  final _customCaloriesController = TextEditingController();
  final _customProteinController = TextEditingController();
  final _customCarbsController = TextEditingController();
  final _customFatController = TextEditingController();

  final List<FoodItem> _foodDatabase = [
    FoodItem(id: "1",
        name: "Chicken Breast",
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6),
    FoodItem(id: "2",
        name: "Brown Rice",
        calories: 112,
        protein: 2.6,
        carbs: 22,
        fat: 0.9),
    FoodItem(id: "3",
        name: "Broccoli",
        calories: 34,
        protein: 2.8,
        carbs: 7,
        fat: 0.4),
    FoodItem(id: "4",
        name: "Egg",
        calories: 155,
        protein: 13,
        carbs: 1.1,
        fat: 11),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFoods);
    
    // 추천 음식 1개만 자동 선택 (첫 번째 것만)
    if (widget.initialFoods != null && widget.initialFoods!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          // recommended만 자동 선택
          final recommended = widget.initialFoods!.first;
          _selectedFoods = [
            recommended.copyWith(id: 'initial-${DateTime.now().millisecondsSinceEpoch}-${recommended.id}')
          ];
        });
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    _customCaloriesController.dispose();
    _customProteinController.dispose();
    _customCarbsController.dispose();
    _customFatController.dispose();
    super.dispose();
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredFoods = []);
      return;
    }
    setState(() {
      _filteredFoods =
          _foodDatabase
              .where((food) => food.name.toLowerCase().contains(query))
              .toList();
    });
  }

  void _addFood(FoodItem food) {
    setState(() {
      _selectedFoods.add(food.copyWith(id: 'selected-${DateTime
          .now()
          .millisecondsSinceEpoch}'));
      _searchController.clear();
    });
  }

  void _removeFood(String id) {
    setState(() {
      _selectedFoods.removeWhere((food) => food.id == id);
    });
  }

  void _addCustomFood() {
    final name = _customNameController.text.trim();
    final caloriesText = _customCaloriesController.text.trim();

    // 입력 검증
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('음식 이름을 입력해주세요!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (caloriesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('칼로리를 입력해주세요!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final calories = double.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('칼로리는 0보다 큰 숫자여야 합니다!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 단백질, 탄수화물, 지방 검증
    final protein = double.tryParse(_customProteinController.text.trim()) ?? 0;
    final carbs = double.tryParse(_customCarbsController.text.trim()) ?? 0;
    final fat = double.tryParse(_customFatController.text.trim()) ?? 0;

    if (protein < 0 || carbs < 0 || fat < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('영양소 값은 0 이상이어야 합니다!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 음식 추가
    final newFood = FoodItem(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    setState(() {
      _selectedFoods.add(newFood);
      _customNameController.clear();
      _customCaloriesController.clear();
      _customProteinController.clear();
      _customCarbsController.clear();
      _customFatController.clear();
      FocusScope.of(context).unfocus(); // Clear focus from text fields
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name이(가) 추가되었습니다!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalCalories = _selectedFoods.fold(
        0, (sum, item) => sum + item.calories);
    double totalProtein = _selectedFoods.fold(
        0, (sum, item) => sum + item.protein);
    double totalCarbs = _selectedFoods.fold(
        0, (sum, item) => sum + item.carbs);
    double totalFat = _selectedFoods.fold(
        0, (sum, item) => sum + item.fat);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Row(
              children: [
                Icon(Icons.edit_note_outlined),
                SizedBox(width: 8),
                Text('Log Meal Manually', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            IconButton(icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 24),
          AppSelect(
            items: const ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
            value: _mealType,
            onChanged: (value) =>
                setState(() => _mealType = value ?? 'Breakfast'),
          ),
          const SizedBox(height: 16),
          
          // 인식된 라벨별 음식 선택 섹션
          if (widget.recognizedLabels != null && widget.recognizedLabels!.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: Colors.blue),
                SizedBox(width: 8),
                Text('AI 인식 결과', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecognizedLabelsSection(),
            const SizedBox(height: 16),
            _buildFilteredFoodsList(),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],
          
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: 'Search for a food',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder()),
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
                    subtitle: Text(
                        '${food.calories.toStringAsFixed(0)} kcal / 100g'),
                    trailing: IconButton(icon: const Icon(
                        Icons.add_circle_outline, color: Colors.green),
                        onPressed: () => _addFood(food)),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),
          _buildCustomFoodEntry(),

          if (_selectedFoods.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.list_alt_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Selected Foods (${_selectedFoods.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
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
                      subtitle: Text('${food.calories.toStringAsFixed(
                          0)} kcal • ${food.protein.toStringAsFixed(
                          1)}g protein'),
                      trailing: IconButton(icon: const Icon(Icons.close,
                          size: 16, color: Colors.redAccent),
                          onPressed: () => _removeFood(food.id)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              content: AppCardContent(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Calories:'),
                          Text('${totalCalories.toStringAsFixed(0)} kcal',
                              style: const TextStyle(fontWeight: FontWeight
                                  .bold))
                        ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Protein:'),
                          Text('${totalProtein.toStringAsFixed(1)}g',
                              style: const TextStyle(fontWeight: FontWeight
                                  .bold))
                        ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Carbs:'),
                          Text('${totalCarbs.toStringAsFixed(1)}g',
                              style: const TextStyle(fontWeight: FontWeight
                                  .bold))
                        ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Fat:'),
                          Text('${totalFat.toStringAsFixed(1)}g',
                              style: const TextStyle(fontWeight: FontWeight
                                  .bold))
                        ]),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: AppButton(
                onPressed: () => Navigator.of(context).pop(),
                variant: AppButtonVariant.outline,
                child: const Text('Cancel'))),
            const SizedBox(width: 8),
            Expanded(child: AppButton(
              onPressed: _isSaving ? null : _handleSaveMeal,
              child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_alt_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Save'),
                    ],
                  ),
            )),
          ]),
        ],
      ),
    );
  }

  String? _validateInput() {
    // 음식이 하나도 없는 경우
    if (_selectedFoods.isEmpty) {
      return '음식을 추가해주세요!';
    }

    // 각 음식의 칼로리가 유효한지 확인
    for (var food in _selectedFoods) {
      if (food.calories <= 0) {
        return '${food.name}의 칼로리가 유효하지 않습니다.';
      }
      if (food.name.trim().isEmpty) {
        return '음식 이름을 입력해주세요.';
      }
    }

    return null; // 검증 통과
  }

  Future<void> _handleSaveMeal() async {
    // 입력 검증
    final validationError = _validateInput();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 현재 날짜
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // mealType 변환 (영어 -> 숫자)
      final mealTypeMap = {
        'Breakfast': 1,
        'Lunch': 2,
        'Dinner': 3,
        'Snack': 4,
      };

      // API 호출
      await _apiService.createMeal({
        'mealDate': today,
        'mealType': mealTypeMap[_mealType] ?? 1,
        'foods': _selectedFoods.map((food) => {
          'foodName': food.name,
          'calories': food.calories,
          'protein': food.protein,
          'carbs': food.carbs,
          'fat': food.fat,
          'servingSizeGrams': food.servingSizeGrams,
        }).toList(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('식단이 저장되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );

        // 부모 위젯에 알림
        widget.onMealAdded?.call();
      }
    } catch (e) {
      print('❌ 식단 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('식단 저장 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildRecognizedLabelsSection() {
    if (widget.recognizedLabels == null || widget.recognizedLabels!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.recognizedLabels!.length + 1, // +1 for "전체" 버튼
        itemBuilder: (context, index) {
          if (index == 0) {
            // "전체" 버튼
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: const Text('전체'),
                selected: _selectedLabel == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedLabel = null;
                  });
                },
              ),
            );
          }
          
          final labelIndex = index - 1;
          final labelData = widget.recognizedLabels![labelIndex] as Map<String, dynamic>;
          final label = labelData['label'] as String? ?? '';
          final koreanKeyword = labelData['koreanKeyword'] as String? ?? '';
          final displayLabel = koreanKeyword.isNotEmpty ? koreanKeyword : label;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(displayLabel),
              selected: _selectedLabel == displayLabel,
              onSelected: (selected) {
                setState(() {
                  _selectedLabel = selected ? displayLabel : null;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilteredFoodsList() {
    if (widget.foodsByLabel == null || widget.foodsByLabel!.isEmpty) {
      return const SizedBox.shrink();
    }

    // 선택된 라벨에 따라 필터링
    List<dynamic> foodsToShow = [];
    
    if (_selectedLabel == null) {
      // 전체 표시: 모든 라벨의 음식들을 합침 (중복 제거)
      final allFoods = <String, Map<String, dynamic>>{};
      for (final entry in widget.foodsByLabel!.entries) {
        final foods = entry.value as List<dynamic>?;
        if (foods != null) {
          for (final food in foods) {
            final foodMap = food as Map<String, dynamic>;
            final foodName = foodMap['foodName'] as String? ?? '';
            if (!allFoods.containsKey(foodName)) {
              allFoods[foodName] = foodMap;
            }
          }
        }
      }
      foodsToShow = allFoods.values.toList();
    } else {
      // 선택된 라벨의 음식만 표시
      // 라벨로 직접 찾기 시도
      foodsToShow = widget.foodsByLabel![_selectedLabel] as List<dynamic>? ?? [];
      
      // 직접 찾지 못하면 부분 매칭 시도
      if (foodsToShow.isEmpty) {
        for (final key in widget.foodsByLabel!.keys) {
          if (key.toString().contains(_selectedLabel!) || _selectedLabel!.contains(key.toString())) {
            foodsToShow = widget.foodsByLabel![key] as List<dynamic>? ?? [];
            if (foodsToShow.isNotEmpty) break;
          }
        }
      }
    }

    if (foodsToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: foodsToShow.length,
        itemBuilder: (context, index) {
          final food = foodsToShow[index] as Map<String, dynamic>;
          final foodName = food['foodName'] as String? ?? '';
          final calories = (food['calories'] as num?)?.toDouble() ?? 0.0;
          final protein = (food['protein'] as num?)?.toDouble() ?? 0.0;
          final carbs = (food['carbs'] as num?)?.toDouble() ?? 0.0;
          final fat = (food['fat'] as num?)?.toDouble() ?? 0.0;
          final servingSize = (food['servingSizeGrams'] as num?)?.toDouble() ?? 100.0;
          
          // 이미 선택된 음식인지 확인
          final isSelected = _selectedFoods.any((f) => f.name == foodName);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(foodName),
              subtitle: Text(
                '${calories.toStringAsFixed(0)}kcal • 단${protein.toStringAsFixed(1)}g • 탄${carbs.toStringAsFixed(1)}g • 지${fat.toStringAsFixed(1)}g',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () {
                        final foodItem = FoodItem(
                          id: 'label-${DateTime.now().millisecondsSinceEpoch}-$index',
                          name: foodName,
                          calories: calories,
                          protein: protein,
                          carbs: carbs,
                          fat: fat,
                          servingSizeGrams: servingSize,
                        );
                        _addFood(foodItem);
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomFoodEntry() {
    return AppCard(
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ 이 부분을 추가하여 카드 상단에 내부 여백을 만듭니다.
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.drive_file_rename_outline_outlined, size: 16),
                SizedBox(width: 8),
                Text('Enter Manually',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
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
                AppInput(
                    controller: _customNameController, 
                    hintText: 'Food name'),
                AppInput(
                    controller: _customCaloriesController,
                    hintText: 'Calories',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ]),
                AppInput(
                    controller: _customProteinController,
                    hintText: 'Protein (g)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ]),
                AppInput(
                    controller: _customCarbsController,
                    hintText: 'Carbs (g)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ]),
                AppInput(
                    controller: _customFatController,
                    hintText: 'Fat (g)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ]),
              ],
            ),
            const SizedBox(height: 12),
            AppButton(
              onPressed: _addCustomFood,
              size: AppButtonSize.sm,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Add'),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}