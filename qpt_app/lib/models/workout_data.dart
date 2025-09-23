// lib/models/workout_data.dart

enum SetStatus { pending, completed }

class WorkoutSet {
  final int id;
  final int targetWeight;
  final int targetReps;
  
  // 1. final 키워드를 제거해서 값을 변경할 수 있도록 합니다.
  int? actualWeight;
  int? actualReps;
  SetStatus status;

  // 2. 생성자는 그대로 둡니다.
  WorkoutSet({
    required this.id,
    required this.targetWeight,
    required this.targetReps,
    this.actualWeight,
    this.actualReps,
    this.status = SetStatus.pending,
  });
}

// ... (Exercise, WorkoutPlan 클래스는 이전과 동일) ...
class Exercise {
  final int id;
  final String name;
  final List<WorkoutSet> sets;

  Exercise({required this.id, required this.name, required this.sets});
}

class WorkoutPlan {
  final int id;
  final String name;
  final String status;
  final int totalSets;
  int completedSets;
  final List<Exercise> exercises;

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.status,
    required this.totalSets,
    required this.completedSets,
    required this.exercises,
  });
}