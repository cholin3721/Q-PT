// lib/models/exercise_data.dart

enum ExerciseType { weight, cardio }

class Exercise {
  final String id;
  final String name;
  final ExerciseType type;
  final List<String> muscleGroups;

  Exercise({
    required this.id,
    required this.name,
    required this.type,
    required this.muscleGroups,
  });
}

class ExerciseSet {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final ExerciseType exerciseType;
  final int setNumber;

  // 값이 변경될 수 있도록 final을 제거합니다.
  int targetWeight;
  int targetReps;
  int targetDuration;
  String targetIntensity;

  ExerciseSet({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseType,
    required this.setNumber,
    this.targetWeight = 0,
    this.targetReps = 10,
    this.targetDuration = 30,
    this.targetIntensity = '보통',
  });
}