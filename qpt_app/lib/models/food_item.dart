// lib/models/food_item.dart

class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  
  // 객체를 복사하면서 일부 값을 변경할 수 있는 메소드 (ID를 새로 부여할 때 유용)
  FoodItem copyWith({String? id}) {
    return FoodItem(
      id: id ?? this.id,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }
}