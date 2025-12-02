// lib/models/food_item.dart

class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSizeGrams;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.servingSizeGrams = 100.0,
  });

  // JSON에서 객체 생성
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // 안전한 타입 변환
    double safeDouble(dynamic value, double defaultValue) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        // 문자열에서 숫자 부분만 추출
        final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
        return double.tryParse(cleanValue) ?? defaultValue;
      }
      return defaultValue;
    }
    
    return FoodItem(
      id: json['loggedFoodId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['foodName'] ?? json['name'] ?? '',
      calories: safeDouble(json['calories'], 0.0),
      protein: safeDouble(json['protein'], 0.0),
      carbs: safeDouble(json['carbs'], 0.0),
      fat: safeDouble(json['fat'], 0.0),
      servingSizeGrams: safeDouble(json['servingSizeGrams'], 100.0),
    );
  }

  // 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'foodName': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servingSizeGrams': servingSizeGrams,
    };
  }
  
  // 객체를 복사하면서 일부 값을 변경할 수 있는 메소드
  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? servingSizeGrams,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      servingSizeGrams: servingSizeGrams ?? this.servingSizeGrams,
    );
  }
}