// lib/screens/workout_planner_screen.dart

import 'package:flutter/material.dart';
import '../models/workout_data.dart';
import '../widgets/app_card.dart';
import '../widgets/app_progress_indicator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_badge.dart';
import '../widgets/exercise_registration_form.dart'; // 운동 등록 폼
import '../widgets/workout_plan_creator.dart';    // 운동 계획 생성 폼

class WorkoutPlannerScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const WorkoutPlannerScreen({super.key, required this.user});

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  WorkoutPlan? _activeWorkout;

  // Mock 데이터
  final _todaysPlan = WorkoutPlan(
    id: 1, name: "Upper Body Strength", status: "active", totalSets: 12, completedSets: 4,
    exercises: [
      Exercise(id: 1, name: "Bench Press", sets: [
        WorkoutSet(id: 1, targetWeight: 60, targetReps: 10, actualWeight: 60, actualReps: 10, status: SetStatus.completed),
        WorkoutSet(id: 2, targetWeight: 60, targetReps: 10, actualWeight: 60, actualReps: 8, status: SetStatus.completed),
        WorkoutSet(id: 3, targetWeight: 65, targetReps: 8),
      ]),
      Exercise(id: 2, name: "Incline Dumbbell Press", sets: [
        WorkoutSet(id: 4, targetWeight: 25, targetReps: 12, actualWeight: 25, actualReps: 12, status: SetStatus.completed),
        WorkoutSet(id: 5, targetWeight: 25, targetReps: 12, actualWeight: 25, actualReps: 10, status: SetStatus.completed),
        WorkoutSet(id: 6, targetWeight: 25, targetReps: 12),
      ]),
    ],
  );

  // --- 로직 함수들 ---
  void _handleStartWorkout() => setState(() => _activeWorkout = _todaysPlan);
  void _handleFinishWorkout() => setState(() => _activeWorkout = null);

  void _handleCompleteSet(WorkoutSet set) {
    setState(() {
      set.status = SetStatus.completed;
      set.actualWeight = set.targetWeight;
      set.actualReps = set.targetReps;
      _todaysPlan.completedSets++;
    });
  }

  void _showExerciseRegistrationForm() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: const ExerciseRegistrationForm(),
        ),
      ),
    );
  }

  void _showWorkoutPlanCreator() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: const WorkoutPlanCreator(),
        ),
      ),
    );
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
          _buildTodaysOverviewCard(),
          const SizedBox(height: 24),
          if (_activeWorkout != null)
            _buildActiveWorkoutView(_activeWorkout!)
          else
            _buildRoutineTemplatesView(),
          const SizedBox(height: 24),
          _buildExerciseLibraryCard(),
          const SizedBox(height: 24),
          _buildWeeklyProgressCard(),
        ],
      ),
    );
  }

  // --- UI 빌더 메소드들 ---
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workout Planner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          // 여기에 날짜 선택 기능 등을 추가할 수 있습니다.
        ],
      ),
    );
  }

  Widget _buildTodaysOverviewCard() {
    final progress = _todaysPlan.completedSets / _todaysPlan.totalSets;
    return AppCard(
      header: AppCardHeader(
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_todaysPlan.name, style: const TextStyle(fontSize: 16)),
          AppBadge(text: _todaysPlan.status, variant: _todaysPlan.status == 'active' ? AppBadgeVariant.defaults : AppBadgeVariant.secondary),
        ]),
        description: Text('${_todaysPlan.completedSets} / ${_todaysPlan.totalSets} sets completed'),
      ),
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppProgressIndicator(value: progress),
            const SizedBox(height: 16),
            if (_activeWorkout == null)
              AppButton(onPressed: _handleStartWorkout, child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.play_arrow, size: 16), SizedBox(width: 8), Text('Start Workout')]))
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text('✅ Workout in progress! Track your sets below.', style: TextStyle(color: Colors.green.shade800)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutView(WorkoutPlan workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...workout.exercises.map((exercise) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AppCard(
            header: AppCardHeader(title: Text(exercise.name)),
            content: AppCardContent(
              child: Column(
                children: exercise.sets.asMap().entries.map((entry) {
                  int idx = entry.key;
                  WorkoutSet set = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Text('#${idx + 1}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Target: ${set.targetWeight}kg × ${set.targetReps} reps'),
                            if (set.status == SetStatus.completed)
                              Text('Actual: ${set.actualWeight}kg × ${set.actualReps} reps', style: const TextStyle(color: Colors.green)),
                          ]),
                        ),
                        if (set.status == SetStatus.completed)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else
                          Row(children: [
                            IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _handleCompleteSet(set)),
                            IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () {}),
                          ]),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        )).toList(),
        const SizedBox(height: 16),
        AppButton(onPressed: _handleFinishWorkout, child: const Text('Finish Workout')),
      ],
    );
  }

  Widget _buildRoutineTemplatesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quick Start Routines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            AppButton(
              onPressed: _showWorkoutPlanCreator,
              size: AppButtonSize.sm, variant: AppButtonVariant.outline,
              child: const Row(children: [Icon(Icons.add, size: 16), SizedBox(width: 4), Text('Create')]),
            )
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16, mainAxisSpacing: 16,
          children: [
            _buildRoutineCard('Upper Body', 4, 12),
            _buildRoutineCard('Lower Body', 5, 15),
          ],
        )
      ],
    );
  }

  Widget _buildRoutineCard(String name, int exercises, int sets) {
    return AppCard(
      content: AppCardContent(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$exercises exercises • $sets sets', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              AppButton(onPressed: () {}, variant: AppButtonVariant.outline, size: AppButtonSize.sm, child: const Text('Load Routine')),
            ]),
      ),
    );
  }

  Widget _buildExerciseLibraryCard() {
    const exercises = ["Bench Press", "Squat", "Deadlift", "Pull-up", "Shoulder Press", "Row"];
    return AppCard(
      header: const AppCardHeader(title: Text('Exercise Library')),
      content: AppCardContent(
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2, childAspectRatio: 4,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8, mainAxisSpacing: 8,
              children: exercises.map((ex) => AppButton(onPressed: () {}, variant: AppButtonVariant.outline, size: AppButtonSize.sm, child: Text(ex))).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () {}, child: const Text('View All Exercises →')),
                AppButton(
                  onPressed: _showExerciseRegistrationForm,
                  size: AppButtonSize.sm, variant: AppButtonVariant.outline,
                  child: const Row(children: [Icon(Icons.add, size: 14), SizedBox(width: 4), Text('새 운동')]),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    return AppCard(
      header: const AppCardHeader(title: Text("This Week's Progress")),
      content: AppCardContent(
        child: Column(
          children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Workouts Completed'), Text('4 / 5')]),
            const SizedBox(height: 8),
            const AppProgressIndicator(value: 0.8),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('12', 'Total Hours', Colors.blue),
                _buildStatItem('156', 'Sets Completed', Colors.green),
                _buildStatItem('2.1k', 'Calories Burned', Colors.orange),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}