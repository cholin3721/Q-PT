// lib/models/meal_data.dart
import 'food_item.dart';

class Meal {
  final int id;
  final int mealType;
  final String? imageUrl;
  final List<FoodItem> foods;

  Meal({
    required this.id,
    required this.mealType,
    this.imageUrl,
    required this.foods,
  });

  // JSON에서 객체 생성
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['mealLogId'] ?? json['id'] ?? 0,
      mealType: json['mealType'] ?? 0,
      imageUrl: json['imageUrl'],
      foods: (json['foods'] as List<dynamic>?)
          ?.map((food) => FoodItem.fromJson(food))
          .toList() ?? [],
    );
  }

  // 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'imageUrl': imageUrl,
      'foods': foods.map((food) => food.toJson()).toList(),
    };
  }

  // 총 칼로리 계산
  double get totalCalories {
    return foods.fold(0.0, (sum, food) => sum + food.calories);
  }

  // 총 단백질 계산
  double get totalProtein {
    return foods.fold(0.0, (sum, food) => sum + food.protein);
  }

  // 총 탄수화물 계산
  double get totalCarbs {
    return foods.fold(0.0, (sum, food) => sum + food.carbs);
  }

  // 총 지방 계산
  double get totalFat {
    return foods.fold(0.0, (sum, food) => sum + food.fat);
  }
}

class MealLog {
  final String date;
  final Map<String, double> totalNutrition;
  final List<Meal> meals;

  MealLog({
    required this.date,
    required this.totalNutrition,
    required this.meals,
  });

  // JSON에서 객체 생성
  factory MealLog.fromJson(Map<String, dynamic> json) {
    // 안전한 타입 변환
    final totalNutrition = json['totalNutrition'] as Map<String, dynamic>? ?? {};
    final convertedNutrition = <String, double>{};
    
    totalNutrition.forEach((key, value) {
      if (value is num) {
        convertedNutrition[key] = value.toDouble();
      } else if (value is String) {
        // 문자열에서 숫자 부분만 추출
        final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
        convertedNutrition[key] = double.tryParse(cleanValue) ?? 0.0;
      }
    });
    
    return MealLog(
      date: json['date'] ?? '',
      totalNutrition: convertedNutrition,
      meals: (json['meals'] as List<dynamic>?)
          ?.map((meal) => Meal.fromJson(meal))
          .toList() ?? [],
    );
  }
}