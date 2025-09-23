// lib/models/meal_data.dart

class Food {
  final String name;
  final int calories;
  final int protein;

  Food({required this.name, required this.calories, required this.protein});
}

class Meal {
  final int id;
  final String name;
  final String time;
  final List<Food> foods;
  final int totalCalories;
  final String? image;

  Meal({
    required this.id,
    required this.name,
    required this.time,
    required this.foods,
    required this.totalCalories,
    this.image,
  });
}